import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/message_service.dart';
import 'widgets/message_screen_widget.dart';

class GroupChatMessageScreen extends StatelessWidget {
  final ChatModel chatModel;
  const GroupChatMessageScreen({Key? key, required this.chatModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => MessageCubit(MessageServiceImp())
            ..fetchMessages(chatModel.chatId, CurrentUser.currentUserId),
        ),
        BlocProvider(create: (_) => NewMessagesCubit(MessageServiceImp())),
        BlocProvider(create: (_) => LoadMoreMessageCubit(MessageServiceImp())),
      ],
      child: _GroupChatMessageScreenExtension(chatModel: chatModel),
    );
  }
}

class _GroupChatMessageScreenExtension extends StatelessWidget {
  final ChatModel chatModel;
  const _GroupChatMessageScreenExtension({Key? key, required this.chatModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leadingWidth: 40.0,
        elevation: 1.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: BackButton(
            color: Theme.of(context).colorScheme.primaryVariant,
          ),
        ),
        title: GroupMessageAppBarTitle(chat: chatModel),
      ),
      body: MessageBody(chatId: chatModel.chatId),
    );
  }
}
