import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/bloc.dart';
import '../../../model/pure_user_model.dart';
import '../../widgets/bottom_bar.dart';
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
    fetchChats();
  }

  void fetchChats() {
    final chatState = context.read<ChatCubit>().state;
    if (chatState is ChatInitial)
      context.read<ChatCubit>().fetchChats(CurrentUser.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: const Text('Chats')),
      body: const ChatList(),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
