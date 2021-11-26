import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../utils/global_utils.dart';

abstract class RemoteStorage {
  Future<String?> uploadProfileImage(String userId, File file);
  Future<String?> uploadImage(String id, File file);
}

class RemoteStorageImpl implements RemoteStorage {
  RemoteStorageImpl({this.firebaseStorage}) {
    firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;
  }

  FirebaseStorage? firebaseStorage;

  /// upload image file to firebase storage and return the file imageurl
  @override
  Future<String?> uploadProfileImage(String userId, File file) async {
    final storageReference =
        firebaseStorage!.ref().child('profile').child('$userId.png');
    await storageReference
        .putFile(file)
        .timeout(GlobalUtils.imageUploadtimeOutInDuration);
    final url = await storageReference.getDownloadURL();
    return url;
  }

  @override
  Future<String?> uploadImage(String id, File file) async {
    final storageReference = firebaseStorage!.ref().child('$id.png');
    await storageReference
        .putFile(file)
        .timeout(GlobalUtils.imageUploadtimeOutInDuration);
    final url = await storageReference.getDownloadURL();
    return url;
  }
}
