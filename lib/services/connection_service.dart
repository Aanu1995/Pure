import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/connection_model.dart';
import '../model/invitation_model.dart';
import '../repositories/local_storage.dart';
import '../utils/exception.dart';
import '../utils/global_utils.dart';
import '../utils/request_messages.dart';

abstract class ConnectionService {
  const ConnectionService();

  Future<ConnectionModel> refresh(String userId,
      {int limit = GlobalUtils.inviteeListLimit});
  Stream<ConnectionModel> getConnectionList(String userId,
      {int limit = GlobalUtils.inviteeListLimit});
  Future<ConnectionModel> loadMoreConnectionList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviteeListLimit});
  Future<void> removeConnection(String connectionId);
  Future<Map<String, dynamic>> getConnection(String connectionId);
}

class ConnectionServiceImpl extends ConnectionService {
  final FirebaseFirestore? firestore;
  final LocalStorage? localStorage;

  ConnectionServiceImpl({this.firestore, this.localStorage}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _connectionCollection =
        _firestore.collection(GlobalUtils.connectionCollection);
    _localStorage = localStorage ?? LocalStorageImpl();
  }

  late FirebaseFirestore _firestore;
  late CollectionReference _connectionCollection;
  late LocalStorage _localStorage;

  @override
  Future<ConnectionModel> refresh(String userId,
      {int limit = GlobalUtils.inviteeListLimit}) async {
    List<Connector> connectionList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _connectionCollection
              .where("members", arrayContains: userId)
              .orderBy('date', descending: true)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        for (final querySnap in querySnapshot.docs) {
          final data = querySnap.data()!;
          connectionList.add(getConnector(data, userId));
        }
      }
      await _saveToStorage(connectionList, GlobalUtils.connectionsPrefKey);
      return ConnectionModel(connectors: connectionList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<ConnectionModel> loadMoreConnectionList(
      String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.inviteeListLimit}) async {
    List<Connector> connectionList = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _connectionCollection
              .where("members", arrayContains: userId)
              .orderBy('date', descending: true)
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
          connectionList.add(getConnector(data, userId));
        }
      }
      return ConnectionModel(connectors: connectionList, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<ConnectionModel> getConnectionList(String userId,
      {int limit = GlobalUtils.inviteeListLimit}) {
    try {
      return _connectionCollection
          .where("members", arrayContains: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<Connector> connectionList = [];

        if (querySnapshot.docs.isNotEmpty) {
          for (final querySnap in querySnapshot.docs) {
            final data = querySnap.data()! as Map<String, dynamic>;
            connectionList.add(getConnector(data, userId));
          }
        }
        await _saveToStorage(connectionList, GlobalUtils.connectionsPrefKey);
        return ConnectionModel(
          connectors: connectionList,
          lastDoc: querySnapshot.docs.last,
        );
      });
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<Map<String, dynamic>> getConnection(String connectionId) async {
    try {
      final docSnapshot = await _connectionCollection
          .doc(connectionId)
          .get()
          .timeout(GlobalUtils.timeOutInDuration);
      return docSnapshot.data() as Map<String, dynamic>;
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  /// ###################################################################
  /// helper method

  // get the connector userId from the member list
  String getConnectorUserId(List members, final String currentUserId) {
    members.remove(currentUserId);
    return members.first as String;
  }

  Connector getConnector(Map<String, dynamic> data, String currentUserId) {
    final members = data["members"] as List;
    final connectorId = getConnectorUserId(members, currentUserId);
    final connector = Connector.fromMap(data, connectorId: connectorId);
    return connector;
  }

  @override
  Future<void> removeConnection(String connectionId) async {
    try {
      await _connectionCollection
          .doc(connectionId)
          .delete()
          .timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // save latest data to database
  Future<void> _saveToStorage(List<Connector> users, String databaseKey) async {
    List<Map<String, dynamic>> data = [];

    for (final user in users) {
      data.add(user.toSaveMap());
    }
    await _localStorage.saveData(databaseKey, data);
  }
}
