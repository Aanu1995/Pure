import 'package:flutter/material.dart';

import '../../../../model/pure_user_model.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/page_transition.dart';
import '../../photo_view_screen.dart';

class MyProfileSection extends StatelessWidget {
  final PureUser user;
  const MyProfileSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Avartar(size: 48.0, imageURL: user.photoURL),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "@${user.username}",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondaryVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final PureUser user;
  const ProfileSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(500),
            child: Avartar(size: 48.0, imageURL: user.photoURL),
            onTap: () => viewProfilePhoto(context),
          ),
          const SizedBox(height: 16.0),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void viewProfilePhoto(BuildContext context) {
    if (user.photoURL.isNotEmpty) {
      Navigator.of(context).push<void>(
        PageTransition(
          child: ViewProfilePhoto(imageURL: user.photoURL),
          type: PageTransitionType.bottomToTop,
        ),
      );
    }
  }
}
