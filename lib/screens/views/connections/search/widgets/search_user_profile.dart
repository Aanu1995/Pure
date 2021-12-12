import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pure/screens/views/settings/settings_screen.dart';

import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/navigate.dart';
import '../../../../widgets/avatar.dart';
import '../../../settings/profile/profile_screen.dart';
import 'connection_status_widget.dart';

class ShortUserProfile extends StatelessWidget {
  final PureUser user;
  const ShortUserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        push(
          context: context,
          page: user.isMe
              ? SettingsScreen(hidBottomNav: true)
              : ProfileScreen(user: user),
        );
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      horizontalTitleGap: 8.0,
      leading: CircleAvatar(
        radius: 14.0,
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        backgroundImage: AssetImage(ImageUtils.user),
        foregroundImage: user.photoURL.isEmpty
            ? null
            : CachedNetworkImageProvider(user.photoURL),
      ),
      title: Text(
        user.isMe ? "You" : user.fullName,
        style: const TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      trailing: Icon(Icons.chevron_right),
    );
  }
}

class DetailedUserProfile extends StatelessWidget {
  final PureUser user;
  const DetailedUserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        push(context: context, page: ProfileScreen(user: user));
      },
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      horizontalTitleGap: 12.0,
      leading: Avartar(size: 30.0, imageURL: user.photoURL),
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontSize: 17.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          user.about!.isEmpty ? "--" : user.about!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ),
      trailing: ConnectionStatusWidget(viewer: user),
    );
  }
}
