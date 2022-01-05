import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/connection_model.dart';
import '../../services/connection_service.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';
import 'connection_state.dart';

class LoadMoreConnectorCubit extends Cubit<ConnectorState> {
  final ConnectionService connectionService;

  LoadMoreConnectorCubit(this.connectionService) : super(ConnectionInitial());

  Future<void> loadMoreConnections(
      String userId, DocumentSnapshot lastDoc) async {
    emit(LoadingConnections());

    try {
      final result =
          await connectionService.loadMoreConnectionList(userId, lastDoc);

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

  bool hasMore(List<Connector> connectorList) {
    if (connectorList.isEmpty) {
      return false;
    }
    return connectorList.length % GlobalUtils.inviteeListLimit == 0;
  }
}

class RefreshConnectionsCubit extends Cubit<ConnectorState> {
  final ConnectionService connectionService;

  RefreshConnectionsCubit(this.connectionService) : super(ConnectionInitial());

  Future<void> refresh(String userId, {bool showIndicator = false}) async {
    if (showIndicator) {
      emit(RefreshingConnectors());
    } else {
      emit(IsRefreshingConnectors());
    }

    try {
      final result = await connectionService.refresh(userId);

      emit(ConnectionsLoaded(connectionModel: result));
    } on NetworkException catch (_) {
      emit(ConnectorsRefreshFailed());
    } on ServerException catch (_) {
      emit(ConnectorsRefreshFailed());
    } catch (_) {
      emit(ConnectorsRefreshFailed());
    }
  }
}

class OtherActionsConnectionCubit extends Cubit<ConnectorState> {
  final ConnectionService connectionService;
  OtherActionsConnectionCubit(this.connectionService)
      : super(ConnectionInitial());

  // takes the index of the item in the list and the invitee model
  Future<void> removeConnection(int index, Connector connector) async {
    emit(RemovingConnector(index));

    try {
      await connectionService.removeConnection(connector.connectionId);

      emit(ConnectorRemoved(connector.connectorId));
    } on NetworkException catch (_) {
      emit(ConnectorRemovalFailed(index: index, connector: connector));
    } on ServerException catch (_) {
      emit(ConnectorRemovalFailed(index: index, connector: connector));
    } catch (_) {
      emit(ConnectorRemovalFailed(index: index, connector: connector));
    }
  }
}
