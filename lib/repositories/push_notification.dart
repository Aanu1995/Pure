import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../utils/global_utils.dart';

abstract class PushNotification {
  Future<void> initialize(void Function(RemoteMessage)? onMessageData,
      void Function(RemoteMessage)? onMessageOpenedAppData);
  void onTokenRefreshed(void Function(String)? onData);
  Future<void> requestPermissions();
}

class PushNotificationImpl implements PushNotification {
  final FirebaseMessaging? firebaseMessaging;

  PushNotificationImpl({this.firebaseMessaging}) {
    _fcm = firebaseMessaging ?? FirebaseMessaging.instance;
  }

  late FirebaseMessaging _fcm;

  Future<void> initialize(void Function(RemoteMessage)? onMessageData,
      void Function(RemoteMessage)? onMessageOpenedAppData) async {
    try {
      // Gets message while the app is in the foreground
      FirebaseMessaging.onMessage.listen(onMessageData);
      // gets message while the app is opened using notification
      FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppData);
      // if app is opened via a terminated state
      FirebaseMessaging.instance.getInitialMessage().then((value) {
        if (value != null) onMessageOpenedAppData!(value);
      });

      if (Platform.isIOS) {
        await _fcm.requestPermission(
          sound: true,
          badge: true,
          alert: true,
          provisional: false,
          criticalAlert: false,
        );

        await _fcm.setForegroundNotificationPresentationOptions(
          sound: true,
          badge: true,
          alert: true,
        );

        // Automatically subscribed user to Ahoy notifications. This is
        // necessary to broadcast information to all users of the app
        subscribeToTopic(GlobalUtils.pureTopic);
      }
    } catch (e) {}
  }

  void onTokenRefreshed(void Function(String)? onData) {
    _fcm.onTokenRefresh.listen(onData);
  }

  // To get the device id of the user
  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final result = await deviceInfoPlugin.androidInfo;
      return result.androidId;
    } else if (Platform.isIOS) {
      final result = await deviceInfoPlugin.iosInfo;
      return result.identifierForVendor;
    }
  }

  // send user device token to the server
  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  // delete the current token
  static Future<String?> deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(
      sound: true,
      badge: true,
      announcement: true,
      alert: true,
      provisional: false,
      criticalAlert: false,
    );

    await _fcm.setForegroundNotificationPresentationOptions(
      sound: true,
      badge: true,
      alert: true,
    );
  }

  // Methods to subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  // Methods to unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
