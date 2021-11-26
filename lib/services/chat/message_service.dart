import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/chat/message_model.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';

abstract class MessageService {
  const MessageService();

  Future<MessagesModel> getOfflineMessages(String chatId);
  Future<Map<String, dynamic>?> getOfflineLastDates(
      String chatId, String currentUserId);
  Stream<MessagesModel?> getRealTimeMessage(String chatId,
      {int limit = GlobalUtils.messagesLimit});
  Future<MessagesModel> loadMoreMessages(String chatId, DocumentSnapshot doc,
      {int limit = GlobalUtils.messagesLimit});
  Future<void> sendTextMessageOnly(String chatId, final MessageModel message);
  Stream<MessagesModel?> getLastRemoteMessage(
      String chatId, DocumentSnapshot endDoc);
  Future<void> setCurrentUserLastReadMessageId(
      String chatId, String userId, String time);
  Stream<Map<String, dynamic>?> getLastDatebyUsers(
      String chatId, String currentUserId);
}

class MessageServiceImp extends MessageService {
  final FirebaseFirestore? firestore;

  MessageServiceImp({this.firestore, bool isPersistentEnabled = true}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _firestore.settings = Settings(persistenceEnabled: isPersistentEnabled);
    _chatCollection = _firestore.collection(GlobalUtils.chatCollection);
    _receiptCollection = _firestore.collection(GlobalUtils.receiptCollection);
    _firestoreNoPersistence = FirebaseFirestore.instance;
    _firestoreNoPersistence.settings = Settings(persistenceEnabled: false);
  }

  late FirebaseFirestore _firestore;
  late FirebaseFirestore _firestoreNoPersistence;
  late CollectionReference _chatCollection;
  late CollectionReference _receiptCollection;

  @override
  Future<MessagesModel> getOfflineMessages(String chatId) async {
    List<MessageModel> messages = [];
    DocumentSnapshot? firstDoc;
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .limit(GlobalUtils.cachedMessagesLimit)
          .get(GetOptions(source: Source.cache));

      if (querySnapshot.docs.isNotEmpty) {
        firstDoc = querySnapshot.docs.first;
        lastDoc = querySnapshot.docs.last;
        for (final data in querySnapshot.docs)
          messages.add(MessageModel.fromMap(data.data()));
      }
      return MessagesModel(
        messages: messages,
        firstDoc: firstDoc,
        lastDoc: lastDoc,
      );
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<Map<String, dynamic>?> getOfflineLastDates(
      String chatId, String currentUserId) async {
    final docSnap = await _receiptCollection.doc(chatId).get();
    final data = docSnap.data() as Map<String, dynamic>?;
    data?.remove(currentUserId);
    return (data == null || data.isEmpty) ? null : data;
  }

  @override
  Stream<MessagesModel?> getRealTimeMessage(String chatId,
      {int limit = GlobalUtils.messagesLimit}) {
    try {
      return _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<MessageModel> messages = [];
        DocumentSnapshot? lastDoc;

        if (querySnapshot.docs.isNotEmpty) {
          lastDoc = querySnapshot.docs.last;
          for (final data in querySnapshot.docs) {
            try {
              messages.add(MessageModel.fromMap(data.data()));
            } catch (e) {
              log(e.toString());
            }
          }
        }

        return MessagesModel(messages: messages, lastDoc: lastDoc);
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Stream<MessagesModel?> getLastRemoteMessage(
      String chatId, DocumentSnapshot endDoc) {
    try {
      return _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .limit(GlobalUtils.LastFetchedMessagesLimit)
          .endBeforeDocument(endDoc)
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<MessageModel> messages = [];

        if (querySnapshot.docs.isNotEmpty) {
          for (final data in querySnapshot.docs) {
            try {
              messages.add(MessageModel.fromMap(data.data()));
            } catch (e) {
              log(e.toString());
            }
          }
        }

        return MessagesModel(messages: messages);
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Future<MessagesModel> loadMoreMessages(String chatId, DocumentSnapshot doc,
      {int limit = GlobalUtils.messagesLimit}) async {
    List<MessageModel> messages = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .startAfterDocument(doc)
          .limit(limit)
          .get()
          .timeout(GlobalUtils.timeOutInDuration);

      // gets last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;
        for (final data in querySnapshot.docs)
          messages.add(MessageModel.fromMap(data.data()));
      }

      return MessagesModel(messages: messages, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  // send text message only
  @override
  Future<void> sendTextMessageOnly(
      String chatId, final MessageModel message) async {
    try {
      await _firestoreNoPersistence
          .collection(GlobalUtils.chatCollection)
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .doc(message.messageId)
          .set(message.toMap())
          .timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> setCurrentUserLastReadMessageId(
      String chatId, String userId, String time) async {
    try {
      final data = {"lastSeen": time, "unreadCount": 0};
      await _receiptCollection.doc(chatId).set(
        {userId: data},
        SetOptions(merge: true),
      ).timeout(GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<Map<String, dynamic>?> getLastDatebyUsers(
      String chatId, String currentUserId) {
    try {
      return _receiptCollection
          .doc(chatId)
          .snapshots()
          .asyncMap((docSnapshot) async {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        data?.remove(currentUserId);
        return (data == null || data.isEmpty) ? null : data;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }
}
