import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../services/ocr_service.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  File? ticketImage;
  bool loadingOCR = false;
  String transactionType = "Gasto";

  // Función OCR
  Future<void> pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked == null) return;

    setState(() => ticketImage = File(picked.path));
    setState(() => loadingOCR = true);

    final ocrService = OCRService();
    final extractedAmount = await ocrService.extractTotal(ticketImage!);

    setState(() => loadingOCR = false);

    if (extractedAmount != null) {
      amountCtrl.text = extractedAmount;
    }
  }

  // Funcion
  Future<void> saveTransaction() async {
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String? imageURL;
    if (ticketImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("tickets/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await storageRef.putFile(ticketImage!);
      imageURL = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection("transactions").add({
      "title": titleCtrl.text,
      "amount": double.tryParse(amountCtrl.text) ?? 0,
      "date": DateTime.now(),
      "type": transactionType,
      "imageUrl": imageURL,
    });

    // mensaje 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$transactionType registrado correctamente ✅",
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: transactionType == "Gasto" ? Colors.green : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    titleCtrl.clear();
    amountCtrl.clear();
    setState(() {
      ticketImage = null;
      transactionType = "Gasto";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Agregar Transacción"),
        backgroundColor: const Color.fromARGB(255, 85, 58, 202),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selector 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Gasto"),
                  selected: transactionType == "Gasto",
                  onSelected: (_) => setState(() => transactionType = "Gasto"),
                  selectedColor: const Color.fromARGB(255, 228, 220, 220),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Ingreso"),
                  selected: transactionType == "Ingreso",
                  onSelected: (_) => setState(() => transactionType = "Ingreso"),
                  selectedColor: const Color.fromARGB(255, 228, 220, 220),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Contenedor 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Monto",
                      prefixText: "L. ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contenedor de foto
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: ticketImage == null
                    ? const Center(
                        child: Text(
                          "Toca para tomar foto del ticket",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(ticketImage!,
                            fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            if (loadingOCR) const CircularProgressIndicator(),

            const SizedBox(height: 20),

            
            ElevatedButton(
              onPressed: saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Guardar Transacción",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
