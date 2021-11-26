import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/connection_model.dart';
import '../../model/invitation_model.dart';
import '../../repositories/local_storage.dart';
import '../../services/connection_service.dart';
import '../../utils/exception.dart';
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
    List? data;

    try {
      data =
          await _localStorage.getData(GlobalUtils.connectionsPrefKey) as List?;
    } catch (e) {}

    // if data is available in local storage, load from local storage first
    // and then sync the local data with remote data.
    // else load from remote database directly
    if (data != null) {
      try {
        final currentState = state;

        // load from local storage
        final connectorList = _mapDataToModel(data);

        if (currentState is ConnectionInitial) {
          emit(LoadingConnections());

          connectionService.getConnectionList(userId).then((result) {
            emit(ConnectionsLoaded(
              connectionModel: result,
              hasMore: hasMore(result.connectors),
            ));
          });

          _subscription?.cancel();
          _subscription = connectionService
              .syncLocalDatabaseWithRemote(userId)
              .listen((user) {});
        }

        emit(
          ConnectionsLoaded(
            connectionModel: ConnectionModel(connectors: connectorList),
          ),
        );
      } catch (e) {
        emit(ConnectionFailed(ErrorMessages.generalMessage2));
      }
    } else {
      final currentState = state;
      if (currentState is ConnectionInitial) {
        // sync data
        _subscription?.cancel();
        _subscription = connectionService
            .syncLocalDatabaseWithRemote(userId)
            .listen((user) {});
      }

      // load directly from local storage
      return loadFromremoteStorage(userId);
    }
  }

  Future<void> loadFromremoteStorage(String userId) async {
    emit(LoadingConnections());

    try {
      // load directly from local storage
      final result = await connectionService.getConnectionList(userId);

      emit(ConnectionsLoaded(
        connectionModel: result,
        hasMore: hasMore(result.connectors),
      ));
    } on NetworkException catch (e) {
      emit(ConnectionFailed(e.message!));
    } on ServerException catch (e) {
      emit(ConnectionFailed(e.message!));
    } catch (_) {
      emit(ConnectionFailed(ErrorMessages.generalMessage2));
    }
  }

  void updateConnection(ConnectionModel connectionModel, bool hasMore) {
    emit(ConnectionsLoaded(connectionModel: connectionModel, hasMore: hasMore));
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
          lastDocs: currentState.connectionModel.lastDocs,
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
          lastDocs: currentState.connectionModel.lastDocs,
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
          lastDocs: currentState.connectionModel.lastDocs,
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

  bool hasMore(List<Connector> connectorList) {
    if (connectorList.isEmpty) {
      return false;
    }
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
}
