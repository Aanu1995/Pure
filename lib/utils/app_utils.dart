import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../model/chat/chat_model.dart';
import '../model/chat/message_model.dart';
import '../model/pure_user_model.dart';
import '../repositories/push_notification.dart';
import '../services/user_service.dart';

// Generate a v1 (time-based) identifier
String generateDatabaseId() {
  return const Uuid().v1();
}

String generateRandomId() {
  return const Uuid().v1();
}

// updates the user fcm token in the remote database
Future<void> updateUserFCMToken(String userId) async {
  final notification = PushNotificationImpl();
  final token = await notification.getToken();
  final deviceId = await notification.getDeviceId();
  if (deviceId != null && token != null) {
    // updates the token at the server side
    UserServiceImpl().updateUserFCMToken(userId, deviceId, token);
  }
}

String getFormattedTime(DateTime date) {
  return timeago.format(date, allowFromNow: true);
}

String groupDate(DateTime date) {
  final filteredDate = DateTime(date.year, date.month, date.day);
  if (DateTime.now().difference(filteredDate).inDays == 0) return "Today";
  if (DateTime.now().difference(filteredDate).inDays == 1) return "Yesterday";
  if (DateTime.now().difference(filteredDate).inDays < 7)
    return DateFormat("EEEE").format(date);
  if (DateTime.now().difference(filteredDate).inDays < 365)
    return DateFormat.MMMEd().format(date);

  return DateFormat.yMMMd().format(date);
}

String chatTime(final DateTime date) {
  final filteredDate = DateTime(date.year, date.month, date.day);
  if (DateTime.now().difference(filteredDate).inDays == 0)
    return DateFormat.jm().format(date);
  if (DateTime.now().difference(filteredDate).inDays == 1) return "Yesterday";
  if (DateTime.now().difference(filteredDate).inDays < 7)
    return DateFormat("EEEE").format(date);

  return DateFormat.yMd().format(date);
}

// this method remove duplicate messages and still main order
List<MessageModel> orderedSetForMessages(final List<MessageModel> messages) {
  final result = messages.toList();
  final messageIds = Set<String>();
  result.retainWhere((x) => messageIds.add(x.messageId));
  return result.toList();
}

// this method remove duplicate chats and still main order
List<ChatModel> orderedSetForChats(final List<ChatModel> chats) {
  final result = chats.toList();
  final chatIds = Set<String>();
  result.retainWhere((x) => chatIds.add(x.chatId));
  return result.toList();
}

// this method remove duplicate Files and still main order
List<File> orderedSetForFiles(final List<File> files) {
  final result = files.toList();
  final chatIds = Set<int>();
  result.retainWhere((x) => chatIds.add(x.lengthSync()));
  return result.toList();
}

// This function returns list of user connection

List<String> getConnections(Map<String, ConnectionStatus> data) {
  final List<String> connections = [];
// gets all the user identifier of the users am connected with in a Map.
  // The key is the userId while the value is the ConnectionStatus
  // users am connected with has ConnectionStatus to be equal to Connected

  for (final data in data.entries)
    if (data.value == ConnectionStatus.Connected) connections.add(data.key);

  return connections.toList();
}

// gets lastDoc for messages
DocumentSnapshot? getLastDoc(MessagesModel newMsg, MessagesModel oldMsg) {
  return oldMsg.messages.length > newMsg.messages.length
      ? oldMsg.lastDoc
      : newMsg.lastDoc;
}
