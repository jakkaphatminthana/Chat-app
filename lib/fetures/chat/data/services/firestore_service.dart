import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firebase = FirebaseFirestore.instance;

  //TODO : Get User Data by Id
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDataById({
    required userId,
  }) async {
    final collection = _firebase.collection('users');

    return await collection.doc(userId).get();
  }

  //TODO : Create User Profile
  Future<void> createUserProfile({
    required String userId,
    required String username,
    required String email,
    required String imageUrl,
  }) async {
    final collection = _firebase.collection('users');

    await collection.doc(userId).set({
      'username': username,
      'email': email,
      'image_url': imageUrl,
    });
  }
}
