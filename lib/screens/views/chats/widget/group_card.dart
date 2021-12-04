import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/app_theme.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/navigate.dart';
import '../../../widgets/avatar.dart';
import '../messages/group_chat_message_screen.dart';
import 'package:collection/collection.dart';

class GroupCard extends StatefulWidget {
  final ChatModel chat;
  final bool showSeparator;
  const GroupCard({Key? key, required this.chat, this.showSeparator = false})
      : super(key: key);

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  final _style = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  DateTime _lastUpdate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final secondVarColor = Theme.of(context).colorScheme.secondaryVariant;
    // This is possible because the state of this widget is not destroyed
    if (_lastUpdate != widget.chat.updateDate) {
      context.read<UnreadMessageCubit>().getUnreadMessageCounts(
          widget.chat.chatId, CurrentUser.currentUserId);
    }

    return Column(
      children: [
        ListTile(
          horizontalTitleGap: 4,
          contentPadding: EdgeInsets.fromLTRB(6, 4, 14, 4),
          onTap: () => pushToMessagesScreen(context),
          leading: Avartar(
            key: ValueKey(widget.chat.groupImage!),
            size: 38.0,
            imageURL: widget.chat.groupImage!,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  widget.chat.groupName!,
                  key: ValueKey("${widget.chat.groupName}"),
                  maxLines: 1,
                  style: _style,
                ),
              ),
              const SizedBox(width: 10.0),
              BlocBuilder<UnreadMessageCubit, int>(
                builder: (context, unreadState) {
                  return Text(
                    chatTime(widget.chat.updateDate),
                    key: ValueKey(widget.chat.updateDate.toIso8601String()),
                    style: _style.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: unreadState > 0
                          ? Theme.of(context).primaryColor
                          : secondVarColor,
                    ),
                  );
                },
              )
            ],
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                key:
                    ValueKey("${widget.chat.chatId}${widget.chat.lastMessage}"),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      height: 1.35,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondVarColor,
                      fontFamily: Palette.sanFontFamily,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.top,
                        child: BlocBuilder<GroupCubit, GroupState>(
                          builder: (context, state) {
                            if (state is GroupMembers) {
                              final _senderUser =
                                  state.members.firstWhereOrNull(
                                (member) => member.id == widget.chat.senderId,
                              );
                              if (_senderUser != null) {
                                bool isYou =
                                    _senderUser.id == CurrentUser.currentUserId;
                                return Text(
                                  isYou ? "You: " : "${_senderUser.fullName}: ",
                                  style: _style.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.25,
                                    color: secondVarColor,
                                  ),
                                );
                              }
                            }
                            return Offstage();
                          },
                        ),
                      ),
                      if (widget.chat.lastMessage.isEmpty)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.attachment,
                              size: 15.0,
                              color: secondVarColor,
                            ),
                          ),
                        ),
                      TextSpan(
                        text: widget.chat.lastMessage.isEmpty
                            ? "Attachments"
                            : widget.chat.lastMessage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              BlocBuilder<UnreadMessageCubit, int>(
                builder: (context, state) {
                  if (state > 0) {
                    return Badge(
                      badgeColor: Theme.of(context).primaryColor,
                      elevation: 0.0,
                      animationType: BadgeAnimationType.fade,
                      animationDuration: const Duration(milliseconds: 300),
                      badgeContent: Text(
                        state.toString(),
                        style: _style.copyWith(
                          color: Theme.of(context).colorScheme.surface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return Offstage();
                },
              )
            ],
          ),
        ),
        if (widget.showSeparator)
          Padding(
            padding: const EdgeInsets.only(left: 88.0),
            child: const Divider(height: 0.0),
          ),
      ],
    );
  }

  void pushToMessagesScreen(BuildContext context) {
    push(
      context: context,
      page: BlocProvider.value(
        value: BlocProvider.of<GroupCubit>(context),
        child: GroupChatMessageScreen(chatModel: widget.chat),
      ),
    );
  }
}
