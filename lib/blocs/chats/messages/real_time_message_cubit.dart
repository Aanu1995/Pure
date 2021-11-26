import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/exception.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'message_state.dart';

class RealTimeMessageCubit extends Cubit<MessageState> {
  final MessageService messageService;

  RealTimeMessageCubit(this.messageService) : super(MessageInitial());

  StreamSubscription<MessagesModel?>? _subscription;

  Future<void> fetchMessages(final String chatId, final String userId) async {
    try {
      _subscription?.cancel();
      _subscription = messageService
          .getRealTimeMessage(chatId, limit: 5)
          .listen((messagesModel) async {
        if (messagesModel != null) {
          _updateMessages(messagesModel.messages);
          // update the current user last message Id in the database
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

  void _updateMessages(final List<MessageModel> messages) {
    final currentState = state;
    List<MessageModel> oldMessages = [];

    if (currentState is MessagesLoaded) {
      oldMessages = currentState.messagesModel.messages.toList();
    }
    final result = orderedSetForMessages(
      [...messages.toList(), ...oldMessages],
    );

    emit(MessagesLoaded(messagesModel: MessagesModel(messages: result)));
  }
}

class LoadMoreMessageCubit extends Cubit<MessageState> {
  final MessageService messageService;

  LoadMoreMessageCubit(this.messageService) : super(MessageInitial());

  Future<void> loadMoreMessages(String chatId, DocumentSnapshot lastDoc) async {
    emit(LoadingMessages());

    try {
      final result = await messageService.loadMoreMessages(chatId, lastDoc);
      emit(
        MessagesLoaded(
          messagesModel: result,
          hasMore: _hasMore(result.messages),
        ),
      );
    } on NetworkException catch (e) {
      emit(MessagesFailed(e.message!));
    } on ServerException catch (e) {
      emit(MessagesFailed(e.message!));
    } catch (_) {
      emit(MessagesFailed(ErrorMessages.generalMessage2));
    }
  }

  bool _hasMore(final List<MessageModel> messages) {
    if (messages.isEmpty) {
      return false;
    }
    return messages.length % GlobalUtils.messagesLimit == 0;
  }
}
