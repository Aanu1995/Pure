import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:pure/model/chat/attachment_model.dart';

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

Future<List<ImageAttachment>> getImageAttachments(
    List<File> imageFiles, List<Color?> colors) async {
  List<ImageAttachment> attachments = [];

  for (int index = 0; index < imageFiles.length; index++) {
    final file = imageFiles[index];
    final int fileSize = await file.length();
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());
    attachments.add(
      ImageAttachment(
        name: file.name ?? "",
        localFile: file,
        size: fileSize,
        fileExtension: file.getFileExtension,
        height: decodedImage.height,
        width: decodedImage.width,
        color: colors[index] ?? Color(0xFF242424),
      ),
    );
  }
  return attachments;
}
