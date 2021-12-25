import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/bloc.dart';
import '../../blocs/chats/chats/unread_chat.dart';
import '../../model/pure_user_model.dart';
import '../../repositories/push_notification.dart';
import '../../services/user_service.dart';
import '../widgets/push_notification_navigation.dart';
import 'chats/chat_screen.dart';
import 'connections/connections_page.dart';
import 'home/home_page.dart';
import 'notifications/notifications_screen.dart';
import 'settings/settings_screen.dart';

class AppBase extends StatefulWidget {
  const AppBase({Key? key}) : super(key: key);

  @override
  _AppBaseState createState() => _AppBaseState();
}

class _AppBaseState extends State<AppBase> {
  static const List<Widget> screens = [
    HomePage(),
    ConnectionsPage(),
    ChatScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return BlocBuilder<BottomBarCubit, int>(
      builder: (context, state) {
        return screens[state];
      },
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
