import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pure/model/chat/message_model.dart';
import 'package:pure/services/chat/message_service.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../model/chat/chat_model.dart';
import '../../model/pure_user_model.dart';
import '../../utils/exception.dart';
import '../../utils/global_utils.dart';
import '../../utils/request_messages.dart';
import '../remote_storage_service.dart';
import '../user_service.dart';

abstract class ChatService {
  const ChatService();

  Future<ChatModel> createGroupChat(final ChatModel chatModel,
      {File? groupImage});
  Future<void> updateGroupChat(String chatId, Map<String, dynamic> data);
  Future<void> addNewParticipants(String chatId, List<String> newMembers);
  Future<void> removeParticipant(
      String chatId, MessageModel message, String memberId);
  Future<void> addAdmin(String chatId, String memberId);
  Future<void> removeAdmin(String chatId, String memberId);
  Future<String> updateGroupImage(String chatId, File file);
  Future<ChatsModel> getOfflineChats(String userId);
  Stream<ChatsModel?> getRealTimeChats(String userId);
  Stream<ChatsModel?> getLastRemoteMessage(
      String userId, DocumentSnapshot endDoc);
  Stream<int> getUnReadMessageCount(String chatId, String userId);
  Stream<int> getUnReadChatCount(String userId);
  Future<ChatsModel> loadMoreChats(String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.messagesLimit});
  Stream<List<PureUser>?> getGroupMembersProfile(List<String> userIds);
}

class ChatServiceImp extends ChatService {
  final FirebaseFirestore? firestore;
  final RemoteStorage? remoteStorageImpl;
  final UserService? userService;
  final MessageService? messageService;

  ChatServiceImp(
      {this.firestore,
      this.remoteStorageImpl,
      this.userService,
      this.messageService}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _chatCollection = _firestore.collection(GlobalUtils.chatCollection);
    _receiptCollection = _firestore.collection(GlobalUtils.receiptCollection);
    _remoteStorage = remoteStorageImpl ?? RemoteStorageImpl();
    _userService = userService ?? UserServiceImpl();
    _messageService = messageService ?? MessageServiceImp();
  }

  late FirebaseFirestore _firestore;
  late CollectionReference _chatCollection;
  late CollectionReference _receiptCollection;
  late RemoteStorage _remoteStorage;
  late UserService _userService;
  late MessageService _messageService;

  Future<ChatModel> createGroupChat(final ChatModel chatModel,
      {File? groupImage}) async {
    String? groupImageURL;
    try {
      if (groupImage != null) {
        // upload image to storage
        groupImageURL = await _remoteStorage.uploadProfileImage(
          chatModel.chatId,
          groupImage,
        );
      }

      final groupChat = chatModel.copyWith(image: groupImageURL ?? "");

      await _chatCollection
          .doc(groupChat.chatId)
          .set(groupChat.toMap())
          .timeout(GlobalUtils.timeOutInDuration);
      return groupChat;
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  Future<void> updateGroupChat(String chatId, Map<String, dynamic> data) async {
    try {
      await _chatCollection
          .doc(chatId)
          .update(data)
          .timeout(GlobalUtils.updateTimeOutInDuration);
      ;
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  Future<String> updateGroupImage(String chatId, File file) async {
    try {
      final groupImageURL =
          await _remoteStorage.uploadProfileImage(chatId, file);
      if (groupImageURL != null) {
        await updateGroupChat(chatId, ChatModel.toGroupImageMap(groupImageURL));
        return groupImageURL;
      } else {
        throw ServerException(message: ErrorMessages.generalMessage2);
      }
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> addNewParticipants(
      String chatId, List<String> newMembers) async {
    try {
      await _chatCollection
          .doc(chatId)
          .update({"members": FieldValue.arrayUnion(newMembers)}).timeout(
              GlobalUtils.updateTimeOutInDuration);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> removeParticipant(
      String chatId, MessageModel message, String memberId) async {
    try {
      await _chatCollection.doc(chatId).update({
        "members": FieldValue.arrayRemove(<String>[memberId]),
        "admins": FieldValue.arrayRemove(<String>[memberId])
      }).timeout(GlobalUtils.updateTimeOutInDuration);
      // delete the participant receipt
      await _receiptCollection
          .doc(chatId)
          .update({memberId: FieldValue.delete()});
      await _messageService.sendMessage(chatId, message);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Future<void> addAdmin(String chatId, String memberId) async {
    await _chatCollection.doc(chatId).update({
      "admins": FieldValue.arrayUnion(<String>[memberId])
    });
  }

  @override
  Future<void> removeAdmin(String chatId, String memberId) async {
    await _chatCollection.doc(chatId).update({
      "admins": FieldValue.arrayRemove(<String>[memberId])
    });
  }

  @override
  Future<ChatsModel> getOfflineChats(String userId) async {
    List<ChatModel> chats = [];
    DocumentSnapshot? firstDoc;
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
              .where("members", arrayContains: userId)
              .orderBy("updateDate", descending: true)
              //   .limit(GlobalUtils.cachedChatsLimit)
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
  Stream<ChatsModel?> getRealTimeChats(String userId) {
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

  @override
  Stream<int> getUnReadMessageCount(String chatId, String userId) {
    try {
      return _receiptCollection.doc(chatId).snapshots().asyncMap((querySnap) {
        final data = querySnap.data() as Map<String, dynamic>?;
        return data?[userId]["unreadCount"] as int? ?? 0;
      });
    } catch (e) {
      return Stream.value(0);
    }
  }

  @override
  Future<ChatsModel> loadMoreChats(String userId, DocumentSnapshot doc,
      {int limit = GlobalUtils.messagesLimit}) async {
    List<ChatModel> chats = [];
    DocumentSnapshot? lastDoc;

    try {
      final querySnapshot = await _chatCollection
              .where("members", arrayContains: userId)
              .orderBy("updateDate", descending: true)
              .startAfterDocument(doc)
              .limit(limit)
              .get()
              .timeout(GlobalUtils.timeOutInDuration)
          as QuerySnapshot<Map<String, dynamic>?>;

      if (querySnapshot.docs.isNotEmpty) {
        lastDoc = querySnapshot.docs.last;

        for (final result in querySnapshot.docs) {
          final data = result.data();
          if (data != null) {
            chats.add(ChatModel.fromMap(data));
          }
        }
      }
      return ChatsModel(chats: chats, lastDoc: lastDoc);
    } on TimeoutException catch (_) {
      throw ServerException(message: ErrorMessages.timeoutMessage);
    } catch (e) {
      throw ServerException(message: ErrorMessages.generalMessage2);
    }
  }

  @override
  Stream<List<PureUser>?> getGroupMembersProfile(List<String> userIds) {
    try {
      return _userService.getGroupMember(userIds.first).combineLatestAll(userIds
          .getRange(1, userIds.length)
          .toList()
          .map((e) => _userService.getGroupMember(e)));
    } catch (e) {
      return Stream.value(null);
    }
  }

  @override
  Stream<int> getUnReadChatCount(String userId) {
    try {
      return _receiptCollection
          .where("$userId.unreadCount", isGreaterThan: 0)
          .snapshots()
          .map((querySnap) => querySnap.docs.length);
    } catch (e) {
      return Stream.value(0);
    }
  }
}
