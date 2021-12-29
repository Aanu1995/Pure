import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/chat_model.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../services/chat/chat_service.dart';
import '../../../../../utils/navigate.dart';
import '../../../../../utils/palette.dart';
import '../../../../widgets/avatar.dart';
import '../../../settings/profile/profile_screen.dart';
import '../../group/group_info_screen.dart';
import 'message_inbox_widget.dart';
import 'messages_body.dart';

class MessageAppBarTitle extends StatelessWidget {
  final String chatId;
  final PureUser receipient;
  final bool hasPresenceActivated;
  const MessageAppBarTitle({
    Key? key,
    required this.chatId,
    required this.receipient,
    this.hasPresenceActivated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewFullProfile(context, receipient),
      child: Row(
        children: [
          Avartar(
            size: 22,
            ringSize: 0.8,
            imageURL: receipient.photoURL,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipient.fullName,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.5,
                    fontFamily: Palette.sanFontFamily,
                    letterSpacing: 0.5,
                  ),
                ),
                if (hasPresenceActivated)
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
    );
  }

  void viewFullProfile(BuildContext context, PureUser user) {
    push(
      context: context,
      page: ProfileScreen(user: user, hideConnectionStatus: true),
    );
  }
}

class GroupMessageAppBarTitle extends StatefulWidget {
  final ChatModel chat;
  const GroupMessageAppBarTitle({Key? key, required this.chat})
      : super(key: key);

  @override
  State<GroupMessageAppBarTitle> createState() =>
      _GroupMessageAppBarTitleState();
}

class _GroupMessageAppBarTitleState extends State<GroupMessageAppBarTitle> {
  late ChatModel chat;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => viewGroupProfile(context),
      child: Row(
        children: [
          Avartar(size: 22, ringSize: 0.8, imageURL: chat.groupImage!),
          const SizedBox(width: 10.0),
          Text(
            chat.groupName!,
            maxLines: 1,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17.5,
              fontFamily: Palette.sanFontFamily,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> viewGroupProfile(BuildContext context) async {
    final state = BlocProvider.of<GroupCubit>(context).state;
    if (state is GroupMembers) {
      List<PureUser> members = state.members;

      Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => GroupChatCubit(ChatServiceImp())),
              BlocProvider(create: (_) => ParticipantCubit(ChatServiceImp())),
            ],
            child: GroupInfoScreen(
              chat: chat,
              participants: members,
              onChatChanged: (newChat) => setState(() => chat = newChat),
            ),
          );
        }),
      );
    }
  }
}

class MessageBody extends StatefulWidget {
  final String chatId;
  final String? receipientName; // only for One-to-One Chat
  const MessageBody({Key? key, required this.chatId, this.receipientName})
      : super(key: key);

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  final _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageCubit, MessageState>(
      listenWhen: (prev, current) =>
          prev is MessageInitial && current is MessagesLoaded,
      listener: (context, state) => context
          .read<NewMessagesCubit>()
          .updateOnNewMessages(widget.chatId, CurrentUser.currentUserId),
      child: Column(
        children: [
          // Messages
          Expanded(
            child: Messagesbody(
              chatId: widget.chatId,
              inputFocusNode: _inputFocusNode,
              firstName: widget.receipientName,
              onSentButtonPressed: (final message) =>
                  sendMessage(context, message),
            ),
          ),
          // Message Input Box
          MessageInputBox(
            chatId: widget.chatId,
            inputFocusNode: _inputFocusNode,
            onSentButtonPressed: (final message) =>
                sendMessage(context, message),
          )
        ],
      ),
    );
  }

  void sendMessage(final BuildContext context, final MessageModel message) {
    context.read<MessageCubit>().sendMessage(widget.chatId, message);
  }
}
