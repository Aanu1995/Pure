import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatType { One_To_One, Group }

class ChatsModel extends Equatable {
  final List<ChatModel> chats;
  final DocumentSnapshot? firstDoc;
  final DocumentSnapshot? lastDoc;

  const ChatsModel({required this.chats, this.firstDoc, this.lastDoc});

  @override
  List<Object?> get props => [chats, lastDoc];
}

class ChatModel extends Equatable {
  final String chatId;
  final ChatType type;
  final String? groupName; // required for group chat
  final String? groupDescription; // required for group chat
  final String? groupImage; // required for group chat
  final List<String> members;
  final DateTime creationDate;
  final DateTime updateDate;
  final String lastMessage;

  const ChatModel({
    required this.chatId,
    required this.type,
    this.groupName,
    this.groupDescription,
    this.groupImage,
    required this.creationDate,
    required this.lastMessage,
    required this.members,
    required this.updateDate,
  });

  factory ChatModel.fromMap(Map<String, dynamic> data) {
    final members = <String>[];
    for (String userId in data['members']) members.add(userId);

    return ChatModel(
      chatId: data["chatId"] as String,
      type: getChatTpe(data["type"] as String),
      lastMessage: data["lastMessage"] as String,
      members: members,
      creationDate: DateTime.parse(data['creationDate'] as String).toLocal(),
      updateDate: DateTime.parse(data['updateDate'] as String).toLocal(),
    );
  }

  static ChatType getChatTpe(final String type) {
    switch (type) {
      case "group":
        return ChatType.Group;
      default:
        return ChatType.One_To_One;
    }
  }

  // only available to one to one chat
  // only available to get the other userId
  String? getReceipient(final String currentuserId) {
    if (type == ChatType.One_To_One) {
      final users = members.toList();
      users.remove(currentuserId);
      return users.first;
    }
  }

  @override
  List<Object?> get props => [
        chatId,
        type,
        groupName,
        groupDescription,
        groupImage,
        creationDate,
        lastMessage,
        members,
        updateDate
      ];
}
