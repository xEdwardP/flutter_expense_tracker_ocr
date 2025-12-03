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
  final TransactionController controller = TransactionController();

  @override
  void initState() {
    super.initState();
    loadTransactions(initial: true);
  }

  Future<void> loadTransactions({bool initial = false, bool next = true}) async {
    setState(() {
      controller.isLoading = true;
    });

    await controller.fetchTransactions(initial: initial, next : next);
    setState(() {});
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Eliminar transacción"),
        content: const Text(
            "¿Seguro que deseas eliminar esta transacción? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteTransaction(id);
              await loadTransactions(initial: true);
            },
            child: const Text("Eliminar"),
          ),
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
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.transactions.isEmpty
                    ? const Center(child: Text("No hay transacciones"))
                    : ListView.builder(
                        itemCount: controller.transactions.length,
                        itemBuilder: (context, index) {
                          final doc = controller.transactions[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final amountColor =
                              data['type'] == 'income' ? Colors.green : Colors.red;

                          DateTime date;
                          if (data['date'] is Timestamp) {
                            date = (data['date'] as Timestamp).toDate();
                          } else if (data['date'] is String) {
                            date = DateTime.parse(data['date'] as String);
                          } else {
                            date = DateTime.now();
                          }

                          final formattedDate = DateFormat('dd/MM/yy - HH:mm').format(date);

                          return ListTile(
                            title: Text(
                              'L. ${data['amount']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: amountColor),
                            ),
                            subtitle: Text(formattedDate),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                  child: const Text("Ver"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => confirmDelete(doc.id),
                                  child: const Text("Borrar"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (!controller.isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: controller.hasMorePrev
                      ? () => loadTransactions(next: false)
                      : null,
                  child: const Text("Anterior"),
                ),
                const SizedBox(width: 20),
                Text("Página ${controller.currentPage}"),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: controller.hasMoreNext
                      ? () => loadTransactions(next: true)
                      : null,
                  child: const Text("Siguiente"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
