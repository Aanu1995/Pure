import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../repositories/push_notification.dart';
import '../../../../services/chat/message_service.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/message_screen_widget.dart';

class GroupChatMessageScreen extends StatefulWidget {
  final ChatModel chatModel;
  const GroupChatMessageScreen({Key? key, required this.chatModel})
      : super(key: key);

  @override
  State<GroupChatMessageScreen> createState() => _GroupChatMessageScreenState();
}

class _GroupChatMessageScreenState extends State<GroupChatMessageScreen> {
  @override
  void initState() {
    super.initState();
    // subscribe to notifification from this chat messages
    PushNotificationImpl.subscribeToTopic(widget.chatModel.chatId);
  }

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
        title: GroupMessageAppBarTitle(chat: widget.chatModel),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) => MessageCubit(MessageServiceImp())
              ..fetchMessages(
                  widget.chatModel.chatId, CurrentUser.currentUserId),
          ),
          BlocProvider(create: (_) => NewMessagesCubit(MessageServiceImp())),
          BlocProvider(
            create: (_) => LoadMoreMessageCubit(MessageServiceImp()),
          ),
        ],
        child: MessageBody(chatId: widget.chatModel.chatId, isGroupChat: true),
      ),
    );
  }
}
