import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:pure/utils/app_utils.dart';

import '../utils/global_utils.dart';

abstract class RemoteStorage {
  Future<String?> uploadProfileImage(String userId, File file);
  Future<String?> uploadChatFile(String chatId, File file, String fileExt);
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
  Future<String?> uploadChatFile(
      String chatId, File file, String fileExt) async {
    final fileId = generateRandomId();
    final storageReference =
        firebaseStorage!.ref("Chats").child(chatId).child("$fileId$fileExt");
    await storageReference
        .putFile(file)
        .timeout(GlobalUtils.imageUploadtimeOutInDuration);
    final url = await storageReference.getDownloadURL();
    return url;
  }
}
