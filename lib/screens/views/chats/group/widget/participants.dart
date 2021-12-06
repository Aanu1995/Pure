import 'package:flutter/material.dart';

import '../../../../../model/chat/chat_model.dart';
import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/app_theme.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/avatar.dart';
import '../../../settings/profile/profile_screen.dart';

class Participants extends StatelessWidget {
  final ChatModel chat;
  final List<PureUser> participants;
  final Function()? onAddNewParticipantstapped;
  const Participants({
    Key? key,
    required this.participants,
    required this.chat,
    this.onAddNewParticipantstapped,
  }) : super(key: key);

  final _style = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(height: 0.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            "${participants.length} PARTICIPANTS",
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
        Column(
          children: [
            // Add Particpants
            _Item(
              title: "Add Participants",
              icon: Icons.add,
              onTap: onAddNewParticipantstapped,
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
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return ListTile(
              dense: true,
              horizontalTitleGap: 12.0,
              onTap: () => viewFullProfile(context, participant),
              leading: Avartar2(imageURL: participant.photoURL),
              title: Text(
                participant.isMe ? "You" : participant.fullName,
                maxLines: 1,
                style: _style,
              ),
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

  void viewFullProfile(BuildContext context, final PureUser user) {
    if (!user.isMe) {
      push(context: context, page: ProfileScreen(user: user));
    }
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
