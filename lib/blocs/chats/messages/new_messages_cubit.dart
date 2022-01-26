import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/chat_utils.dart';
import 'message_state.dart';

class NewMessagesCubit extends Cubit<MessageState> {
  final MessageService messageService;

  NewMessagesCubit(this.messageService) : super(MessageInitial());

  StreamSubscription<MessagesModel?>? _subscription;

  Future<void> updateOnNewMessages(String chatId, String userId) async {
    try {
      _subscription?.cancel();
      _subscription = messageService
          .getNewMessages(chatId, userId)
          .listen((messagesModel) async {
        if (messagesModel != null) {
          // update the UI on new messages
          _update(messagesModel);

          if (messagesModel.shouldUpdateReceipt) {
            _updateTheLastMessageReceipt(chatId, userId, messagesModel);
          }
        }
      });
    } catch (e) {}
  }

  void emptyMessages() {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(
        MessagesLoaded(
          messagesModel: MessagesModel(
            messages: [],
            topMessageDate: currentState.messagesModel.topMessageDate,
            lastDoc: currentState.messagesModel.lastDoc,
          ),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

  Future<void> _updateTheLastMessageReceipt(
      String chatId, String userId, MessagesModel msgModel) async {
    if (msgModel.messages.isNotEmpty) {
      await messageService.setCurrentUserLastReadMessageId(
        chatId,
        userId,
        msgModel.messages.first.sentDate!.toUtc().toIso8601String(),
      );
    }
  }

  void _update(final MessagesModel messagesModel) {
    final currentState = state;

    List<MessageModel> oldMessages = [];
    final List<MessageModel> newMessages = messagesModel.messages.toList();
    DocumentSnapshot? lastDoc = messagesModel.lastDoc;

    if (currentState is MessagesLoaded) {
      oldMessages = currentState.messagesModel.messages.toList();
      lastDoc = getLastDoc(messagesModel, currentState.messagesModel);
    }

    final result = orderedSetForMessages([...newMessages, ...oldMessages]);
    final messageModel = MessagesModel(
      messages: result,
      topMessageDate: messagesModel.topMessageDate,
      lastDoc: lastDoc,
    );

    emit(MessagesLoaded(messagesModel: messageModel));
  }
}
