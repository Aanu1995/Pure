import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../model/pure_user_model.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../widgets/avatar.dart';
import 'connection_status_widget.dart';

class ShortUserProfile extends StatelessWidget {
  final PureUser viewer;
  const ShortUserProfile({Key? key, required this.viewer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // push(
        //     context: context,
        //     page: viewer.isMe
        //         ? ProfileScreen(isViewer: true)
        //         : ProfilePublicView(viewer: viewer));
      },
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      horizontalTitleGap: 8.0,
      leading: CircleAvatar(
        radius: 14.0,
        backgroundColor: Colors.red,
        backgroundImage: AssetImage(ImageUtils.user),
        foregroundImage: viewer.photoURL.isEmpty
            ? null
            : CachedNetworkImageProvider(viewer.photoURL),
      ),
      title: Text(
        viewer.isMe ? "You" : viewer.fullName,
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
  final PureUser viewer;
  const DetailedUserProfile({Key? key, required this.viewer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // push(context: context, page: ProfilePublicView(viewer: viewer));
      },
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      horizontalTitleGap: 12.0,
      leading: Avartar(size: 30.0, imageURL: viewer.photoURL),
      title: Text(
        viewer.fullName,
        style: const TextStyle(
          fontSize: 17.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          viewer.about!.isEmpty ? "--" : viewer.about!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ),
      trailing: ConnectionStatusWidget(
        viewer: viewer,
      ),
    );
  }
}
