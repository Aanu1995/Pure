import 'package:equatable/equatable.dart';

// The person that invitation is sent to or that receives invitation
// is called invitee.

class Invitee extends Equatable {
  final String inviteeId;
  final String invitationId;
  final DateTime? sentDate;

  const Invitee({
    required this.inviteeId,
    required this.invitationId,
    this.sentDate,
  });

  factory Invitee.fromMap(Map<String, dynamic> data) {
    return Invitee(
      inviteeId: data['receiverId'] as String,
      invitationId: data['id'] as String,
      sentDate: DateTime.parse(data['sentDate'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [inviteeId, invitationId, sentDate];

  // required for data of user to save to local storage
  Map<String, dynamic> toSaveMap() {
    return <String, dynamic>{
      'receiverId': inviteeId,
      'id': invitationId,
      "sentDate": sentDate!.toUtc().toIso8601String(),
    };
  }
}
