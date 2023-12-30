import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageServices {
  final _storage = FirebaseStorage.instance;

  //TODO : Upload Image Profile User 
  Future<Reference> uploadImageProfile({
    required String userId,
    required File image,
  }) async {
    final storageRef = _storage.ref().child('user_image').child('$userId.jpg');
    await storageRef.putFile(image);

    return storageRef;
  }
}
