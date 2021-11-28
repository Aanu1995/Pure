import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/message_service.dart';
import '../../../../services/user_service.dart';
import 'widgets/message_screen_widget.dart';

class MessagesScreen extends StatelessWidget {
  final String chatId;
  final PureUser receipient;
  final bool hasPresenceActivated;
  const MessagesScreen({
    Key? key,
    required this.chatId,
    required this.receipient,
    this.hasPresenceActivated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => MessageCubit(MessageServiceImp())
            ..fetchMessages(chatId, CurrentUser.currentUserId),
        ),
        BlocProvider(create: (_) => NewMessagesCubit(MessageServiceImp())),
        BlocProvider(create: (_) => LoadMoreMessageCubit(MessageServiceImp())),
        if (!hasPresenceActivated)
          BlocProvider(
            create: (_) => UserPresenceCubit(UserServiceImpl())
              ..getUserPresence(receipient.id),
          ),
      ],
      child: _MessagesScreenExtension(
        chatId: chatId,
        receipient: receipient,
        hasPresenceActivated: hasPresenceActivated,
      ),
    );
  }
}

class _MessagesScreenExtension extends StatelessWidget {
  final String chatId;
  final PureUser receipient;
  final bool hasPresenceActivated;
  const _MessagesScreenExtension({
    Key? key,
    required this.chatId,
    required this.receipient,
    this.hasPresenceActivated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        updateUnReadMessageCount(context);
        return true;
      },
      child: Scaffold(
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
          title: MessageAppBarTitle(
            chatId: chatId,
            receipient: receipient,
            hasPresenceActivated: hasPresenceActivated,
          ),
        ),
        body: MessageBody(chatId: chatId, receipientName: receipient.firstName),
      ),
    );
  }

  void updateUnReadMessageCount(BuildContext context) {
    context
        .read<NewMessagesCubit>()
        .updateUnreadMessageCount(chatId, CurrentUser.currentUserId);
  }
}
