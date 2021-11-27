import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/utils/app_theme.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/message_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/message_service.dart';
import '../../../../services/user_service.dart';
import '../../../widgets/avatar.dart';
import 'widgets/message_inbox_widget.dart';
import 'widgets/messages_body.dart';

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
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (_) => MessageCubit(MessageServiceImp())
            ..fetchMessages(
              widget.chatId,
              CurrentUser.currentUserId,
            ),
        ),
        BlocProvider(create: (_) => RealTimeMessageCubit(MessageServiceImp())),
        BlocProvider(create: (_) => LoadMoreMessageCubit(MessageServiceImp())),
        if (!widget.hasPresenceActivated)
          BlocProvider(
            create: (_) => UserPresenceCubit(UserServiceImpl())
              ..getUserPresence(widget.receipient.id),
          ),
      ],
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
          title: Row(
            children: [
              Avartar(
                size: 22,
                ringSize: 0.8,
                imageURL: widget.receipient.photoURL,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.receipient.fullName,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17.5,
                        fontFamily: Palette.sanFontFamily,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.hasPresenceActivated)
                      BlocBuilder<UserPresenceCubit, UserPresenceState>(
                        builder: (context, state) {
                          final status = state is UserPresenceSuccess &&
                              state.presence.isOnline;
                          if (status)
                            return Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                "Online",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryVariant
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13.0,
                                  fontFamily: Palette.sanFontFamily,
                                  letterSpacing: 0.25,
                                ),
                              ),
                            );
                          return Offstage();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: _MessageBody(
          chatId: widget.chatId,
          receipientName: widget.receipient.firstName,
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  final String chatId;
  final String receipientName;
  const _MessageBody(
      {Key? key, required this.chatId, required this.receipientName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageCubit, MessageState>(
      listenWhen: (prev, current) =>
          current is MessagesLoaded && current.isListening == false,
      listener: (context, state) =>
          context.read<RealTimeMessageCubit>().fetchMessages(
                chatId,
                CurrentUser.currentUserId,
              ),
      child: Column(
        children: [
          // Messages
          Expanded(
            child: Messagesbody(
              chatId: chatId,
              firstName: receipientName,
              onSentButtonPressed: (final message) =>
                  sendMessage(context, message),
            ),
          ),
          // Message Input Box
          AnimatedPadding(
            duration: Duration(milliseconds: 300),
            curve: Curves.decelerate,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MessageInputBox(
              chatId: chatId,
              onSentButtonPressed: (final message) =>
                  sendMessage(context, message),
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(final BuildContext context, final MessageModel message) {
    context.read<MessageCubit>().sendTextMessageOnly(chatId, message);
  }
}
