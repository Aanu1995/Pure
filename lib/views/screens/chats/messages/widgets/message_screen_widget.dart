import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/chat_utils.dart';
import '../../../../widgets/editable_text_controller.dart';
import 'message_inbox_widget.dart';
import 'messages_body.dart';
import 'tagged_user_profile.dart';

class MessageBody extends StatefulWidget {
  final String chatId;
  final String? receipientName; // only for One-to-One Chat
  final bool isGroupChat;
  const MessageBody({
    Key? key,
    required this.chatId,
    this.receipientName,
    this.isGroupChat = false,
  }) : super(key: key);

  @override
  State<MessageBody> createState() => _MessageBodyState();
}

class _MessageBodyState extends State<MessageBody> {
  final _inputFocusNode = FocusNode();
  final _userTaggedNotifier = ValueNotifier<String?>(null);
  TextEditingController _inputController = TextEditingController();

  final message = "You can't send messages to this group because you're "
      "no longer a participant.";

  @override
  void initState() {
    super.initState();
    if (widget.receipientName == null) {
      _inputController = EditableTextController();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _userTaggedNotifier.dispose();
    _inputController.dispose();
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                Messagesbody(
                  chatId: widget.chatId,
                  inputFocusNode: _inputFocusNode,
                  firstName: widget.receipientName,
                  onSentButtonPressed: (final message) =>
                      sendMessage(context, message),
                ),
                if (widget.isGroupChat)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: BlocBuilder<GroupCubit, GroupState>(
                      builder: (context, state) {
                        if (state is GroupMembers) {
                          return ValueListenableBuilder<String?>(
                            valueListenable: _userTaggedNotifier,
                            builder: (context, value, _) {
                              if (value == null) return Offstage();
                              final users = taggedUsers(state.members, value);
                              return users.isEmpty
                                  ? Offstage()
                                  : TaggedUsers(
                                      members: users,
                                      onUserPressed: (username) =>
                                          onTaggedUserSelected(value, username),
                                    );
                            },
                          );
                        }
                        return Offstage();
                      },
                    ),
                  ),
              ],
            ),
          ),

          if (widget.isGroupChat)
            // Message Input Box for Group chat
            BlocBuilder<GroupCubit, GroupState>(
              builder: (context, state) {
                if (state is GroupMembers) {
                  final isAMember = state.members.firstWhereOrNull(
                      (element) => element.id == CurrentUser.currentUserId);
                  if (isAMember != null) {
                    return MessageInputBox(
                      chatId: widget.chatId,
                      inputFocusNode: _inputFocusNode,
                      controller: _inputController,
                      userTaggingNotifier: _userTaggedNotifier,
                      onSentButtonPressed: (final message) =>
                          sendMessage(context, message),
                    );
                  }
                }
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                  color: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            )
          else
            // Message Input Box for One to One chat
            MessageInputBox(
              chatId: widget.chatId,
              inputFocusNode: _inputFocusNode,
              controller: _inputController,
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

  List<PureUser> taggedUsers(List<PureUser> users, String value) {
    final members = users.toList();
    members.removeWhere((element) => element.id == CurrentUser.currentUserId);

    return members.toList().where((member) {
      return member.username.toLowerCase().contains(value.toLowerCase());
    }).toList();
  }

  void onTaggedUserSelected(String input, String selected) {
    replaceUserTagOnSelected(_inputController, input, selected);
  }
}
