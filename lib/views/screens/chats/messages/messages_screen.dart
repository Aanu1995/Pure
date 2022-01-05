import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../repositories/push_notification.dart';
import '../../../../services/chat/message_service.dart';
import '../../../../services/user_service.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/message_screen_widget.dart';

class MessagesScreen extends StatefulWidget {
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
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final messageServiceImpl = MessageServiceImp();

  @override
  void initState() {
    super.initState();
    // subscribe to notifification from this chat messages
    PushNotificationImpl.subscribeToTopic(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          chatId: widget.chatId,
          receipient: widget.receipient,
          hasPresenceActivated: widget.hasPresenceActivated,
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) => MessageCubit(messageServiceImpl)
              ..fetchMessages(widget.chatId, CurrentUser.currentUserId),
          ),
          BlocProvider(create: (_) => NewMessagesCubit(messageServiceImpl)),
          BlocProvider(create: (_) => LoadMoreMessageCubit(messageServiceImpl)),
          if (!widget.hasPresenceActivated)
            BlocProvider(
              create: (_) => UserPresenceCubit(UserServiceImpl())
                ..getUserPresence(widget.receipient.id),
            ),
        ],
        child: MessageBody(
          chatId: widget.chatId,
          receipientName: widget.receipient.firstName,
        ),
      ),
    );
  }
}
