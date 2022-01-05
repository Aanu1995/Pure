import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bloc.dart';
import '../../../model/pure_user_model.dart';
import '../../../services/chat/chat_service.dart';
import '../../../services/search_service.dart';
import '../../../utils/navigate.dart';
import 'group/search_friend_chat.dart';
import 'widget/chat_list_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().fetchChats(CurrentUser.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoadMoreChatsCubit(ChatServiceImp()),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('Chats'),
          actions: [
            TextButton(
              onPressed: () => pushToCreateNewGroupScreen(),
              child: Text(
                "New Group",
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.05,
                ),
              ),
            ),
          ],
        ),
        body: ChatList(),
      ),
    );
  }

  Future<void> pushToCreateNewGroupScreen() async {
    push(
      context: context,
      rootNavigator: true,
      page: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GroupCubit(ChatServiceImp())),
          BlocProvider(create: (_) => SearchFriendBloc(SearchServiceImpl())),
        ],
        child: SearchFriendChat(),
      ),
    );
  }
}
