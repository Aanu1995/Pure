import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/global_utils.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageService messageService;

  MessageCubit(this.messageService) : super(MessageInitial());

  Future<void> fetchMessages(String chatId, String currentUserId) async {
    try {
      final data =
          await messageService.getOfflineLastDates(chatId, currentUserId);
      final result = await messageService.getOfflineMessages(chatId);

      updateReceipt(
          result, receiptDate(data), data, true, result.firstDoc != null);
      fetchReceipts(chatId, currentUserId);
      if (result.firstDoc != null)
        fetchRemoteMessages(chatId, result.firstDoc!);
    } catch (e) {
      fetchReceipts(chatId, currentUserId);
      emit(MessagesLoaded(messagesModel: MessagesModel(messages: [])));
    }
  }

  StreamSubscription<MessagesModel?>? _subscription;
  // This is used to get recent messages to the last doc
  Future<void> fetchRemoteMessages(
      String chatId, DocumentSnapshot lastDoc) async {
    try {
      _subscription?.cancel();
      _subscription = messageService
          .getLastRemoteMessage(chatId, lastDoc)
          .listen((messagesModel) {
        if (messagesModel != null) {
          _syncMessages(messagesModel);
          _subscription?.cancel();
          _subscription = null;
        }
      });
    } catch (e) {
      emit(MessagesLoaded(messagesModel: MessagesModel(messages: [])));
    }
  }

  Future<void> sendTextMessageOnly(
      final String chatId, final MessageModel message,
      {bool isOnline = false, bool update = true}) async {
    if (update) {
      _updateMessage(message, null, null);
    }
    try {
      await messageService.sendTextMessageOnly(chatId, message);
    } catch (e) {
      _onMessageFailed(message);
    }
  }

  void updateNewMessages(final MessagesLoaded newMessageState) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final newMessages = newMessageState.messagesModel.messages.toList();
      List<MessageModel> oldMessages =
          currentState.messagesModel.messages.toList();

      final totalMessages =
          orderedSetForMessages([...newMessages, ...oldMessages]);

      final lastDoc = oldMessages.length > newMessages.length
          ? currentState.messagesModel.lastDoc
          : newMessageState.messagesModel.lastDoc;

      updateReceipt(
        MessagesModel(
          messages: totalMessages,
          lastDoc: lastDoc,
        ),
        currentState.topMessageId,
        currentState.messageIds,
        currentState.hasMore,
        true,
      );
    }
  }

  void updateOldMessages(final MessagesLoaded oldMessageState) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final oldMessages = oldMessageState.messagesModel.messages.toList();
      final currentMessages = currentState.messagesModel.messages.toList();

      final totalMessages = [...currentMessages, ...oldMessages];

      updateReceipt(
        MessagesModel(
          messages: totalMessages,
          lastDoc: oldMessageState.messagesModel.lastDoc,
        ),
        currentState.topMessageId,
        currentState.messageIds,
        oldMessageState.hasMore,
        true,
      );
    }
  }

  // This method retrieves all failed messages and try to send them again
  void resendMessages(final String chatId) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      List<MessageModel> failedMessages = [];
      // get all failed messages
      final currentMessages = currentState.messagesModel.messages.toList();
      for (final msg in currentMessages.reversed.toList()) {
        if (msg.receipt == Receipt.Failed) {
          final message = msg;
          final copiedMessage = message.copyWith(newRecept: Receipt.Pending);
          _updateMessage(
            copiedMessage,
            currentState.topMessageId,
            currentState.messageIds,
          );
          failedMessages.add(copiedMessage);
        }
      }

      // start resending those messages
      for (final msg in failedMessages.toList()) {
        sendTextMessageOnly(chatId, msg, update: false);
      }
    }
  }

  StreamSubscription<Map<String, dynamic>?>? _receiptSubscription;

  // This is used to get the message Ids of the user
  Future<void> fetchReceipts(String chatId, String currentUserId) async {
    _receiptSubscription?.cancel();
    _receiptSubscription =
        messageService.getLastDatebyUsers(chatId, currentUserId).listen((data) {
      if (data != null) {
        // get state
        final currentState = state;
        if (currentState is MessagesLoaded) {
          updateReceipt(
            currentState.messagesModel,
            receiptDate(data),
            data,
            currentState.hasMore,
            currentState.isListening,
          );
        }
      }
    });
  }

  @override
  Future<void> close() {
    _receiptSubscription?.cancel();
    _subscription?.cancel();
    return super.close();
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

  void _syncMessages(final MessagesModel newMessagesModel) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      if (newMessagesModel.messages.length >=
          GlobalUtils.LastFetchedMessagesLimit) {
        updateReceipt(
          newMessagesModel,
          currentState.topMessageId,
          currentState.messageIds,
          currentState.hasMore,
          false,
        );
      } else {
        final newMessages = <MessageModel>[
          ...newMessagesModel.messages.toList(),
          ...currentState.messagesModel.messages.toList()
        ];

        final msgsModel = MessagesModel(
          messages: newMessages,
          lastDoc: currentState.messagesModel.lastDoc,
        );
        updateReceipt(
          msgsModel,
          currentState.topMessageId,
          currentState.messageIds,
          currentState.hasMore,
          false,
        );
      }
    }
  }

  void _updateMessage(final MessageModel message, String? topMsgId,
      Map<String, dynamic>? msgIds) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final newMessages = <MessageModel>[
        message,
        ...currentState.messagesModel.messages.toList()
      ];

      updateReceipt(
        MessagesModel(
          messages: newMessages,
          lastDoc: currentState.messagesModel.lastDoc,
        ),
        topMsgId ?? currentState.topMessageId,
        msgIds ?? currentState.messageIds,
        currentState.hasMore,
        true,
      );
    }
  }

  void _onMessageFailed(final MessageModel message) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      List<MessageModel> messages =
          currentState.messagesModel.messages.toList();

      final index =
          messages.indexWhere((msg) => msg.messageId == message.messageId);
      messages.removeWhere((msg) => msg.messageId == message.messageId);
      messages.insert(index, message.copyWith());
      emit(
        MessagesLoaded(
          messagesModel: MessagesModel(
            messages: messages,
            lastDoc: currentState.messagesModel.lastDoc,
          ),
          topMessageId: currentState.topMessageId,
          messageIds: currentState.messageIds,
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  String? receiptDate(final Map<String, dynamic>? data) {
    if (data != null) {
      List<String> dates = [];
      final newData = data.values.toList();

      for (final map in newData) {
        dates.add(map["lastSeen"] as String);
      }

      dates.sort();
      final topDate = dates.last;
      return topDate;
    }
    return null;
  }

  // update receipt
  void updateReceipt(final MessagesModel msgsModel, final String? topMessageId,
      final Map<String, dynamic>? messageIds, bool hasMore, bool isListening) {
    MessagesModel messagesModel = msgsModel;

    if (topMessageId != null) {
      messagesModel = MessagesModel(
        messages: msgsModel.messages
            .toList()
            .map((e) => e.copyWithUpdateReceipt(topMessageId))
            .toList(),
        firstDoc: msgsModel.firstDoc,
        lastDoc: msgsModel.lastDoc,
      );
    }

    emit(
      MessagesLoaded(
        messagesModel: messagesModel,
        topMessageId: topMessageId,
        messageIds: messageIds,
        hasMore: hasMore,
        isListening: isListening,
      ),
    );
  }
}
