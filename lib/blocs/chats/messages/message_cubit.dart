import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/chat_utils.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageService messageService;

  MessageCubit(this.messageService) : super(MessageInitial());

  Future<void> fetchMessages(String chatId, String currentUserId) async {
    final result = await messageService.getOfflineMessages(
      chatId,
      currentUserId,
    );

    if (result.messages.isNotEmpty) {
      _updateMessagesReceipt(result, true);
    } else {
      final result = await messageService.getRecentMessages(chatId);
      _updateMessagesReceipt(result, true);
    }
  }

  Future<void> sendMessage(final String chatId, final MessageModel message,
      {bool isFreshMessage = true}) async {
    try {
      // isFreshMessage is true only when the message is sent by
      // the user for the first time. it is false if the message is resent
      // by the user after first failed attempt
      // if true, the UI is updated to show a message is being sent (Pending)
      if (isFreshMessage) _updateMessage(message);

      final result = await messageService.sendMessage(chatId, message);
      // update on message sent
      final newMessage = result.copyWith(newRecept: Receipt.Sent);
      _updateMessage(newMessage, oldMsg: message);
    } catch (e) {
      _onMessageFailed(message);
    }
  }

  // used to add new messages to the existing list of messages
  void updateNewMessages(final MessagesLoaded newMessageState) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final newMessages = newMessageState.messagesModel.messages.toList();
      List<MessageModel> oldMessages =
          currentState.messagesModel.messages.toList();

      final messages = orderedSetForMessages([...newMessages, ...oldMessages]);

      final lastDoc = getLastDoc(
        newMessageState.messagesModel,
        currentState.messagesModel,
      );

      _updateMessagesReceipt(
        MessagesModel(
          messages: messages,
          topMessageDate: newMessageState.messagesModel.topMessageDate,
          lastDoc: lastDoc,
        ),
        currentState.hasMore,
      );
    }
  }

  // used to add old messages to existing list of messages
  // used precisely when loading old chat messages
  void updateOldMessages(final MessagesLoaded oldMessageState) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final oldMessages = oldMessageState.messagesModel.messages.toList();
      final currentMessages = currentState.messagesModel.messages.toList();

      final totalMessages = [...currentMessages, ...oldMessages];

      _updateMessagesReceipt(
        MessagesModel(
          messages: totalMessages,
          topMessageDate: currentState.messagesModel.topMessageDate,
          lastDoc: oldMessageState.messagesModel.lastDoc,
        ),
        oldMessageState.hasMore,
      );
    }
  }

  // This method retrieves all failed sent messages and try to send them again

  void resendFailedMessages(final String chatId) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      List<MessageModel> failedMessages = [];

      final currentMessages = currentState.messagesModel.messages.toList();
      for (final msg in currentMessages.reversed.toList()) {
        if (msg.receipt == Receipt.Failed) {
          // get failed message
          final message = msg;
          final copiedMessage = message.copyWith(newRecept: Receipt.Pending);
          _updateMessage(copiedMessage, oldMsg: msg);
          failedMessages.add(copiedMessage);
        }
      }

      // start resending those failed messages
      for (final msg in failedMessages.toList()) {
        sendMessage(chatId, msg, isFreshMessage: false);
      }
    }
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

  void _updateMessage(final MessageModel message, {MessageModel? oldMsg}) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final oldMessages = currentState.messagesModel.messages.toList();
      if (oldMsg != null) oldMessages.remove(oldMsg);

      final newMessages = <MessageModel>[message, ...oldMessages.toList()];

      _updateMessagesReceipt(
        MessagesModel(
          messages: newMessages,
          lastDoc: currentState.messagesModel.lastDoc,
          topMessageDate: currentState.messagesModel.topMessageDate,
        ),
        currentState.hasMore,
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
            topMessageDate: currentState.messagesModel.topMessageDate,
          ),
          hasMore: currentState.hasMore,
        ),
      );
    }
  }

  // update receipt
  void _updateMessagesReceipt(final MessagesModel msgsModel, bool hasMore) {
    final topMessageDate =
        msgsModel.topMessageDate ?? DateTime(1970).toIso8601String();

    final messagesModel = MessagesModel(
      messages: msgsModel.messages.toList().map((e) {
        return e.copyWithUpdateReceipt(topMessageDate, e.receipt);
      }).toList(),
      lastDoc: msgsModel.lastDoc,
      topMessageDate: topMessageDate,
    );

    emit(MessagesLoaded(messagesModel: messagesModel, hasMore: hasMore));
  }
}
