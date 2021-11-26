import 'package:equatable/equatable.dart';

import 'inviter_model.dart';

// The person that you are connected with is called Connector
class Connector extends Equatable {
  final String connectorId;
  final String connectionId;
  final DateTime? connectionDate;

  const Connector({
    required this.connectorId,
    required this.connectionId,
    this.connectionDate,
  });

  factory Connector.fromMap(Map<String, dynamic> data, {String? connectorId}) {
    return Connector(
      connectorId: connectorId ?? data['connectorId'] as String,
      connectionId: data['id'] as String,
      connectionDate: DateTime.parse(data['date'] as String).toLocal(),
    );
  }

  factory Connector.fromInviter(Inviter inviter) {
    return Connector(
      connectorId: inviter.inviterId,
      connectionId: inviter.invitationId,
      connectionDate: DateTime.now().toLocal(),
    );
  }

  @override
  List<Object?> get props => [connectorId, connectionId, connectionDate];

  // required for data of user to save to local storage
  Map<String, dynamic> toSaveMap() {
    return <String, dynamic>{
      'connectorId': connectorId,
      'id': connectionId,
      "date": connectionDate!.toUtc().toIso8601String(),
    };
  }
}
