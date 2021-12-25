import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'exception.dart';
import 'file_utils.dart';
import 'global_utils.dart';

abstract class ImageMethods {
  Future<File?> pickImage(
    ImagePicker imagePicker,
    ImageSource source, {
    CameraDevice preferredCameraDevice,
    int imageQuality = 100,
    int compressQuality = 45,
    String? doneTitle,
    bool crop,
  });
  Future<List<File>?> pickMultiImage(ImagePicker imagePicker,
      {int imageQuality = 100, int compressQuality = 45});
  Future<File?> pickVideo(ImagePicker imagePicker, ImageSource source,
      {CameraDevice preferredCameraDevice = CameraDevice.front});
}

class ImageUtils implements ImageMethods {
  const ImageUtils();

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
  static const String emptyMessageLight = 'assets/images/emptyMessageLight.png';
  static const String emptyMessageDark = 'assets/images/emptyMessageDark.png';
  static const String username = 'assets/images/username.png';
  static const String location = 'assets/images/location.png';
  static const String calendar = 'assets/images/calendar.png';
  static const String notifyLight = 'assets/images/notify_light.png';
  static const String notifyDark = 'assets/images/notify_dark.png';

  @override
  Future<File?> pickImage(
    ImagePicker imagePicker,
    ImageSource source, {
    CameraDevice preferredCameraDevice = CameraDevice.front,
    int imageQuality = 100,
    int compressQuality = 45,
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

      // check if image does not exceed the maximum upload size
      final isExceeded = await isImageUploadSizeExceeded(rawPickedFile);
      if (isExceeded == false) {
        if (crop == false) {
          // compress image
          final compressedFile =
              await _compressImage(rawPickedFile, compressQuality);
          return compressedFile;
        } else {
          final file = await _cropImage(
            rawPickedFile,
            cancelTitle: cancelTitle,
            doneTitle: doneTitle,
          );
          return file;
        }
      } else {
        final standardSize =
            getStadardFileSize(GlobalUtils.maxImageUploadSizeInByte);
        final String message = "Maximum image upload size is $standardSize";
        throw MaximumUploadExceededException(message: message);
      }
    } else {
      return null;
    }
  }

  Future<File?> pickVideo(ImagePicker imagePicker, ImageSource source,
      {CameraDevice preferredCameraDevice = CameraDevice.front}) async {
    final pickedFile = await imagePicker.pickVideo(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: Duration(minutes: 2),
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  }

  @override
  Future<List<File>?> pickMultiImage(ImagePicker imagePicker,
      {int imageQuality = 100, int compressQuality = 45}) async {
    final pickedFiles =
        await imagePicker.pickMultiImage(imageQuality: imageQuality);

    if (pickedFiles != null) {
      List<File> imageFiles = [];

      for (final pickedFile in pickedFiles) {
        final rawPickedFile = File(pickedFile.path);
        // return raw file if cropping is not required

        // check if image does not exceed the maximum upload size
        final isExceeded = await isImageUploadSizeExceeded(rawPickedFile);
        if (isExceeded == false) {
          // compress image
          final compressedFile =
              await _compressImage(rawPickedFile, compressQuality);
          if (compressedFile != null) {
            imageFiles.add(compressedFile);
          }
        }
      }
      return imageFiles;
    } else {
      return null;
    }
  }

  // this method is called to crop an image picked
  Future<File?> _cropImage(File imageFile,
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

  Future<File?> _compressImage(File file, int quality) async {
    final filePath = file.absolute.path;

    // Create output file path
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final targetPath = "${splitted}_out${filePath.substring(lastIndex)}";

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: quality,
    );

    return result;
  }
}
