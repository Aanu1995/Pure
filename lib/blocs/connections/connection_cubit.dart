import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/connection_model.dart';
import '../../model/invitation_model.dart';
import '../../repositories/local_storage.dart';
import '../../services/connection_service.dart';
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
  StreamSubscription<ConnectionModel>? _subscription;

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
    try {
      _subscription?.cancel();
      _subscription =
          connectionService.getConnectionList(userId).listen((connectionModel) {
        _subscription?.cancel();
        emit(ConnectionsLoaded(connectionModel: connectionModel));
      });
    } catch (_) {
      final currentState = state;
      if (currentState is! ConnectionsLoaded)
        emit(ConnectionFailed(ErrorMessages.generalMessage2));
    }
  }

  // Preciely used when to update the UI after it is refreshed
  void updateNewConnection(ConnectionModel connectionModel) {
    emit(ConnectionsLoaded(
      connectionModel: connectionModel,
      hasMore: hasMore(connectionModel.connectors),
    ));
  }

  // Precisely used to update the UI when more connections are fetched (pagination)
  void updateOldConnection(ConnectionModel connectionModel, bool hasMore) {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final doc = connectionModel.lastDoc;
      final totalConnections = [
        ...currentState.connectionModel.connectors.toList(),
        ...connectionModel.connectors.toList(),
      ];

      final model = ConnectionModel(connectors: totalConnections, lastDoc: doc);
      emit(ConnectionsLoaded(connectionModel: model, hasMore: hasMore));
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

  /// Helper methods

  bool hasMore(List<Connector> connectorList) {
    if (connectorList.isEmpty) return false;
    return connectorList.length % GlobalUtils.inviteeListLimit == 0;
  }

  List<Connector> _mapDataToModel(List data) {
    final connectorList = <Connector>[];
    for (final connectorJson in data) {
      connectorList
          .add(Connector.fromMap(connectorJson as Map<String, dynamic>));
    }

    return connectorList;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
