import 'dart:io';

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
import '../../utils/true_time.dart';
import '../widgets/nav_bar_notification.dart';
import '../widgets/push_notification_navigation.dart';
import 'chats/chat_screen.dart';
import 'connections/connections_page.dart';
import 'home/home_page.dart';
import 'notifications/notifications_screen.dart';
import 'settings/settings_screen.dart';

// This is a global controller to control bottom nav bar from
// anywhere within the app
late CupertinoTabController cupertinoTabController;

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
      child: _AppBaseExtension(),
    );
  }
}

class _AppBaseExtension extends StatefulWidget {
  const _AppBaseExtension({Key? key}) : super(key: key);

  @override
  __AppBaseExtensionState createState() => __AppBaseExtensionState();
}

class __AppBaseExtensionState extends State<_AppBaseExtension> {
  // creates list of key for each tab
  // This is required to handle backbutton in android
  final tabKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  void initState() {
    super.initState();
    TrueTime.initialize();
    cupertinoTabController = CupertinoTabController();
    initialize();
    initializePushNotificationMethods();
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
  void dispose() {
    cupertinoTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: CupertinoTabScaffold(
        controller: cupertinoTabController,
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          activeColor: Palette.tintColor,
          inactiveColor: Theme.of(context).colorScheme.secondaryVariant,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.home)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage(ImageUtils.friends)),
              label: 'Connections',
            ),
            BottomNavigationBarItem(
              icon: NotificationCouterWidget(),
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
            navigatorKey: tabKeys[index],
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

  // This method is required to handle back button pressed in android
  // The logic also handle ability to exit the app only when the app
  // is in the home tab
  Future<bool> onWillPop() async {
    final result =
        await tabKeys[cupertinoTabController.index].currentState!.maybePop();
    if (result)
      return false;
    else {
      if (cupertinoTabController.index != 0) {
        cupertinoTabController.index = 0;
        return false;
      }
      return true;
    }
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
