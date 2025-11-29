import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_service.dart';

class TransactionController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final OCRService _ocr = OCRService();

  //  foto  ticket
  Future<File?> pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  //  Detector OCR 
  Future<String?> detectAmount(File image) async {
    return await _ocr.extractTotal(image);
  }

  //  Subir imagen 
  Future<String?> uploadTicket(File? file) async {
    if (file == null) return null;

    final ref = _storage.ref().child(
      "tickets/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Guardar transacción 
  Future<void> saveTransaction({
    required String title,
    required double amount,
    required String type,
    File? ticketImage,
  }) async {
    final imageUrl = await uploadTicket(ticketImage);

    await _db.collection("transactions").add({
      "title": title,
      "amount": amount,
      "type": type,
      "imageUrl": imageUrl,
      "date": DateTime.now(),
    });
  }
}
