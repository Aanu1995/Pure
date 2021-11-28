import 'package:equatable/equatable.dart';

import 'pure_user_model.dart';

class PureUserExtraModel extends Equatable {
  final int totalConnection;
  final List<String> connections;

  const PureUserExtraModel({
    required this.connections,
    required this.totalConnection,
  });

  factory PureUserExtraModel.fromMap(Map<String, dynamic> data) {
    final List<String> connections = [];
    final connectionsMap = data["connections"] as Map<String, dynamic>;

    for (final connection in connectionsMap.entries) {
      final status = PureUser.getStatus(connection.value as int);
      if (status == ConnectionStatus.Connected) connections.add(connection.key);
    }

    return PureUserExtraModel(
      totalConnection: data["connectionCounter"] as int,
      connections: connections,
    );
  }

  @override
  List<Object?> get props => [totalConnection, connections];
}
