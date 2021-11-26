import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';

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
