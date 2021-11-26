import 'package:flutter/material.dart';

import '../../widgets/bottom_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(child: Text('Notifications')),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
