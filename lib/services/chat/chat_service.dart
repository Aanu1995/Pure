import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/chat/chat_model.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';

abstract class ChatService {
  const ChatService();

  Future<ChatsModel> getOfflineChats(String userId);
  Stream<ChatsModel?> getRealTimeChats(String userId,
      {int limit = GlobalUtils.messagesLimit});
  Stream<ChatsModel?> getLastRemoteMessage(
      String userId, DocumentSnapshot endDoc);
  Future<int> getUnReadMessageCount(String chatId, String userId);
}

class ChatServiceImp extends ChatService {
  final FirebaseFirestore? firestore;

  ChatServiceImp({this.firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _chatCollection = _firestore.collection(GlobalUtils.chatCollection);
    _receiptCollection = _firestore.collection(GlobalUtils.receiptCollection);
  }

  late FirebaseFirestore _firestore;
  late CollectionReference _chatCollection;
  late CollectionReference _receiptCollection;

  @override
  Future<ChatsModel> getOfflineChats(String userId) async {
    List<ChatModel> chats = [];
    DocumentSnapshot? firstDoc;
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
              .where("members", arrayContains: userId)
              .orderBy("updateDate", descending: true)
              .limit(GlobalUtils.cachedChatsLimit)
              .get(GetOptions(source: Source.cache))
          as QuerySnapshot<Map<String, dynamic>?>;

      if (querySnapshot.docs.isNotEmpty) {
        firstDoc = querySnapshot.docs.first;
        lastDoc = querySnapshot.docs.last;
        for (final result in querySnapshot.docs) {
          final data = result.data();
          if (data != null) {
            chats.add(ChatModel.fromMap(data));
          }
        }
      }
      return ChatsModel(chats: chats, firstDoc: firstDoc, lastDoc: lastDoc);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<ChatsModel?> getLastRemoteMessage(
      String userId, DocumentSnapshot endDoc) {
    try {
      return _chatCollection
          .where("members", arrayContains: userId)
          .orderBy("updateDate", descending: true)
          .limit(GlobalUtils.LastFetchedchatsLimit)
          .endBeforeDocument(endDoc)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<ChatModel> chats = [];
        DocumentSnapshot? lastDoc;

        if (querySnapshot.docs.isNotEmpty) {
          lastDoc = querySnapshot.docs.last;
          for (final result in querySnapshot.docs) {
            try {
              final data = result.data() as Map<String, dynamic>?;
              if (data != null) {
                chats.add(ChatModel.fromMap(data));
              }
            } catch (e) {
              log(e.toString());
            }
          }
        }

        return ChatsModel(chats: chats, lastDoc: lastDoc);
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Stream<ChatsModel?> getRealTimeChats(String userId,
      {int limit = GlobalUtils.messagesLimit}) {
    try {
      return _chatCollection
          .where("members", arrayContains: userId)
          .orderBy("updateDate", descending: true)
          .limit(GlobalUtils.chatsLimit)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<ChatModel> chats = [];
        DocumentSnapshot? lastDoc;

        if (querySnapshot.docs.isNotEmpty) {
          lastDoc = querySnapshot.docs.last;
          for (final result in querySnapshot.docs) {
            try {
              final data = result.data() as Map<String, dynamic>?;
              if (data != null) {
                chats.add(ChatModel.fromMap(data));
              }
            } catch (e) {
              log(e.toString());
            }
          }
        }
        return ChatsModel(chats: chats, lastDoc: lastDoc);
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<int> getUnReadMessageCount(String chatId, String userId) async {
    try {
      final result = await _receiptCollection
          .doc(chatId)
          .get()
          .timeout(Duration(seconds: 4));
      final data = result.data() as Map<String, dynamic>?;
      return data?[userId]["unreadCount"] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }
}