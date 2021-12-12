import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat/message_model.dart';
import '../../../services/chat/message_service.dart';
import '../../../utils/exception.dart';
import '../../../utils/global_utils.dart';
import '../../../utils/request_messages.dart';
import 'message_state.dart';

class LoadMoreMessageCubit extends Cubit<MessageState> {
  final MessageService messageService;

  LoadMoreMessageCubit(this.messageService) : super(MessageInitial());

  Future<void> loadMoreMessages(String chatId, DocumentSnapshot lastDoc) async {
    emit(LoadingMessages());

    try {
      final result = await messageService.loadMoreMessages(chatId, lastDoc);
      final msgModel = MessagesLoaded(
        messagesModel: result,
        hasMore: _hasMore(result.messages),
      );

      emit(msgModel);
    } on NetworkException catch (e) {
      emit(MessagesFailed(e.message!));
    } on ServerException catch (e) {
      emit(MessagesFailed(e.message!));
    } catch (_) {
      emit(MessagesFailed(ErrorMessages.generalMessage2));
    }
  }

  bool _hasMore(final List<MessageModel> messages) {
    if (messages.isEmpty) return false;

    return messages.length % GlobalUtils.messagesLimit == 0;
  }
}
