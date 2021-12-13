import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pure/model/chat/attachment_model.dart';

import '../../model/chat/message_model.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';
import '../remote_storage_service.dart';

abstract class MessageService {
  const MessageService();

  Future<MessagesModel> getOfflineMessages(String chatId, String currentUserId);
  Stream<MessagesModel?> getNewMessages(String chatId, String currentUserId);
  Future<MessagesModel> getRecentMessages(String chatId);
  Future<MessagesModel> loadMoreMessages(String chatId, DocumentSnapshot doc,
      {int limit = GlobalUtils.messagesLimit});
  Future<void> sendMessage(String chatId, final MessageModel message);
  Future<void> setCurrentUserLastReadMessageId(
      String chatId, String userId, String time);
}

class MessageServiceImp extends MessageService {
  final FirebaseFirestore? firestore;
  final RemoteStorage? remoteStorageImpl;

  MessageServiceImp({
    this.firestore,
    this.remoteStorageImpl,
    bool isPersistentEnabled = true,
  }) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _firestore.settings = Settings(persistenceEnabled: isPersistentEnabled);
    _chatCollection = _firestore.collection(GlobalUtils.chatCollection);
    _receiptCollection = _firestore.collection(GlobalUtils.receiptCollection);
    _firestoreNoPersistence = FirebaseFirestore.instance;
    _firestoreNoPersistence.settings = Settings(persistenceEnabled: false);
    _remoteStorage = remoteStorageImpl ?? RemoteStorageImpl();
  }

  late FirebaseFirestore _firestore;
  late FirebaseFirestore _firestoreNoPersistence;
  late CollectionReference _chatCollection;
  late CollectionReference _receiptCollection;
  late RemoteStorage _remoteStorage;

  @override
  Future<MessagesModel> getOfflineMessages(
      String chatId, String currentUserId) async {
    List<MessageModel> messages = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .get(GetOptions(source: Source.cache));

      final docSnap = await _receiptCollection.doc(chatId).get();
      final data = docSnap.data() as Map<String, dynamic>?;

      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;
        for (final data in querySnapshot.docs)
          messages.add(MessageModel.fromMap(data.data()));
      }
      return MessagesModel(
        messages: messages,
        lastDoc: lastDoc,
        topMessageDate: _getTopReadMessageDate(data, currentUserId),
      );
    } catch (e) {
      return MessagesModel(messages: []);
    }
  }

  // this fetches new messages for a user on every receipt update using the
  // user last seen message time
  String? topMessageDate;

  @override
  Stream<MessagesModel?> getNewMessages(String chatId, String currentUserId) {
    try {
      return _receiptCollection
          .doc(chatId)
          .snapshots()
          .asyncMap((docSnapshot) async {
        final data = docSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          // this will be null if user just connected with another user
          // or if the user just joined
          final lastSeenMessageDate =
              data[currentUserId]["lastSeen"] as String? ??
                  DateTime(1970).toIso8601String();

          String? newTopMessageDate =
              _getTopReadMessageDate(data, currentUserId);

          if (newTopMessageDate != null) {
            final msgModelResult =
                await _getNewMessagesFuture(chatId, lastSeenMessageDate);
            if (msgModelResult != null) {
              topMessageDate = newTopMessageDate;
              return _getMessageModel(msgModelResult, newTopMessageDate, data);
            }
          }
        }
        return null;
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<MessagesModel> getRecentMessages(String chatId) async {
    try {
      final colref = await _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .orderBy("sentDate", descending: true)
          .limit(GlobalUtils.messagesLimit)
          .get()
          .timeout(GlobalUtils.timeOutInDuration);

      List<MessageModel> messages = [];
      DocumentSnapshot? lastDoc;

      if (colref.docs.isNotEmpty) {
        lastDoc = colref.docs.last;
        for (final data in colref.docs) {
          try {
            messages.add(MessageModel.fromMap(data.data()));
          } catch (e) {
            log(e.toString());
          }
        }
      }
      return MessagesModel(messages: messages, lastDoc: lastDoc);
    } catch (e) {
      return MessagesModel(messages: []);
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
  Future<void> sendMessage(String chatId, final MessageModel message) async {
    try {
      if (message.attachments != null) {
        List<Attachment> attachments = [];

        for (final attachment in message.attachments!) {
          final photoURL = await _remoteStorage.uploadChatFile(
            chatId,
            attachment.localFile!,
            attachment.fileExtension,
          );

          if (photoURL != null) attachments.add(attachment.copyWith(photoURL));
        }
        await _sendMessage(chatId, message.copyWithAttachments(attachments));
      } else {
        await _sendMessage(chatId, message);
      }
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

  ///  Helper Methods
  /// ##################################################################
  ///

  Future<void> _sendMessage(String chatId, final MessageModel message) async {
    await _firestoreNoPersistence
        .collection(GlobalUtils.chatCollection)
        .doc(chatId)
        .collection(GlobalUtils.messageCollection)
        .doc(message.messageId)
        .set(message.toMap())
        .timeout(GlobalUtils.updateTimeOutInDuration);
  }

  MessagesModel _getMessageModel(final MessagesModel msgModel,
      String topMessageDate, final Map<String, dynamic>? data) {
    return MessagesModel(
      messages: msgModel.messages.toList(),
      topMessageDate: topMessageDate,
      lastDoc: msgModel.lastDoc,
    );
  }

  Future<MessagesModel?> _getNewMessagesFuture(
      String chatId, String lastSeenMsgDate,
      {int limit = GlobalUtils.messagesLimit}) async {
    try {
      final colref = await _chatCollection
          .doc(chatId)
          .collection(GlobalUtils.messageCollection)
          .where('sentDate', isGreaterThan: lastSeenMsgDate)
          .orderBy("sentDate", descending: true)
          .limit(limit)
          .get()
          .timeout(GlobalUtils.timeOutInDuration);

      List<MessageModel> messages = [];
      DocumentSnapshot? lastDoc;

      if (colref.docs.isNotEmpty) {
        lastDoc = colref.docs.last;
        for (final data in colref.docs) {
          try {
            messages.add(MessageModel.fromMap(data.data()));
          } catch (e) {
            log(e.toString());
          }
        }
      }
      return MessagesModel(messages: messages, lastDoc: lastDoc);
    } catch (e) {
      return null;
    }
  }

  String? _getTopReadMessageDate(
      final Map<String, dynamic>? data, String currentUserId) {
    data?.remove(currentUserId);
    if (data != null) {
      List<String> dates = [];
      final newData = data.values.toList();

      for (final map in newData) {
        dates.add(
            map["lastSeen"] as String? ?? DateTime(1970).toIso8601String());
      }

      dates.sort();
      final topDate = dates.last;
      return topDate;
    }
    return null;
  }
}
