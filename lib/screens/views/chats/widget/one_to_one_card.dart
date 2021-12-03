import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/navigate.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/shimmers/loading_shimmer.dart';
import '../../../widgets/user_profile_provider.dart';
import '../messages/messages_screen.dart';

class OneToOneCard extends StatefulWidget {
  final ChatModel chat;
  final String userId;
  final bool showSeparator;
  const OneToOneCard({
    Key? key,
    required this.chat,
    required this.userId,
    this.showSeparator = false,
  }) : super(key: key);

  @override
  State<OneToOneCard> createState() => _OneToOneCardState();
}

class _OneToOneCardState extends State<OneToOneCard> {
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

    return UserPresenceProvider(
      key: ValueKey(widget.userId),
      userId: widget.userId,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileSuccess) {
            final user = state.user;
            return Column(
              children: [
                ListTile(
                  horizontalTitleGap: 4,
                  contentPadding: EdgeInsets.fromLTRB(6, 4, 14, 4),
                  onTap: () => pushToMessagesScreen(context, user),
                  leading: Avartar(
                    key: ValueKey(user.photoURL),
                    size: 38.0,
                    imageURL: user.photoURL,
                    hidePresence: false,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          key:
                              ValueKey("${widget.chat.chatId}${user.fullName}"),
                          maxLines: 1,
                          style: _style,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      BlocBuilder<UnreadMessageCubit, int>(
                        builder: (context, unreadState) {
                          return Text(
                            chatTime(widget.chat.updateDate),
                            key: ObjectKey(widget.chat.updateDate),
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
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          key: ValueKey(
                              "${widget.chat.chatId}${widget.chat.lastMessage}"),
                          child: Row(
                            children: [
                              if (widget.chat.lastMessage.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.attachment,
                                    size: 20.0,
                                    color: secondVarColor,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  widget.chat.lastMessage.isEmpty
                                      ? "Attachments"
                                      : widget.chat.lastMessage,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _style.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: secondVarColor,
                                  ),
                                ),
                              ),
                            ],
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
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                badgeContent: Text(
                                  state.toString(),
                                  style: _style.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.surface,
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
                ),
                if (widget.showSeparator)
                  Padding(
                    padding: const EdgeInsets.only(left: 88.0),
                    child: const Divider(height: 0.0),
                  ),
              ],
            );
          }
          return const SingleShimmer();
        },
      ),
    );
  }

  void pushToMessagesScreen(BuildContext context, PureUser user) {
    push(
      context: context,
      page: BlocProvider.value(
        value: BlocProvider.of<UserPresenceCubit>(context),
        child: MessagesScreen(
          chatId: widget.chat.chatId,
          receipient: user,
          hasPresenceActivated: true,
        ),
      ),
    );
  }
}
