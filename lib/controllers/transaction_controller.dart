import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_expense_tracker_ocr/services/ocr_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController {
  final OcrService _ocrService = OcrService();

  File? ticketImageFile;
  Uint8List? ticketImageBytes;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    if (picked == null) return;

    if (kIsWeb) {
      ticketImageBytes = await picked.readAsBytes();
      ticketImageFile = null;
    } else {
      ticketImageFile = File(picked.path);
      ticketImageBytes = null;
    }
  }

  Future<String?> detectAmount() async {
    if (!kIsWeb && ticketImageFile != null) {
      return _ocrService.extractTotal(ticketImageFile!);
    }
    return null;
  }

  Future<void> saveTransaction({
    required String title,
    required double amount,
    required String type,
  }) async {
    await FirebaseFirestore.instance.collection("transactions").add({
      "title": title,
      "amount": amount,
      "date": DateTime.now(),
      "type": type,
      // Guardar la imagen en Firebase Storage y guardar la url
    });
  }

  void clearImage() {
    ticketImageFile = null;
    ticketImageBytes = null;
  }
}
