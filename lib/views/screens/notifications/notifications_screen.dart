import 'package:flutter/material.dart';

import '../../widgets/bottom_bar.dart';
import 'widgets/no_notification_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1, title: const Text('Notifications')),
      body: NoNotificationWidget(),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
