import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transaction_detail_page.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final int pageSize = 6;
  DocumentSnapshot? lastDocument;
  DocumentSnapshot? firstDocument;
  List<DocumentSnapshot> transactions = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreNext = true;
  bool hasMorePrev = false;

  @override
  void initState() {
    super.initState();
    fetchTransactions(initial: true);
  }

  Future<void> fetchTransactions({
    bool next = true,
    bool initial = false,
  }) async {
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(pageSize);

    if (initial) {
      lastDocument = null;
      firstDocument = null;
      currentPage = 1;
    }

    if (next && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    } else if (!next && firstDocument != null) {
      query = query.endBeforeDocument(firstDocument!).limitToLast(pageSize);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        transactions = snapshot.docs;
        firstDocument = snapshot.docs.first;
        lastDocument = snapshot.docs.last;

        if (!initial) {
          if (next)
            currentPage += 1;
          else
            currentPage -= 1;
        }

        hasMoreNext = snapshot.docs.length == pageSize;
        hasMorePrev = currentPage > 1;
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(id)
        .delete();
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 10),
            Text(
              "Eliminar transacción",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.info_outline, color: Colors.grey, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "¿Seguro que deseas eliminar esta transacción?\n"
                "Esta acción no se puede deshacer.",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey),
            label: const Text("Cancelar"),
          ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(150, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await deleteTransaction(id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text("Transacción eliminada correctamente"),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );

                fetchTransactions(initial: true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Row(
                      children: const [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 10),
                        Text("Error eliminando transacción"),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              "Transacciones",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No hay transacciones"))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final doc = transactions[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final amountColor = data['type'] == 'income'
                          ? Colors.green
                          : Colors.red;

                      final timestamp = data['date'] as Timestamp;
                      final date = timestamp.toDate();
                      final formattedDate = DateFormat('dd/MM/yy - HH:mm').format(date);

                      return ListTile(
                        title: Text(
                          'L. ${data['amount']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                          ),
                        ),
                        subtitle: Text(formattedDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                minimumSize: const Size(90, 40),
                              ),
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
                              icon: const Icon(Icons.info),
                              label: const Text("Ver"),
                            ),

                            const SizedBox(width: 8),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(90, 40),
                              ),
                              onPressed: () => confirmDelete(doc.id),
                              icon: const Icon(Icons.delete),
                              label: const Text("Borrar"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: hasMorePrev
                    ? () => fetchTransactions(next: false)
                    : null,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(120, 40),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Anterior"),
              ),

              const SizedBox(width: 20),

              Text(
                "Página $currentPage",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(width: 20),

              ElevatedButton.icon(
                onPressed: hasMoreNext
                    ? () => fetchTransactions(next: true)
                    : null,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(120, 40),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Siguiente"),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
