import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_expense_tracker_ocr/services/ocr_service.dart';
import 'package:flutter_expense_tracker_ocr/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController {
  final OcrService _ocrService = OcrService();
  final StorageService _storage = StorageService();

  File? ticketImageFile;

  Future<void> pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    ticketImageFile = picked != null ? File(picked.path) : null;
  }

  Future<String?> detectAmount() async {
    if (ticketImageFile == null) return null;
    return await _ocrService.extractTotal(ticketImageFile!);
  }

  Future<String?> uploadImageToFirebase() async {
    if (ticketImageFile == null) return null;
    return await _storage.uploadImage(ticketImageFile!, 'tickets');
  }

  Future<DocumentReference> saveTransactionWithPhoto({
    required String note,
    required double amount,
    required String type,
  }) async {
    final imageURL = await uploadImageToFirebase();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuario no autenticado");
    }

    return await FirebaseFirestore.instance.collection("transactions").add({
      "note": note,
      "amount": amount,
      "date": DateTime.now().toIso8601String(),
      "type": type,
      "ticketPhotoUrl": imageURL,
      "userId": user.uid,
    });
  }

  void clearImage() {
    ticketImageFile = null;
  }
}
