import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/message_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../widgets/avatar.dart';
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

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _userTaggedNotifier.dispose();
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
                                  : _TaggedUsers(members: users);
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
    return users.toList().where((member) {
      return member.fullName.toLowerCase().contains(value.toLowerCase());
    }).toList();
  }
}

class _TaggedUsers extends StatelessWidget {
  final List<PureUser> members;
  const _TaggedUsers({Key? key, required this.members}) : super(key: key);

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
                title: Text(member.fullName),
              );
            },
          ),
        );
      },
    );
  }
}
