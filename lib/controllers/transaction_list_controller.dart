import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionController {
  final int pageSize = 6;
  DocumentSnapshot? lastDocument;
  DocumentSnapshot? firstDocument;
  int currentPage = 1;

  List<DocumentSnapshot> transactions = [];
  bool hasMoreNext = true;
  bool hasMorePrev = false;

  bool isLoading = false;

  Future<void> fetchTransactions({bool next = true, bool initial = false}) async {
    isLoading = true;

    final user = FirebaseAuth.instance.currentUser;

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user?.uid)
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
      transactions = snapshot.docs;
      firstDocument = snapshot.docs.first;
      lastDocument = snapshot.docs.last;

      if (!initial) {
        if (next) {
          currentPage++;
        } else {
          currentPage--;
        }
      }

      hasMoreNext = snapshot.docs.length == pageSize;
      hasMorePrev = currentPage > 1;
    }

    isLoading = false;
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
  }
}
