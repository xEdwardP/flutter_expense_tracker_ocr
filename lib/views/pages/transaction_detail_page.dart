import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'];
    final date = transaction['date'];
    final type = transaction['type'];
    final note = transaction['note'] ?? "Sin nota";
    final imageUrl = transaction['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Transacción"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(
                      "Monto: L. $amount",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text("Fecha: $date", style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(type == "income" ? "Tipo de Transaccion: Ingreso" : "Tipo de Transaccion: Gasto", style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Expanded(child: Text("Nota: $note", style: const TextStyle(fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 16),

                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text("No se pudo cargar la imagen");
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}