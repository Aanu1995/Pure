import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/bloc.dart';
import '../../../blocs/search/search_username.dart';
import '../../../model/pure_user_model.dart';
import '../../../repositories/push_notification.dart';
import '../../../services/search_service.dart';
import '../../../services/user_service.dart';
import '../../../utils/image_utils.dart';
import '../../../utils/navigate.dart';
import '../../widgets/bottom_bar.dart';
import 'account_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'update_username_screen.dart';
import 'widgets/items.dart';
import 'widgets/profile.dart';

class SettingsScreen extends StatelessWidget {
  final bool hidBottomNav;
  const SettingsScreen({Key? key, this.hidBottomNav = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: Text("Settings")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: _Body(),
        ),
      ),
      bottomNavigationBar: hidBottomNav ? null : const BottomBar(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  void signOutListener(BuildContext context, AuthState authState) {
    if (authState is UnAuthenticated) {
      GoRouter.of(context).goNamed("social");
      context.read<BottomBarBloc>().reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: signOutListener,
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final user = state.user;
            return Column(
              children: [
                // Profile
                MyProfileSection(user: user),
                const SizedBox(height: 20.0),
                SettingItem(
                  title: "Edit Profile",
                  icon: ImageUtils.edit,
                  onTap: () => pushToScreen(
                    context,
                    BlocProvider(
                      create: (_) => UserProfileCubit(UserServiceImpl()),
                      child: EditProfileScreen(user: user),
                    ),
                  ),
                ),
                SettingItem(
                  title: "Change Username",
                  icon: ImageUtils.communities,
                  onTap: () => pushToScreen(
                    context,
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (_) => SearchBloc(SearchServiceImpl()),
                        ),
                        BlocProvider(
                          create: (_) => UserProfileCubit(UserServiceImpl()),
                        )
                      ],
                      child: UpdateUsernameScreen(user: user),
                    ),
                  ),
                ),
                SettingItem(
                  title: "Connections",
                  icon: ImageUtils.friends,
                  onTap: () {},
                ),
                // Preferences
                TitleHeader(
                  title: "Preferences",
                  child: Column(
                    children: [
                      SettingItem(
                        title: "Account and Privacy",
                        icon: ImageUtils.privacy,
                        onTap: () => pushToScreen(context, AccountScreen()),
                      ),
                      SettingItem(
                        title: "Notifications",
                        icon: ImageUtils.notifications,
                        onTap: () {},
                      ),
                      SettingItem(
                        title: "Sounds",
                        icon: ImageUtils.sound,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Other
                TitleHeader(
                  title: "Other",
                  child: Column(
                    children: [
                      SettingItem(
                        title: "User Guide",
                        icon: ImageUtils.guide,
                        onTap: () {},
                      ),
                      SettingItem(
                        title: "Help And Feedback",
                        icon: ImageUtils.help,
                        onTap: () {},
                      ),
                      SettingItem(
                        title: "Log Out",
                        icon: ImageUtils.logout,
                        hideTrailingIcon: true,
                        color: Colors.redAccent,
                        onTap: () => signOut(context),
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                )
              ],
            );
          }
          return Offstage();
        },
      ),
    );
  }

  void pushToScreen(BuildContext context, Widget page) {
    push(context: context, page: page);
  }

  Future<void> signOut(BuildContext context) async {
    await PushNotificationImpl.deleteToken();
    BlocProvider.of<ChatCubit>(context).dispose();
    BlocProvider.of<ConnectorCubit>(context).dispose();
    BlocProvider.of<ReceivedInvitationCubit>(context).dispose();
    BlocProvider.of<SentInvitationCubit>(context).dispose();
    await BlocProvider.of<AuthCubit>(context)
        .signOut(CurrentUser.currentUserId);
  }
}
