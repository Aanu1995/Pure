import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/chat/chat_service.dart';

class UnreadMessageCubit extends Cubit<int> {
  final ChatService chatService;
  UnreadMessageCubit(this.chatService) : super(0);

  Future<void> getUnreadMessageCounts(String chatId, String userId) async {
    try {
      final result = await chatService.getUnReadMessageCount(chatId, userId);
      emit(result);
    } catch (e) {
      log("error");
    }
  }
}
