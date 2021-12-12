import 'dart:developer';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pure/blocs/chats/chats/unread_chat.dart';

import '../../blocs/bloc.dart';
import '../../model/pure_user_model.dart';
import '../../repositories/push_notification.dart';
import '../../services/user_service.dart';
import '../widgets/deep_link_navigation.dart';
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
    initDynamicLinks();
  }

  void initialize() {
    final currentUserId = CurrentUser.currentUserId;
    // set user presence online
    context.read<AuthCubit>().setUserOnline(currentUserId);
    // gets all unread chat
    context.read<UnReadChatCubit>().getUnreadMessageCounts(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomBarBloc, int>(
      builder: (context, state) {
        return screens[state];
      },
    );
  }

  // Push Notifications
  Future<void> initializePushNotificationMethods() async {
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

  // Firebase Dynamic links
  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        return DeepLinkNavigation.deepLinkRoute(dynamicLink?.link);
      },
      onError: (OnLinkErrorException e) async {
        return log(e.message ?? "Dynamic Link failed");
      },
    );

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    return DeepLinkNavigation.deepLinkRoute(data?.link);
  }
}
