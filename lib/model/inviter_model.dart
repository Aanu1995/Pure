// The person that sent invitation is called inviter

import 'package:equatable/equatable.dart';

class Inviter extends Equatable {
  final String inviterId;
  final String invitationId;
  final DateTime? receivedDate;

  const Inviter({
    required this.inviterId,
    required this.invitationId,
    this.receivedDate,
  });

  factory Inviter.fromMap(Map<String, dynamic> data) {
    return Inviter(
      inviterId: data['senderId'] as String,
      invitationId: data['id'] as String,
      receivedDate: DateTime.parse(data['sentDate'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [inviterId, invitationId, receivedDate];

  // required for data of user to save to local storage
  Map<String, dynamic> toSaveMap() {
    return <String, dynamic>{
      'senderId': inviterId,
      'id': invitationId,
      "sentDate": receivedDate!.toUtc().toIso8601String(),
    };
  }
}
