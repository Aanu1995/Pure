import 'package:equatable/equatable.dart';

import '../../model/connection_model.dart';
import '../../model/invitation_model.dart';

class ConnectorState extends Equatable {
  const ConnectorState();

  @override
  List<Object?> get props => [];
}

class ConnectionInitial extends ConnectorState {}

class LoadingConnections extends ConnectorState {}

class ConnectionsLoaded extends ConnectorState {
  final ConnectionModel connectionModel;
  final bool hasMore;

  const ConnectionsLoaded({required this.connectionModel, this.hasMore = true});

  @override
  List<Object?> get props => [connectionModel];
}

class ConnectionFailed extends ConnectorState {
  final String message;

  const ConnectionFailed(this.message);
}

// For Refresh
class RefreshingConnectors extends ConnectorState {}

class IsRefreshingConnectors extends ConnectorState {}

class ConnectorsRefreshFailed extends ConnectorState {}

// Remote Connection State

class RemovingConnector extends ConnectorState {
  final int index;

  const RemovingConnector(this.index);
}

class ConnectorRemoved extends ConnectorState {
  final String connectorId;

  ConnectorRemoved(this.connectorId);
}

class ConnectorRemovalFailed extends ConnectorState {
  final int index;
  final Connector connector;

  const ConnectorRemovalFailed({required this.index, required this.connector});
}
