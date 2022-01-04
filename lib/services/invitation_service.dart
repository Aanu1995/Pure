import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/invitation_model.dart';
import '../model/invitee_model.dart';
import '../model/inviter_model.dart';
import '../repositories/connection.dart';
import '../repositories/local_storage.dart';
import '../utils/exception.dart';
import '../utils/global_utils.dart';
import '../utils/request_messages.dart';

abstract class InvitationService {
  const InvitationService();

  Future<void> sendInvitation(Map<String, dynamic> data);
  Future<InviteeModel> refreshInvitees(String userId,
      {int limit = GlobalUtils.inviteeListLimit});
  Future<void> withdrawInvitation(String invitationId);
  Future<InviteeModel> loadMoreSentInvitationList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviteeListLimit});
  Stream<InviteeModel> getSentInvitationList(String userId,
      {int limit = GlobalUtils.inviteeListLimit});
  Future<void> acceptInvitation(String invitationId);
  Future<InviterModel> refreshInviters(String userId,
      {int limit = GlobalUtils.inviterListLimit});
  Future<InviterModel> loadMoreReceivedInvitationList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviterListLimit});
  Stream<InviterModel> getReceivedInvitationList(String userId,
      {int limit = GlobalUtils.inviteeListLimit});
}

class InvitationServiceImp extends InvitationService {
  final FirebaseFirestore? firestore;
  final ConnectionRepo? connection;
  final LocalStorage? localStorage;

  InvitationServiceImp({
    this.firestore,
    this.connection,
    this.localStorage,
    bool isPersistentEnabled = true,
  }) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _firestore.settings = Settings(persistenceEnabled: isPersistentEnabled);
    _invitationCollection =
        _firestore.collection(GlobalUtils.invitationCollection);
    _connection = connection ?? ConnectionRepoImpl();
    _localStorage = localStorage ?? LocalStorageImpl();
  }

  late ConnectionRepo _connection;
  late FirebaseFirestore _firestore;
  late CollectionReference _invitationCollection;
  late LocalStorage _localStorage;

  @override
  Future<void> sendInvitation(Map<String, dynamic> data) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      final id = data['id'] as String;

      await _invitationCollection
          .doc(id)
          .set(data)
          .timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<InviteeModel> refreshInvitees(String userId,
      {int limit = GlobalUtils.inviteeListLimit}) async {
    // check internet connection
    await _connection.checkConnectivity();
    List<Invitee> inviteeList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _invitationCollection
              .where("senderId", isEqualTo: userId)
              .orderBy('sentDate', descending: true)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;

        for (final querySnap in querySnapshot.docs) {
          final data = querySnap.data()!;
          inviteeList.add(Invitee.fromMap(data));
        }
      }

      _saveInviteeToStorage(inviteeList, GlobalUtils.sentInvitationPrefKey);
      return InviteeModel(invitees: inviteeList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<InviteeModel> getSentInvitationList(String userId,
      {int limit = GlobalUtils.inviteeListLimit}) {
    try {
      return _invitationCollection
          .where("senderId", isEqualTo: userId)
          .orderBy('sentDate', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<Invitee> inviteeList = [];
        if (querySnapshot.docs.isNotEmpty) {
          for (final querySnap in querySnapshot.docs) {
            final data = querySnap.data()! as Map<String, dynamic>;
            inviteeList.add(Invitee.fromMap(data));
          }
        }
        await _saveInviteeToStorage(
            inviteeList, GlobalUtils.sentInvitationPrefKey);
        return InviteeModel(invitees: inviteeList);
      });
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<InviteeModel> loadMoreSentInvitationList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviteeListLimit}) async {
    // check internet connection
    await _connection.checkConnectivity();
    List<Invitee> inviteeList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _invitationCollection
              .where("senderId", isEqualTo: userId)
              .orderBy('sentDate', descending: true)
              .startAfterDocument(doc)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;

        for (final querySnap in querySnapshot.docs) {
          final data = querySnap.data()!;
          inviteeList.add(Invitee.fromMap(data));
        }
      }

      return InviteeModel(invitees: inviteeList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<InviterModel> refreshInviters(String userId,
      {int limit = GlobalUtils.inviterListLimit}) async {
    // check internet connection
    await _connection.checkConnectivity();
    List<Inviter> inviterList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _invitationCollection
              .where("receiverId", isEqualTo: userId)
              .orderBy('sentDate', descending: true)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;

        for (final querySnap in querySnapshot.docs) {
          final data = querySnap.data()!;
          inviterList.add(Inviter.fromMap(data));
        }
      }

      _saveInviterToStorage(inviterList, GlobalUtils.receivedInvitationPrefKey);
      return InviterModel(inviters: inviterList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<InviterModel> getReceivedInvitationList(String userId,
      {int limit = GlobalUtils.inviteeListLimit}) {
    try {
      return _invitationCollection
          .where("receiverId", isEqualTo: userId)
          .orderBy('sentDate', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<Inviter> inviterList = [];
        if (querySnapshot.docs.isNotEmpty) {
          for (final querySnap in querySnapshot.docs) {
            final data = querySnap.data()! as Map<String, dynamic>;
            inviterList.add(Inviter.fromMap(data));
          }
        }
        await _saveInviterToStorage(
            inviterList, GlobalUtils.receivedInvitationPrefKey);
        return InviterModel(inviters: inviterList);
      });
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<InviterModel> loadMoreReceivedInvitationList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviterListLimit}) async {
    // check internet connection
    await _connection.checkConnectivity();
    List<Inviter> inviterList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _invitationCollection
              .where("receiverId", isEqualTo: userId)
              .orderBy('sentDate', descending: true)
              .startAfterDocument(doc)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;

        for (final querySnap in querySnapshot.docs) {
          final data = querySnap.data()!;
          inviterList.add(Inviter.fromMap(data));
        }
      }

      return InviterModel(inviters: inviterList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      await _invitationCollection.doc(invitationId).update({
        "isAccepted": true,
        "sentDate": DateTime.now().toUtc().toIso8601String()
      }).timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> withdrawInvitation(String invitationId) async {
    // check internet connection
    await _connection.checkConnectivity();

    try {
      await _invitationCollection
          .doc(invitationId)
          .delete()
          .timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // helper Methods

  // save latest data to database
  Future<void> _saveInviteeToStorage(
      List<Invitee> users, String databaseKey) async {
    List<Map<String, dynamic>> data = [];

    for (final user in users) {
      data.add(user.toSaveMap());
    }
    await _localStorage.saveData(databaseKey, data);
  }

  // save latest data to database
  Future<void> _saveInviterToStorage(
      List<Inviter> users, String databaseKey) async {
    List<Map<String, dynamic>> data = [];

    for (final user in users) {
      data.add(user.toSaveMap());
    }
    await _localStorage.saveData(databaseKey, data);
  }
}
