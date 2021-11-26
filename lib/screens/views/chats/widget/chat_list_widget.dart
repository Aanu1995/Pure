import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/pure_user_model.dart';
import '../../../widgets/progress_indicator.dart';
import '../../../widgets/user_profile_provider.dart';
import '../../connections/widgets/message_widget.dart';
import 'one_to_one_card.dart';
import 'unread_message_provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatsLoaded) {
          final chats = state.chatsModel.chats;
          if (chats.isEmpty)
            return MessageDisplay(
              fontSize: 20.0,
              title: "No Chats here yet...",
              description: "Start converation with your connections now",
              buttonTitle: "",
            );
          else
            return ListView.custom(
              controller: _controller,
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final chat = chats[index];
                  final userId =
                      chat.getOtherMember(CurrentUser.currentUserId)!;
                  return KeepAlive(
                    key: ValueKey<String>(chat.chatId),
                    keepAlive: true,
                    child: ProfileProvider(
                      userId: userId,
                      child: UnreadMessageProvider(
                        child: OneToOneCard(
                          key: ValueKey(chat.chatId),
                          userId: userId,
                          chat: chat,
                          showSeparator: index < (chats.length - 1),
                        ),
                      ),
                    ),
                  );
                },
                childCount: chats.length,
                findChildIndexCallback: (Key key) {
                  final ValueKey<String> valueKey = key as ValueKey<String>;
                  final String data = valueKey.value;
                  return chats.map((e) => e.chatId).toList().indexOf(data);
                },
              ),
            );
        }
        return const CustomProgressIndicator();
      },
    );
  }
}
