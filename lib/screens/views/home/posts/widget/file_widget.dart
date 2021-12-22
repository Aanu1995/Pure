import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../utils/app_permission.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../widgets/page_transition.dart';
import '../video_trimmer_screen.dart';

class PostImagePreview extends StatelessWidget {
  final List<File> imageFiles;
  final Function(File) onImageRemoved;
  const PostImagePreview({
    Key? key,
    required this.imageFiles,
    required this.onImageRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      height: 1.sw * 0.8,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: imageFiles.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        itemBuilder: (context, index) {
          final file = imageFiles[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                    onPressed: () => onImageRemoved(file),
                    color: Theme.of(context).colorScheme.secondary,
                    icon: Icon(Icons.cancel),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostFileIconWidget extends StatelessWidget {
  final File? videoFile;
  final List<File> imageFiles;
  final Function(List<File> files) onImageFilesUpdated;
  final Function(File originalFile, File trimmedFile) onVideoFilePicked;
  final Function() requestFocus;
  const PostFileIconWidget({
    Key? key,
    required this.imageFiles,
    required this.videoFile,
    required this.onImageFilesUpdated,
    required this.onVideoFilePicked,
    required this.requestFocus,
  }) : super(key: key);

  final _imageMethods = const ImageUtils();
  static final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: (videoFile == null && imageFiles.length <= 4)
                ? () => pickImageUsingCamera(context)
                : null,
            icon: Icon(FontAwesomeIcons.camera),
          ),
          IconButton(
            onPressed: (videoFile == null && imageFiles.length <= 4)
                ? () => pickImagesFromGallery(context)
                : null,
            icon: Icon(Icons.photo),
          ),
          IconButton(
            onPressed: (imageFiles.isEmpty)
                ? () => pickVideoUsingCamera(context)
                : null,
            icon: Icon(FontAwesomeIcons.video),
          ),
          IconButton(
            onPressed: (imageFiles.isEmpty)
                ? () => pickVideoFromGallery(context)
                : null,
            icon: Icon(Icons.video_library),
          ),
        ],
      ),
    );
  }

  Future<void> pickImagesFromGallery(BuildContext context) async {
    // close keyboard
    FocusScope.of(context).unfocus();
    try {
      final files = await _imageMethods.pickMultiImage(
        _imagePicker,
        compressQuality: 90,
      );
      if (files != null) onImageFilesUpdated(files);
    } on PlatformException catch (_) {
      await AppPermission.checkPhotoPermission(context);
    }
    // called to open keyboard again
    requestFocus();
  }

  Future<void> pickImageUsingCamera(BuildContext context) async {
    // close keyboard
    FocusScope.of(context).unfocus();
    try {
      final file = await _imageMethods.pickImage(
        _imagePicker,
        ImageSource.camera,
        compressQuality: 90,
        crop: false,
      );
      if (file != null) onImageFilesUpdated([file]);
    } on PlatformException catch (_) {
      await AppPermission.checkPhotoPermission(context);
    }
    // called to open keyboard again
    requestFocus();
  }

  Future<void> pickVideoFromGallery(BuildContext context) async {
    // close keyboard
    FocusScope.of(context).unfocus();
    try {
      final file = await _imageMethods.pickVideo(
        _imagePicker,
        ImageSource.gallery,
      );
      if (file != null) trimVideo(context, file);
    } on PlatformException catch (_) {
      await AppPermission.checkVideoPermission(context);
    }
    // called to open keyboard again
    requestFocus();
  }

  Future<void> pickVideoUsingCamera(BuildContext context) async {
    // close keyboard
    FocusScope.of(context).unfocus();
    try {
      final file = await _imageMethods.pickVideo(
        _imagePicker,
        ImageSource.camera,
      );
      if (file != null) trimVideo(context, file);
    } on PlatformException catch (_) {
      await AppPermission.checkVideoPermission(context);
    }
    // called to open keyboard again
    requestFocus();
  }

  Future<void> trimVideo(BuildContext context, File file) async {
    final trimmedFile = await Navigator.of(context).push<File?>(
      PageTransition(
        child: TrimmerView(file),
        type: PageTransitionType.bottomToTop,
      ),
    );
    if (trimmedFile != null) {
      onVideoFilePicked(file, trimmedFile);
    }
  }
}
