import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../repositories/push_notification.dart';
import '../../../../services/chat/message_service.dart';
import '../../../../services/user_service.dart';
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
  @override
  void initState() {
    super.initState();
    // subscribe to notifification from this chat messages
    PushNotificationImpl.subscribeToTopic(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => MessageCubit(MessageServiceImp())
            ..fetchMessages(widget.chatId, CurrentUser.currentUserId),
        ),
        BlocProvider(create: (_) => NewMessagesCubit(MessageServiceImp())),
        BlocProvider(create: (_) => LoadMoreMessageCubit(MessageServiceImp())),
        if (!widget.hasPresenceActivated)
          BlocProvider(
            create: (_) => UserPresenceCubit(UserServiceImpl())
              ..getUserPresence(widget.receipient.id),
          ),
      ],
      child: _MessagesScreenExtension(
        chatId: widget.chatId,
        receipient: widget.receipient,
        hasPresenceActivated: widget.hasPresenceActivated,
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
        title: MessageAppBarTitle(
          chatId: chatId,
          receipient: receipient,
          hasPresenceActivated: hasPresenceActivated,
        ),
      ),
      bottomSheet: Container(
        color: Colors.red,
        height: 300,
        width: 1.sw,
      ),
      body: MessageBody(chatId: chatId, receipientName: receipient.firstName),
    );
  }
}
