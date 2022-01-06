import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/model/chat/message_model.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../../model/chat/chat_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/palette.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/avatar.dart';
import '../../../settings/profile/profile_screen.dart';

class Participants extends StatefulWidget {
  final ChatModel chat;
  final List<PureUser> participants;
  final Function()? onAddNewParticipantstapped;

  const Participants({
    Key? key,
    required this.participants,
    required this.chat,
    this.onAddNewParticipantstapped,
  }) : super(key: key);

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  late PureUser currentUser;
  final _style = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      currentUser = authState.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 0.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            "${widget.participants.length} PARTICIPANTS",
            maxLines: 1,
            style: _style.copyWith(
              color: Theme.of(context).colorScheme.secondaryVariant,
              fontWeight: FontWeight.w400,
              fontSize: 13.0,
              letterSpacing: 0.25,
            ),
          ),
        ),
        Divider(height: 0.0),
        // Only the group Admin can add participants
        if (widget.chat.isAdmin(CurrentUser.currentUserId))
          Column(
            children: [
              // Add Particpants
              _Item(
                title: "Add Participants",
                icon: Icons.add,
                onTap: widget.onAddNewParticipantstapped,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 60.0),
                child: Divider(height: 0.0),
              ),
              // Invite to Group
              _Item(
                title: "Invite to group via link",
                icon: Icons.link,
                onTap: () {},
              )
            ],
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(left: 74.0),
            child: Divider(height: 0.0),
          ),
          itemCount: widget.participants.length,
          itemBuilder: (context, index) {
            final participant = widget.participants[index];
            return ListTile(
              dense: true,
              horizontalTitleGap: 12.0,
              onTap: () => onUserTapped(context, index, participant),
              onLongPress: () => onUserLongPressed(context, participant),
              leading: Avartar2(imageURL: participant.photoURL),
              title: RichText(
                maxLines: 1,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: participant.isMe ? "You" : participant.fullName,
                      style: _style.copyWith(
                        color: Theme.of(context).colorScheme.primaryVariant,
                      ),
                    ),
                    TextSpan(
                      text: "  @${participant.username}",
                      style: _style.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondaryVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: widget.chat.isAdmin(participant.id)
                  ? Text(
                      "Admin",
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25,
                      ),
                    )
                  : Offstage(),
              subtitle: Padding(
                padding: const EdgeInsets.only(right: 40.0),
                child: Text(
                  participant.about!.isEmpty ? "--" : participant.about!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  void onUserTapped(
      BuildContext context, int index, final PureUser user) async {
    if (!user.isMe) {
      if (widget.chat.isAdmin(CurrentUser.currentUserId)) {
        const infoButton = SheetAction(label: 'Info', key: 'info');
        const makeButton = SheetAction(
          label: 'Make Group Admin',
          key: 'make',
        );
        const dismissButton = SheetAction(
          label: 'Dismiss As Admin',
          key: 'dismiss',
          isDestructiveAction: true,
        );
        const removeButton = SheetAction(
          label: 'Remove From Group',
          key: 'remove',
          isDestructiveAction: true,
        );

        final result = await showModalActionSheet<String>(
          context: context,
          title: user.fullName,
          actions: [
            infoButton,
            widget.chat.isAdmin(user.id) ? dismissButton : makeButton,
            removeButton,
          ],
        );

        if (result == "info") {
          push(context: context, page: ProfileScreen(user: user));
        } else if (result == "make") {
          BlocProvider.of<ParticipantCubit>(context)
              .addAdmin(widget.chat.chatId, user.id);
        } else if (result == "dismiss") {
          BlocProvider.of<ParticipantCubit>(context)
              .removeAdmin(widget.chat.chatId, user.id);
        } else if (result == "remove") {
          removeMember(index, user);
        }
      } else {
        onUserLongPressed(context, user);
      }
    }
  }

  void onUserLongPressed(BuildContext context, final PureUser user) {
    if (!user.isMe) {
      push(context: context, page: ProfileScreen(user: user));
    }
  }

  void removeMember(int index, PureUser removedMember) {
    final message = MessageModel.notifyMessage(
      "removed",
      currentUser.id,
      "@${currentUser.username}",
      object: "@${removedMember.username}",
    );
    context
        .read<ParticipantCubit>()
        .removeMember(widget.chat.chatId, index, message, removedMember);
  }
}

class _Item extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function()? onTap;

  const _Item({Key? key, required this.title, required this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20.0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(icon, color: Palette.tintColor),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Palette.tintColor,
            ),
          ),
        ],
      ),
    );
  }
}
