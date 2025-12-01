import 'package:flutter/foundation.dart';
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

  bool loadingOCR = false;
  String transactionType = "Gasto";

  Future<void> pickTicketImage() async {
    await controller.pickImage();

    setState(() {
      loadingOCR = true;
    });

    final detected = await controller.detectAmount();

    setState(() => loadingOCR = false);

    if (detected != null) {
      amountCtrl.text = detected;
    } else if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se detectó el total en el ticket"),
          backgroundColor: Colors.red,
        ),
      );
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
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$transactionType guardado correctamente"),
        backgroundColor: Colors.green,
      ),
    );

    titleCtrl.clear();
    amountCtrl.clear();
    controller.clearImage();
    setState(() {
      transactionType = "Gasto";
    });
  }

  Widget _imagePreview() {
    if (controller.ticketImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(
          controller.ticketImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (controller.ticketImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          controller.ticketImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else {
      return const Center(child: Text("Toca para tomar/subir foto del ticket"));
    }
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
                child: _imagePreview(),
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
