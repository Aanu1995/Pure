import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  // check if camera permission is granted
  static Future<void> checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      const title = 'Enable Camera Access';
      const message = 'Go to settings to enable camera access';
      await _showPermissionRequestDialog(
        context: context,
        title: title,
        message: message,
      );
    }
  }

  // check if camera permission is granted
  static Future<void> checkPhotoPermission(BuildContext context) async {
    final status = await Permission.photos.request();
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      const title = 'Enable Photos Access';
      const message = 'Go to settings to enable photo access';
      await _showPermissionRequestDialog(
        context: context,
        title: title,
        message: message,
      );
    }
  }

  static Future<void> checkMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      const title = 'Enable Microphone Access';
      const message = 'Go to settings to enable microphone access';
      await _showPermissionRequestDialog(
        context: context,
        title: title,
        message: message,
      );
    }
  }

  // check if camera permission is granted
  static Future<void> checkVideoPermission(BuildContext context) async {
    await checkPhotoPermission(context);
    await checkCameraPermission(context);
    await checkMicrophonePermission(context);
  }

  static Future<void> _showPermissionRequestDialog(
      {required BuildContext context,
      required String title,
      required String message}) async {
    final result = await showOkCancelAlertDialog(
      barrierDismissible: false,
      context: context,
      title: title,
      message: message,
      okLabel: 'Settings',
    );

    if (result == OkCancelResult.ok) {
      // open app settings for permission to be granted
      await AppSettings.openAppSettings();
    }
  }
}
