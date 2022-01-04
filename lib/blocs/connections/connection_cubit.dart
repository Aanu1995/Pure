import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/connection_model.dart';
import '../../model/invitation_model.dart';
import '../../repositories/local_storage.dart';
import '../../services/connection_service.dart';
import '../../utils/connection_utils.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';
import 'connection_state.dart';

class ConnectorCubit extends Cubit<ConnectorState> {
  final ConnectionService connectionService;
  final LocalStorage? localStorage;
  ConnectorCubit({required this.connectionService, this.localStorage})
      : super(ConnectionInitial()) {
    _localStorage = localStorage ?? LocalStorageImpl();
  }

  late LocalStorage _localStorage;
  StreamSubscription<ConnectionModel?>? _subscription;

  Future<void> loadConnections(String userId) async {
    // load data from local storage first
    await _loadDataFromLocalStorage();
    loadDataFromRemoteStorage(userId);
  }

  Future<void> _loadDataFromLocalStorage() async {
    try {
      // load from local storage
      final data =
          await _localStorage.getData(GlobalUtils.connectionsPrefKey) as List?;
      if (data != null) {
        final connectorList = _mapDataToModel(data);
        final connectionModel = ConnectionModel(connectors: connectorList);
        emit(ConnectionsLoaded(connectionModel: connectionModel));
      }
    } catch (e) {
      emit(ConnectionFailed(ErrorMessages.generalMessage2));
    }
  }

  void loadDataFromRemoteStorage(String userId) {
    final currentState = state;
    if (currentState is! ConnectionsLoaded) emit(LoadingConnections());

    try {
      _subscription?.cancel();
      _subscription =
          connectionService.getConnectionList(userId).listen((connectionModel) {
        List<Connector> newConnectorsList = connectionModel.connectors.toList();
        List<Connector> oldConnectorsList = [];
        DocumentSnapshot? oldLastDoc;
        if (currentState is ConnectionsLoaded) {
          oldConnectorsList = currentState.connectionModel.connectors;
          oldLastDoc = currentState.connectionModel.lastDoc;
        }

        final totalList = [...newConnectorsList, ...oldConnectorsList.toList()];
        final result = ConnectionModel(
          connectors: orderedSetForConnections(totalList),
          lastDoc: newConnectorsList.length > oldConnectorsList.length
              ? connectionModel.lastDoc
              : oldLastDoc,
        );
        emit(ConnectionsLoaded(connectionModel: result));
      });
    } catch (_) {
      if (currentState is! ConnectionsLoaded)
        emit(ConnectionFailed(ErrorMessages.generalMessage2));
    }
  }

  // Preciely used when to update the UI after it is refreshed
  void updateNewConnection(ConnectionModel connectionModel) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final docs = currentState.connectionModel.lastDoc;
      final conns = orderedSetForConnections([
        ...connectionModel.connectors.toList(),
        ...currentState.connectionModel.connectors.toList()
      ]);
      emit(
        ConnectionsLoaded(
          connectionModel: ConnectionModel(connectors: conns, lastDoc: docs),
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  // Precisely used to update the UI when more connections is fetched (pagination)
  void updateOldConnection(ConnectionModel connectionModel, bool hasMore) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final doc = connectionModel.lastDoc;
      final conns = orderedSetForConnections([
        ...currentState.connectionModel.connectors.toList(),
        ...connectionModel.connectors.toList(),
      ]);
      emit(
        ConnectionsLoaded(
          connectionModel: ConnectionModel(connectors: conns, lastDoc: doc),
          hasMore: hasMore,
        ),
      );
    }
  }

  void delete(int index) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final connectionList = currentState.connectionModel.connectors.toList();
      // remove the invitee from the list
      connectionList.removeAt(index);

      emit(ConnectionsLoaded(
        connectionModel: ConnectionModel(
          connectors: connectionList,
          lastDoc: currentState.connectionModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  void deleteItemWithId(String connectorId) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final connectionList = currentState.connectionModel.connectors.toList();
      // remove the invitee from the list
      connectionList.removeWhere(
        (element) => element.connectorId == connectorId,
      );

      emit(ConnectionsLoaded(
        connectionModel: ConnectionModel(
          connectors: connectionList,
          lastDoc: currentState.connectionModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  void addConnectionBack(int index, Connector connector) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final connectionList = currentState.connectionModel.connectors.toList();
      // remove the invitee from the list
      connectionList.insert(index, connector);

      emit(ConnectionsLoaded(
        connectionModel: ConnectionModel(
          connectors: connectionList,
          lastDoc: currentState.connectionModel.lastDoc,
        ),
        hasMore: currentState.hasMore,
      ));
    }
  }

  // This disposes the stream and initialize the cubit
  void dispose() {
    _subscription?.cancel();
    emit(ConnectionInitial());
  }

  /// Helper methods

  List<Connector> _mapDataToModel(List data) {
    final connectorList = <Connector>[];
    for (final connectorJson in data) {
      connectorList
          .add(Connector.fromMap(connectorJson as Map<String, dynamic>));
    }

    return connectorList;
  }
}
