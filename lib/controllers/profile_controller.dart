import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_expense_tracker_ocr/models/user.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<UserModel?> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, user.uid);
    }

    final newUser = UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email,
      photoUrl: user.photoURL,
    );

    await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

    return newUser;
  }

  Future<File?> pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<String?> uploadPhoto(String uid, File? image) async {
    if (image == null) return null;

    final ref = _storage.ref().child("profile_photos/$uid.jpg");

    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> saveProfile(UserModel user, File? newImage) async {
    final firebaseUser = _auth.currentUser!;
    final uid = firebaseUser.uid;

    String? newUrl = await uploadPhoto(uid, newImage);

    final updatedUser = UserModel(
      uid: uid,
      name: user.name,
      email: user.email,
      photoUrl: newUrl ?? user.photoUrl,
    );

    await _firestore.collection('users').doc(uid).update(updatedUser.toMap());

    await firebaseUser.updateDisplayName(updatedUser.name);
    if (newUrl != null) {
      await firebaseUser.updatePhotoURL(newUrl);
    }
  }
}
