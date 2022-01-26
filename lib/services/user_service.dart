import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stream_transform/stream_transform.dart';

import '../model/pure_user_extra.dart';
import '../model/pure_user_model.dart';
import '../model/user_presence_model.dart';
import '../repositories/connection.dart';
import '../repositories/local_storage.dart';
import '../utils/exception.dart';
import '../utils/global_utils.dart';
import '../utils/request_messages.dart';
import 'remote_storage_service.dart';

abstract class UserService {
  const UserService();

  Future<PureUser> getUser(String userId);
  Future<PureUserExtraModel> getUserExtraData(String userId);
  Future<PureUser> getUserIfExistOrCreate(
      String userId, Map<String, dynamic> data);
  Future<void> createUser(String userId, Map<String, dynamic> data);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Future<void> updateUserProfileImage(String userId, File file);
  Future<void> deleteProfileImage(String userId);
  Future<void> updateUserFCMToken(String userId, String deviceId, String token);
  Stream<PureUser> getCurrentUserData(String userId);
  Stream<PureUser?> getUserData(String userId);
  Stream<UserPresenceModel?> getUserPresence(String userId);
  Future<void> setUserPresence(String userId);
  Future<void> setUserOfflineOnSignOut(String userId);
  Stream<PureUser> getGroupMember(String userId);
}

class UserServiceImpl extends UserService {
  final FirebaseFirestore? firestore;
  final FirebaseDatabase? firebaseDatabase;
  final LocalStorage? localStorage;
  final ConnectionRepo? connection;
  RemoteStorage? remoteStorage;

  UserServiceImpl({
    this.firestore,
    this.firebaseDatabase,
    this.localStorage,
    this.connection,
    this.remoteStorage,
  }) {
    _userCollection = (firestore ?? FirebaseFirestore.instance)
        .collection(GlobalUtils.userCollection);
    _userExtCollection = (firestore ?? FirebaseFirestore.instance)
        .collection(GlobalUtils.userExtCollection);
    _databaseReference = (firebaseDatabase ?? FirebaseDatabase.instance)
        .reference()
        .child(GlobalUtils.userCollection);
    _connection = connection ?? ConnectionRepoImpl();
    _localStorage = localStorage ?? LocalStorageImpl();
    _remoteStorage = remoteStorage ?? RemoteStorageImpl();
  }

  late CollectionReference _userCollection;
  late CollectionReference _userExtCollection;
  late DatabaseReference _databaseReference;
  late ConnectionRepo _connection;
  late LocalStorage _localStorage;
  late RemoteStorage _remoteStorage;

  @override
  Future<PureUser> getUser(String userId) async {
    try {
      return _getCurrentUserProfile(userId);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // This gets the user extra data such as connection list
  @override
  Future<PureUserExtraModel> getUserExtraData(String userId) async {
    try {
      final docSnap = await _userExtCollection.doc(userId).get();
      return PureUserExtraModel.fromMap(docSnap.data() as Map<String, dynamic>);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // gets the current user data, including connections and requests
  @override
  Stream<PureUser> getCurrentUserData(String userId) {
    try {
      return getUserDataStream(userId).combineLatest(
        getUserExtDataStream(userId),
        (Map<String, dynamic> first, Map<String, dynamic>? second) {
          final newData = first;
          newData["connections"] = second?["connections"];
          newData["receivedCounter"] = second?["receivedCounter"];
          newData["sentCounter"] = second?["sentCounter"];
          newData["connectionCounter"] = second?["connectionCounter"];
          return _getUserFromMap(newData);
        },
      );
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<PureUser?> getUserData(String userId) {
    try {
      return _userCollection.doc(userId).snapshots().map((docSnapshot) {
        return PureUser.fromMap(docSnapshot.data() as Map<String, dynamic>);
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Stream<PureUser> getGroupMember(String userId) {
    return _userCollection.doc(userId).snapshots().map((docSnapshot) {
      return PureUser.fromMap(docSnapshot.data() as Map<String, dynamic>);
    });
  }

  // Listens to when user is offline or online
  @override
  Stream<UserPresenceModel?> getUserPresence(String userId) {
    try {
      return _userExtCollection.doc(userId).snapshots().map((docSnapshot) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return UserPresenceModel.fromMap(data);
      });
    } catch (e) {
      return Stream.value(UserPresenceModel.onError());
    }
  }

  // gets user from the remote database if exists, or create the user if it
  // does not exist
  @override
  Future<PureUser> getUserIfExistOrCreate(
      String userId, Map<String, dynamic> data) async {
    try {
      final docSnapshot = await _userCollection
          .doc(userId)
          .get()
          .timeout(GlobalUtils.timeOutInDuration);
      if (docSnapshot.exists) {
        // gets ahoy user from document snapshot
        return await _getUserFromDocSnapshot(docSnapshot);
      } else {
        // create user in remote database
        await _userCollection.doc(userId).set(data);
        return await _getUserFromMap(data);
      }
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    try {
      await _userCollection
          .doc(userId)
          .set(data)
          .timeout(GlobalUtils.timeOutInDuration);
      return;
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      await _userCollection
          .doc(userId)
          .update(data)
          .timeout(GlobalUtils.timeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  /// update user profile image in the database
  /// if file is null then the profile image will be deleted from the database
  @override
  Future<void> updateUserProfileImage(String userId, File file) async {
    // check internet connection
    await _connection.checkConnectivity();

    // upload the image file and update the database
    try {
      final photoURL = await _remoteStorage.uploadProfileImage(userId, file);
      if (photoURL != null) {
        await _userCollection.doc(userId).update({'photoURL': photoURL});
      } else {
        throw ServerException(message: ErrorMessages.generalMessage2);
      }
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    // check internet connection
    await _connection.checkConnectivity();

    // upload the image file and update the database
    try {
      // delete the user profile image in the database
      await _userCollection
          .doc(userId)
          .update({'photoURL': ''}).timeout(GlobalUtils.timeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // updates the user token in Firebase
  @override
  Future<void> updateUserFCMToken(
      String userId, String deviceId, String token) async {
    await _userCollection.doc(userId).update({'FCM_token.$deviceId': token});
  }

  @override
  Future<void> setUserPresence(String userId) async {
    final onlineData = UserPresenceModel.onlineData();
    final offlineData = UserPresenceModel.offlineData();

    // disconnects
    try {
      await _databaseReference.child(userId).onDisconnect().update(offlineData);
    } catch (e) {
      log(e.toString());
    }

    // connects
    try {
      await _databaseReference.child(userId).update(onlineData);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> setUserOfflineOnSignOut(String userId) async {
    final onlineData = UserPresenceModel.offlineData();

    // connects
    try {
      await _databaseReference
          .child(userId)
          .update(onlineData)
          .timeout(GlobalUtils.shortTimeOutInDuration);
    } catch (e) {
      log(e.toString());
    }
  }

  /// ###################################################################
  /// helper method

  Future<PureUser> _getCurrentUserProfile(String userId) async {
    final docSnapshot = await _userCollection
        .doc(userId)
        .get()
        .timeout(GlobalUtils.timeOutInDuration);
    // gets ahoy user from document snapshot
    return await _getUserFromDocSnapshot(docSnapshot);
  }

  Future<PureUser> _getUserFromDocSnapshot(DocumentSnapshot docSnapshot) async {
    final data = docSnapshot.data() as Map<String, dynamic>;
    // save data to the local storage
    _localStorage.saveUserData(data);
    return PureUser.fromMap(data);
  }

  Future<PureUser> _getUserFromMap(Map<String, dynamic> data) async {
    // save data to the local storage
    _localStorage.saveUserData(data);
    return PureUser.fromMap(data);
  }

  // gets the user data stream
  Stream<Map<String, dynamic>> getUserDataStream(String userId) {
    return _userCollection.doc(userId).snapshots().map((docSnapshot) {
      return docSnapshot.data() as Map<String, dynamic>;
    });
  }

  // gets the user ext data stream
  Stream<Map<String, dynamic>?> getUserExtDataStream(String userId) {
    return _userExtCollection.doc(userId).snapshots().map((docSnapshot) {
      return docSnapshot.data() as Map<String, dynamic>?;
    });
  }
}
