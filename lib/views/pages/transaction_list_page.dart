import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker_ocr/controllers/transaction_list_controller.dart';
import 'package:flutter_expense_tracker_ocr/core/constants/colors.dart';
import 'package:intl/intl.dart';
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
        backgroundColor: tWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: Text(
          "Confirmar eliminación",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: tDarkColor,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "¿Seguro que deseas eliminar esta transacción?\n"
          "Esta acción no se puede deshacer.",
          style: TextStyle(fontSize: 14, color: tDarkColor),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar", style: TextStyle(color: tWhiteColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.deleteTransaction(id);
                    await controller.fetchInitial();
                    setState(() {});
                  },
                  child: Text("Eliminar", style: TextStyle(color: tWhiteColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: buildList()),
          buildPagination(),
        ],
      ),
    );
  }

  Widget buildList() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (controller.isLoading && controller.transactions.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? tWhiteColor : tDarkColor,
        ),
      );
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
        final Color amountColor = type == "expense" ? Colors.red : Colors.green;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: amountColor.withOpacity(0.1),
              child: Icon(
                type == "expense" ? Icons.arrow_downward : Icons.arrow_upward,
                color: amountColor,
              ),
            ),
            title: Text(
              "L. ${amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: amountColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat("dd/MM/yyyy HH:mm").format(date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                  tooltip: "Detalles",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionDetailPage(transaction: data),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Eliminar",
                  onPressed: () => confirmDelete(doc.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildPagination() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: Text(
              "Anterior",
              style: TextStyle(color: isDarkMode ? tWhiteColor : tDarkColor),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: controller.hasMorePrev && !controller.isLoading
                ? () async {
                    await controller.fetchPrevious();
                    setState(() {});
                  }
                : null,
          ),
          const SizedBox(width: 20),
          Text(
            "Página ${controller.currentPage}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? tWhiteColor : tDarkColor,
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: Text(
              "Siguiente",
              style: TextStyle(color: isDarkMode ? tWhiteColor : tDarkColor),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: controller.hasMoreNext && !controller.isLoading
                ? () async {
                    await controller.fetchNext();
                    setState(() {});
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
