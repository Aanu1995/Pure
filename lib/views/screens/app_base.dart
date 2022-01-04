import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../model/pure_user_model.dart';
import '../../repositories/push_notification.dart';
import '../../services/chat/chat_service.dart';
import '../../services/connection_service.dart';
import '../../services/user_service.dart';
import '../../utils/image_utils.dart';
import '../../utils/palette.dart';
import '../widgets/push_notification_navigation.dart';
import 'chats/chat_screen.dart';
import 'connections/connections_page.dart';
import 'home/home_page.dart';
import 'notifications/notifications_screen.dart';
import 'settings/settings_screen.dart';

class AppBase extends StatelessWidget {
  const AppBase({Key? key}) : super(key: key);

  static final _chatService = ChatServiceImp();
  static final _connectionService = ConnectionServiceImpl();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectorCubit(connectionService: _connectionService),
        ),
        BlocProvider(create: (_) => ChatCubit(_chatService)),
        BlocProvider(create: (_) => UnReadChatCubit(_chatService)),
      ],
      child: AppBaseExtenion(),
    );
  }
}

// This is a global controller to control bottom nav bar from
// anywhere within the app
late CupertinoTabController cupertinoTabController;

class AppBaseExtenion extends StatefulWidget {
  const AppBaseExtenion({Key? key}) : super(key: key);

  @override
  _AppBaseExtenionState createState() => _AppBaseExtenionState();
}

class _AppBaseExtenionState extends State<AppBaseExtenion> {
  @override
  void initState() {
    super.initState();
    cupertinoTabController = CupertinoTabController();
    initialize();
    initializePushNotificationMethods();
  }

  @override
  void dispose() {
    cupertinoTabController.dispose();
    super.dispose();
  }

  void initialize() {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.id;
      CurrentUser.setUserId = currentUserId;
      // set user presence online
      context.read<AuthCubit>().setUserOnline(currentUserId);
      // gets all unread chat
      context.read<UnReadChatCubit>().getUnreadMessageCounts(currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (cupertinoTabController.index > 0) {
          cupertinoTabController.index = 0;
          return false;
        }
        return true;
      },
      child: CupertinoTabScaffold(
        controller: cupertinoTabController,
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          activeColor: Palette.tintColor,
          inactiveColor: Theme.of(context).colorScheme.secondaryVariant,
          iconSize: 24,
          items: [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.home)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.friends)),
              label: 'Connections',
            ),
            BottomNavigationBarItem(
              icon: _NotificationCouterWidget(),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.notifications)),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.settings)),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) {
              return const [
                HomePage(),
                ConnectionsPage(),
                ChatScreen(),
                NotificationsScreen(),
                SettingsScreen(),
              ][index];
            },
          );
        },
      ),
    );
  }

  // Push Notifications
  Future<void> initializePushNotificationMethods() async {
    // This only support android till when push notification is set up
    // for IOS
    if (Platform.isAndroid) {
      final notifications = PushNotificationImpl();

      // initialize notifications
      notifications.initialize(
        NotificationNavigation.updateNotificationScreen,
        NotificationNavigation.navigateToScreenOnMessageOpenApp,
      );

      // executes method on token refreshed
      notifications.onTokenRefreshed((token) async {
        final userId = CurrentUser.currentUserId;
        final deviceId = await notifications.getDeviceId();
        if (deviceId != null) {
          // updates the token at the server side
          UserServiceImpl().updateUserFCMToken(userId, deviceId, token);
        }
      });
    }
  }
}

class _NotificationCouterWidget extends StatelessWidget {
  const _NotificationCouterWidget({Key? key}) : super(key: key);

  final _style = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ImageIcon(AssetImage(ImageUtils.message)),
        ),
        Positioned(
          top: -2.0,
          right: 10.0,
          child: BlocBuilder<UnReadChatCubit, int>(
            builder: (context, state) {
              if (state > 0) {
                return Badge(
                  badgeColor: Colors.red,
                  elevation: 0.0,
                  padding: EdgeInsets.all(6.0),
                  animationType: BadgeAnimationType.fade,
                  badgeContent: Text(
                    state.toString(),
                    style: _style.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }
              return Offstage();
            },
          ),
        )
      ],
    );
  }
}
