import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImageMethods {
  Future<File?> pickImage(
    ImagePicker imagePicker,
    ImageSource source, {
    CameraDevice preferredCameraDevice,
    int? imageQuality,
    String cancelTitle,
    String? doneTitle,
    bool crop,
  });
}

class ImageUtils implements ImageMethods {
  static const String splash = 'assets/images/splash.png';

  // onboarding light mode slides
  static const String slide1Light = 'assets/images/slide1_light.png';
  static const String slide2Light = 'assets/images/slide2_light.png';
  static const String slide3Light = 'assets/images/slide3_light.png';
  // onboarding dark mode slides
  static const String slide1Dark = 'assets/images/slide1_dark.png';
  static const String slide2Dark = 'assets/images/slide2_dark.png';
  static const String slide3Dark = 'assets/images/slide3_dark.png';

  static const String logo = 'assets/images/logo.png';
  static const String apple = 'assets/images/apple.png';
  static const String google = 'assets/images/google.png';
  static const String user = 'assets/images/user.png';
  static const String edit = 'assets/images/edit.png';
  static const String friends = 'assets/images/friends.png';
  static const String communities = 'assets/images/communities.png';
  static const String privacy = 'assets/images/privacy.png';
  static const String notifications = 'assets/images/notifications.png';
  static const String sound = 'assets/images/sound.png';
  static const String logout = 'assets/images/logout.png';
  static const String guide = 'assets/images/guide.png';
  static const String help = 'assets/images/help.png';
  static const String eye = 'assets/images/eye.png';
  static const String message = 'assets/images/message.png';
  static const String video = 'assets/images/video.png';
  static const String settings = 'assets/images/settings.png';
  static const String home = 'assets/images/home.png';

  @override
  Future<File?> pickImage(
    ImagePicker imagePicker,
    ImageSource source, {
    CameraDevice preferredCameraDevice = CameraDevice.front,
    int? imageQuality = 100,
    String cancelTitle = 'Cancel',
    String? doneTitle = 'Done',
    bool crop = true,
  }) async {
    final pickedFile = await imagePicker.pickImage(
      source: source,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );

    if (pickedFile != null) {
      final rawPickedFile = File(pickedFile.path);
      // return raw file if cropping is not required
      if (crop == false) return rawPickedFile;

      final file = await cropImage(
        rawPickedFile,
        cancelTitle: cancelTitle,
        doneTitle: doneTitle,
      );
      return file;
    } else {
      return null;
    }
  }

  // this method is called to crop an image picked
  Future<File?> cropImage(File imageFile,
      {String? cancelTitle, String? doneTitle}) async {
    final croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxWidth: 300,
      maxHeight: 300,
      cropStyle: CropStyle.circle,
      compressFormat: ImageCompressFormat.png,
      aspectRatioPresets: [],
      iosUiSettings: IOSUiSettings(
        cancelButtonTitle: cancelTitle,
        doneButtonTitle: doneTitle,
        resetButtonHidden: true,
      ),
      androidUiSettings: const AndroidUiSettings(
        statusBarColor: Colors.white,
        toolbarColor: Colors.white,
        toolbarWidgetColor: Colors.black,
        showCropGrid: false,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        toolbarTitle: '',
        activeControlsWidgetColor: Colors.white,
      ),
    );
    return croppedFile;
  }
}