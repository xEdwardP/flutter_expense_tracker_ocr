import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/transaction_controller.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TransactionController controller = TransactionController();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  File? ticketImage;
  bool loadingOCR = false;
  String transactionType = "Gasto";

  Future<void> pickTicketImage() async {
    final image = await controller.pickImage();
    if (image == null) return;

    setState(() {
      ticketImage = image;
      loadingOCR = true;
    });

    final detected = await controller.detectAmount(image);

    setState(() => loadingOCR = false);

    if (detected != null) {
      amountCtrl.text = detected;
    }
  }

  Future<void> saveTransaction() async {
    if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await controller.saveTransaction(
      title: titleCtrl.text,
      amount: double.tryParse(amountCtrl.text) ?? 0,
      type: transactionType,
      ticketImage: ticketImage,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$transactionType guardado correctamente"),
        backgroundColor: Colors.green,
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Gasto"),
                  selected: transactionType == "Gasto",
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) {
                    setState(() => transactionType = "Gasto");
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Ingreso"),
                  selected: transactionType == "Ingreso",
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) {
                    setState(() => transactionType = "Ingreso");
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.note),
                labelText: "Nota",
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
                prefixIcon: const Icon(Icons.monetization_on),
                labelText: "Monto",
                prefixText: "L. ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickTicketImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: ticketImage == null
                    ? const Center(
                        child: Text("Toca para tomar foto del ticket"),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          ticketImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (loadingOCR) const CircularProgressIndicator(),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: saveTransaction,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Transacción"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
