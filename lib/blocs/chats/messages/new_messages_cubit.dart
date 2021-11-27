import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/app_utils.dart';
import 'message_state.dart';

class NewMessagesCubit extends Cubit<MessageState> {
  final MessageService messageService;

  NewMessagesCubit(this.messageService) : super(MessageInitial());

  StreamSubscription<MessagesModel?>? _subscription;

  Future<void> updateOnNewMessages(String chatId, String userId) async {
    try {
      _subscription?.cancel();
      _subscription =
          messageService.getNewMessages(chatId).listen((messagesModel) async {
        if (messagesModel != null) {
          // update the UI on new messages
          _update(messagesModel);

          // update the time of the last message seen by the user
          await messageService.setCurrentUserLastReadMessageId(
            chatId,
            userId,
            messagesModel.messages.first.sentDate!.toUtc().toIso8601String(),
          );
        }
      });
    } catch (e) {
      emptyMessages();
    }
  }

  void emptyMessages() {
    emit(MessagesLoaded(messagesModel: MessagesModel(messages: [])));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  // #######################################################################
  // #######################################################################
  // Helper Methods

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
    final messageModel = MessagesModel(messages: result, lastDoc: lastDoc);

    emit(MessagesLoaded(messagesModel: messageModel));
  }
}
