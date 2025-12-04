import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionController {
  final int pageSize = 6;
  
  final List<DocumentSnapshot> pageStartStack = [];

  bool isLoading = false;
  bool hasMoreNext = true;
  bool hasMorePrev = false;

  List<DocumentSnapshot> transactions = [];
  DocumentSnapshot? lastDocument;

  int currentPage = 1;

  Future<void> fetchInitial() async {
    pageStartStack.clear();
    lastDocument = null;
    currentPage = 1;

    await _fetchPage(isNext: true, isInitial: true);
  }

  Future<void> fetchNext() async {
    if (!hasMoreNext || isLoading) return;
    await _fetchPage(isNext: true);
  }

  Future<void> fetchPrevious() async {
    if (!hasMorePrev || isLoading) return;
    await _fetchPage(isNext: false);
  }

  Future<void> _fetchPage({required bool isNext, bool isInitial = false}) async {
    isLoading = true;

    final user = FirebaseAuth.instance.currentUser;

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('date', descending: true)
        .limit(pageSize);

    if (isNext && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    if (!isNext) {
      if (pageStartStack.length >= 2) {
        pageStartStack.removeLast();
        final previousStart = pageStartStack.last;

        query = query.startAtDocument(previousStart);
      }
    }

    final snapshot = await query.get();
    transactions = snapshot.docs;

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;

      if (isNext || isInitial) {
        pageStartStack.add(snapshot.docs.first);
      }

      if (!isInitial) {
        currentPage += isNext ? 1 : -1;
      }
    }

    hasMoreNext = snapshot.docs.length == pageSize;
    hasMorePrev = currentPage > 1 && pageStartStack.length > 1;

    isLoading = false;
  }

  Future<void> deleteTransaction(String id) async {
    await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
  }
}
