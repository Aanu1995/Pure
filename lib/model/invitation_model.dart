import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'connection_model.dart';
import 'invitee_model.dart';
import 'inviter_model.dart';

class ConnectionModel extends Equatable {
  final List<Connector> connectors;
  final DocumentSnapshot? lastDoc;

  const ConnectionModel({required this.connectors, this.lastDoc});

  @override
  List<Object?> get props => [connectors, lastDoc];
}

class InviteeModel extends Equatable {
  final List<Invitee> invitees;
  final DocumentSnapshot? lastDoc;

  const InviteeModel({required this.invitees, this.lastDoc});

  @override
  List<Object?> get props => [invitees, lastDoc];
}

class InviterModel extends Equatable {
  final List<Inviter> inviters;
  final DocumentSnapshot? lastDocs;

  const InviterModel({required this.inviters, this.lastDocs});

  @override
  List<Object?> get props => [inviters, lastDocs];
}

class InvitationModel {
  final String senderId;
  final String receiverId;
  final bool isAccepted;
  const InvitationModel({
    required this.senderId,
    required this.receiverId,
    this.isAccepted = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': getInvitationId(senderId, receiverId),
      "senderId": senderId,
      "receiverId": receiverId,
      "isAccepted": isAccepted,
      "sentDate": DateTime.now().toUtc().toIso8601String(),
      "members": [senderId, receiverId],
    };
  }

  Map<String, dynamic> toInviteLinkMap(String id) {
    return <String, dynamic>{
      'id': id,
      "senderId": senderId,
      "receiverId": "",
      "isAccepted": false,
      "sentDate": DateTime.now().toUtc().toIso8601String(),
      "members": [senderId],
    };
  }

  static Map<String, dynamic> toUpdateMap(bool isAccepted) {
    return <String, dynamic>{"isAccepted": isAccepted};
  }

  static String getInvitationId(String senderId, String receiverId) {
    if (senderId.compareTo(receiverId) == -1) {
      return "${senderId}_${receiverId}";
    } else {
      return "${receiverId}_${senderId}";
    }
  }
}
