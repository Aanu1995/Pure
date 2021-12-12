import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/chat/chat_service.dart';

class UnreadMessageCubit extends Cubit<int> {
  final ChatService chatService;
  UnreadMessageCubit(this.chatService) : super(0);

  StreamSubscription<int>? _subscription;

  Future<void> getUnreadMessageCounts(String chatId, String userId) async {
    _subscription = chatService
        .getUnReadMessageCount(chatId, userId)
        .listen((unreadMessagesCount) {
      emit(unreadMessagesCount);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
