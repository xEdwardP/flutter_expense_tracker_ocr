import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/transaction_list_controller.dart';
import 'transaction_detail_page.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final controller = TransactionController();

  @override
  void initState() {
    super.initState();
    controller.fetchInitial().then((_) => setState(() {}));
  }

  Future<void> confirmDelete(String id) async {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 48,
      ),
      title: const Text("Confirmar eliminación"),
      content: const Text(
        "¿Seguro que deseas eliminar esta transacción?"
        " Esta acción no se puede deshacer."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await controller.deleteTransaction(id);
            await controller.fetchInitial();
            setState(() {});
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Eliminar"),
        )
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transacciones")),
      body: Column(
        children: [
          Expanded(child: buildList()),
          buildPagination(),
        ],
      ),
    );
  }

  Widget buildList() {
    if (controller.isLoading && controller.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final doc = controller.transactions[index];
        final data = doc.data() as Map<String, dynamic>;

        DateTime date;
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        } else {
          date = DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
        }

        final double amount = (data["amount"] ?? 0).toDouble();

        final String type = data["type"] ?? "income";

        final Color amountColor =
            type == "expense" ? Colors.red : Colors.green;

        return ListTile(
          title: Text(
            "L. ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: amountColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(DateFormat("dd/MM/yyyy HH:mm").format(date)),

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Detalles
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailPage(
                        transaction: data,
                      ),
                    ),
                  );
                },
                child: const Text("Detalles"),
              ),
              const SizedBox(width: 10),

              // Botón Eliminar
              ElevatedButton(
                onPressed: () => confirmDelete(doc.id),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Eliminar"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: controller.hasMorePrev && !controller.isLoading
                ? () async {
                    await controller.fetchPrevious();
                    setState(() {});
                  }
                : null,
            child: const Text("Anterior"),
          ),
          const SizedBox(width: 20),
          Text("Página ${controller.currentPage}",
              style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: controller.hasMoreNext && !controller.isLoading
                ? () async {
                    await controller.fetchNext();
                    setState(() {});
                  }
                : null,
            child: const Text("Siguiente"),
          ),
        ],
      ),
    );
  }
}

