import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/transaction_controller.dart';
import 'transaction_detail_page.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TransactionController controller = TransactionController();

  final TextEditingController noteCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  bool loadingOCR = false;
  bool uploading = false;
  String transactionType = "Gasto";
  String infoMsg = "";

  Future<void> pickTicketImage() async {
    infoMsg = "";
    await controller.pickImage();

    setState(() {
      loadingOCR = true;
    });

    if (controller.ticketImageFile != null) {
      final detected = await controller.detectAmount();
      setState(() => loadingOCR = false);

      if (detected != null) {
        amountCtrl.text = detected;
        infoMsg = "Monto detectado automáticamente.";
      } else {
        infoMsg =
            "No se detectó el monto en el ticket. Ingresa el valor manualmente.";
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se detectó el total en el ticket"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        loadingOCR = false;
        amountCtrl.text = "";
        infoMsg = "No se seleccionó ninguna imagen.";
      });
    }
  }

  Future<void> saveTransaction() async {
    if (noteCtrl.text.isEmpty || amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => uploading = true);

    try {
      final docRef = await controller.saveTransactionWithPhoto(
        note: noteCtrl.text,
        amount: double.tryParse(amountCtrl.text) ?? 0,
        type: transactionType == "Ingreso" ? "income" : "expense",
      );

      final doc = await docRef.get();
      final transaction = doc.data() as Map<String, dynamic>;

      noteCtrl.clear();
      amountCtrl.clear();
      controller.clearImage();
      setState(() {
        transactionType = "Gasto";
        infoMsg = "";
        uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Transacción guardada"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(transaction: transaction),
        ),
      );
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    } else {
      return const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 40, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text("Toca para tomar foto del ticket"),
          ],
        ),
      );
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
                  label: Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.red),
                      const SizedBox(width: 5),
                      const Text("Gasto"),
                    ],
                  ),
                  selected: transactionType == "Gasto",
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) {
                    setState(() => transactionType = "Gasto");
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green),
                      const SizedBox(width: 5),
                      const Text("Ingreso"),
                    ],
                  ),
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
              controller: noteCtrl,
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
            if (infoMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  infoMsg,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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
            if (uploading)
              Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Subiendo y guardando..."),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: uploading ? null : saveTransaction,
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
