import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseHomeData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Count unique customers based on 'sales' collection
  Future<int> getActiveCustomers() async {
    final formattedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());

    final entriesSnapshot = await _db
        .collection("sales")
        .doc(formattedDate)
        .collection("entries")
        .get();

    return entriesSnapshot.docs.length;
  }

  // Count inventory items with low stock
  Future<int> getTotalStockItems(int threshold) async {
    final query = await _db.collection("food_items").get();
    return query.docs.length;
  }

  // Total pending payments (PaymentMethod = Pending in sales)
  Future<num> getPendingPaymentsTotal() async {
    final query = await _db
        .collection("invoices")
        .where("status", isEqualTo: false)
        .get();
    num total = 0;
    for (var doc in query.docs) {
      final amount = doc.data()["total_amount"];
      if (amount != null) {
        total += amount;
      }
    }
    return total;
  }

  // Count invoices where status == false (unsent)
  Future<int> getUnsentInvoicesCount() async {
    final query = await _db
        .collection("invoices")
        .where("status", isEqualTo: false)
        .get();
    return query.docs.length;
  }
}
