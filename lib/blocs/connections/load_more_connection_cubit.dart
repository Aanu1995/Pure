import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/connection_model.dart';
import '../../model/invitation_model.dart';
import '../../services/connection_service.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';
import 'connection_state.dart';

class LoadMoreConnectorCubit extends Cubit<ConnectorState> {
  final ConnectionService connectionService;

  LoadMoreConnectorCubit({required this.connectionService})
      : super(ConnectionInitial());

  Future<void> loadMoreInvitees(
      String userId, ConnectionModel connectionModel) async {
    emit(LoadingConnections());

    try {
      final result = await connectionService.loadMoreConnectionList(
          userId, connectionModel.lastDocs!);

      List<Connector> newData = [
        ...connectionModel.connectors.toList(),
        ...result.connectors
      ];

      emit(ConnectionsLoaded(
        connectionModel: ConnectionModel(
          connectors: newData,
          lastDocs: result.lastDocs,
        ),
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

  Future<void> refresh(String userId, {bool showIndicator = false}) async {
    if (showIndicator) {
      emit(RefreshingConnectors());
    } else {
      emit(IsRefreshingConnectors());
    }

    try {
      final result = await connectionService.getConnectionList(userId);

      emit(ConnectionsLoaded(
        connectionModel: result,
        hasMore: hasMore(result.connectors),
      ));
    } on NetworkException catch (_) {
      emit(ConnectorsRefreshFailed());
    } on ServerException catch (_) {
      emit(ConnectorsRefreshFailed());
    } catch (_) {
      emit(ConnectorsRefreshFailed());
    }
  }

  bool hasMore(List<Connector> connectorList) {
    if (connectorList.isEmpty) {
      return false;
    }
    return connectorList.length % GlobalUtils.inviteeListLimit == 0;
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
