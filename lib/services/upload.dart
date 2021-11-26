import 'dart:io';

abstract class Upload {
  Future<String> uploadImage(String id, File imageFile);
}
