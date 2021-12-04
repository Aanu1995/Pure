import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Attachment extends Equatable {
  final String? fileURL;
  final File? localFile;
  final String name;
  final int size;
  final String? type;
  final String fileExtension;

  const Attachment(
    this.fileURL,
    this.localFile,
    this.name,
    this.size,
    this.type,
    this.fileExtension,
  );

  Map<String, dynamic> toMap();

  Attachment copyWith(String name);

  static Attachment? getAttachment(Map<String, dynamic> data) {
    final String attachMentType = data["type"] as String;
    if (attachMentType == AttachmentType.image.getString) {
      return ImageAttachment.fromMap(data);
    } else if (attachMentType == AttachmentType.document.getString) {
      return DocumentAttachment.fromMap(data);
    }
  }

  @override
  List<Object?> get props => [fileURL, name, size, type, fileExtension];
}

class ImageAttachment extends Attachment {
  final int width;
  final int height;
  final Color? color;

  const ImageAttachment({
    String? fileURL,
    File? localFile,
    required String name,
    required int size,
    String? type,
    required String fileExtension,
    required this.height,
    required this.width,
    required this.color,
  }) : super(fileURL, localFile, name, size, type, fileExtension);

  factory ImageAttachment.fromMap(Map<String, dynamic> data) {
    Color color = Color(0xFF242424);
    final colorInt = data["color"] as int?;
    if (colorInt != null) {
      color = Color(colorInt);
    }

    return ImageAttachment(
      fileURL: data["fileURL"] as String?,
      name: data["name"] as String,
      size: data["size"] as int,
      type: data["type"] as String?,
      fileExtension: data["fileExtension"] as String,
      height: data["height"] as int,
      width: data["width"] as int,
      color: color,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "fileURL": this.fileURL,
      "name": this.name,
      "size": this.size,
      "type": this.type ?? AttachmentType.image.getString,
      "fileExtension": this.fileExtension,
      "width": this.width,
      "height": this.height,
      "color": this.color?.value,
    };
  }

  @override
  ImageAttachment copyWith(String imageURL) {
    return ImageAttachment(
      name: name,
      fileURL: imageURL,
      size: size,
      type: type,
      fileExtension: fileExtension,
      height: height,
      width: width,
      color: color,
    );
  }

  @override
  List<Object?> get props =>
      [fileURL, name, size, type, fileExtension, width, height];
}

class DocumentAttachment extends Attachment {
  const DocumentAttachment({
    String? fileURL,
    File? localFile,
    required String name,
    required int size,
    String? type,
    required String fileExtension,
  }) : super(fileURL, localFile, name, size, type, fileExtension);

  factory DocumentAttachment.fromMap(Map<String, dynamic> data) {
    return DocumentAttachment(
      fileURL: data["fileURL"] as String?,
      name: data["name"] as String,
      size: data["size"] as int,
      type: data["type"] as String?,
      fileExtension: data["fileExtension"] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "fileURL": this.fileURL,
      "name": this.name,
      "size": this.size,
      "type": this.type ?? AttachmentType.document.getString,
      "fileExtension": this.fileExtension,
    };
  }

  @override
  DocumentAttachment copyWith(String docURL) {
    return DocumentAttachment(
      name: name,
      fileURL: docURL,
      size: size,
      type: type,
      fileExtension: fileExtension,
    );
  }
}

class VoiceAttachment extends Attachment {
  const VoiceAttachment({
    String? fileURL,
    File? localFile,
    required String name,
    required int size,
    String? type,
    required String fileExtension,
  }) : super(fileURL, localFile, name, size, type, fileExtension);

  factory VoiceAttachment.fromMap(Map<String, dynamic> data) {
    return VoiceAttachment(
      fileURL: data["fileURL"] as String?,
      name: data["name"] as String,
      size: data["size"] as int,
      type: data["type"] as String?,
      fileExtension: data["fileExtension"] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "fileURL": this.fileURL,
      "name": this.name,
      "size": this.size,
      "type": this.type ?? AttachmentType.document.getString,
      "fileExtension": this.fileExtension,
    };
  }

  @override
  DocumentAttachment copyWith(String docURL) {
    return DocumentAttachment(
      name: name,
      fileURL: docURL,
      size: size,
      type: type,
      fileExtension: fileExtension,
    );
  }
}

enum AttachmentType { image, document }

extension AttachmentTypeExtension on AttachmentType {
  String get getString {
    switch (this) {
      case AttachmentType.image:
        return "image";
      case AttachmentType.document:
        return "document";
      default:
        return "";
    }
  }
}
