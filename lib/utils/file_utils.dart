import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../model/chat/attachment_model.dart';
import 'global_utils.dart';

abstract class FileUtils {
  Future<PlatformFile?> pickFile();
}

class FileUtilsImpl implements FileUtils {
  final List<String> allowedExtensions = ["pdf", "doc", "txt", "docx", "xlsx"];

  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        PlatformFile file = result.files.single;
        return file;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

Future<String> getFilePath() async {
  Directory directory = await getTemporaryDirectory();
  return directory.path;
}

extension FileSize on PlatformFile {
  String get getFileSize {
    int sizeInByte = this.size;
    return getStadardFileSize(sizeInByte);
  }
}

extension FileExtension on File {
  // returns the file extension
  String get getFileExtension => extension(this.path, 1);
}

extension FileExtention on FileSystemEntity {
  String? get name {
    return this.path.split("/").last;
  }
}

String getStadardFileSize(int sizeInByte) {
  int divider = 1024;
  if (sizeInByte < divider * divider && sizeInByte % divider == 0) {
    return '${(sizeInByte / divider).toStringAsFixed(0)} KB';
  } else if (sizeInByte < divider * divider) {
    return '${(sizeInByte / divider).toStringAsFixed(2)} KB';
  } else if (sizeInByte < divider * divider * divider &&
      sizeInByte % divider == 0) {
    return '${(sizeInByte / (divider * divider)).toStringAsFixed(0)} MB';
  } else if (sizeInByte < divider * divider * divider) {
    return '${(sizeInByte / divider / divider).toStringAsFixed(2)} MB';
  } else {
    return sizeInByte.toString();
  }
}

Future<List<ImageAttachment>> getImageAttachments(List<File> imageFiles) async {
  List<ImageAttachment> attachments = [];

  for (final image in imageFiles) {
    final int fileSize = await image.length();
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    final color = await getImageColor(image) ?? Color(0xFF242424);

    attachments.add(
      ImageAttachment(
        name: image.name ?? "",
        localFile: image,
        size: fileSize,
        fileExtension: image.getFileExtension,
        height: decodedImage.height,
        width: decodedImage.width,
        color: color,
      ),
    );
  }
  return attachments;
}

List<DocumentAttachment> getDocAttachments(PlatformFile docFile) {
  List<DocumentAttachment> attachments = [];

  attachments.add(
    DocumentAttachment(
      localFile: File(docFile.path!),
      name: docFile.name,
      size: docFile.size,
      fileExtension: docFile.extension!,
    ),
  );
  return attachments;
}

Future<bool> isImageUploadSizeExceeded(File file) async {
  // get image file size
  final int fileSize = await file.length();
  return fileSize > GlobalUtils.maxImageUploadSizeInByte;
}

Future<Color?> getImageColor(File image) async {
  PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
    FileImage(image),
    size: Size(200, 200),
  );
  return generator.darkMutedColor?.color;
}
