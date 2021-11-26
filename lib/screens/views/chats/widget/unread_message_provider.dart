import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/chats/chats/unread_message_cubit.dart';
import '../../../../services/chat/chat_service.dart';

class UnreadMessageProvider extends StatelessWidget {
  final Widget child;
  const UnreadMessageProvider({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => UnreadMessageCubit(ChatServiceImp()),
      child: child,
    );
  }
}
