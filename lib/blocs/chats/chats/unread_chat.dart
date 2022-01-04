import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/chat/chat_service.dart';

class UnReadChatCubit extends Cubit<int> {
  final ChatService chatService;
  UnReadChatCubit(this.chatService) : super(0);

  StreamSubscription<int?>? _subscription;

  Future<void> getUnreadMessageCounts(String userId) async {
    _subscription?.cancel();

    _subscription =
        chatService.getUnReadChatCount(userId).listen((unreadChatCount) {
      emit(unreadChatCount);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
