import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/chat_utils.dart';
import '../../../../widgets/avatar.dart';
import '../../../../widgets/editable_text_controller.dart';
import 'message_inbox_widget.dart';
import 'messages_body.dart';

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
  final _userTaggedNotifier = ValueNotifier<String?>(null);
  TextEditingController _inputController = TextEditingController();

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
                if (widget.receipientName == null)
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
                                  : _TaggedUsers(
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
          // Message Input Box
          MessageInputBox(
            chatId: widget.chatId,
            inputFocusNode: _inputFocusNode,
            controller: _inputController,
            // recipient name is null if it is a group chat
            // because the current user is not conversing with a specific user
            // but rather a group of users
            userTaggingNotifier:
                widget.receipientName == null ? _userTaggedNotifier : null,
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

class _TaggedUsers extends StatelessWidget {
  final List<PureUser> members;
  final Function(String) onUserPressed;
  const _TaggedUsers(
      {Key? key, required this.members, required this.onUserPressed})
      : super(key: key);

  final _style = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          color: Theme.of(context).dialogBackgroundColor,
          child: ListView.separated(
            itemCount: members.length,
            controller: scrollController,
            separatorBuilder: (_, __) => Divider(height: 0),
            itemBuilder: (context, index) {
              final member = members[index];
              return ListTile(
                leading: Avartar2(imageURL: member.photoURL),
                title: RichText(
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: member.fullName,
                        style: _style.copyWith(
                          color: Theme.of(context).colorScheme.primaryVariant,
                        ),
                      ),
                      TextSpan(
                        text: "  @${member.username}",
                        style: _style.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondaryVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => onUserPressed.call("${member.username} "),
              );
            },
          ),
        );
      },
    );
  }
}
