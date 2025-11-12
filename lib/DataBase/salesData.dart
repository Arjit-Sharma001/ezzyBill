import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Automatically creates the document if it doesn't exist.
Future<void> updateTotalSales(int billNo, double amount) async {
  final firestore = FirebaseFirestore.instance;

  final String todayKey = getTodayKey(); // e.g. 05-12-2025
  final String monthKey = getMonthKey(); // e.g. 05-2025

  final todayRef = firestore.collection('sales').doc(todayKey);
  final monthRef = firestore
      .collection('sales')
      .doc('monthly')
      .collection('months')
      .doc(monthKey);

  await firestore.runTransaction((transaction) async {
    final todaySnap = await transaction.get(todayRef);
    final monthSnap = await transaction.get(monthRef);

    final todayTotal =
        todaySnap.exists ? (todaySnap.data()?['total_sale'] ?? 0) : 0;
    transaction.set(
        todayRef, {'total_sale': todayTotal + amount}, SetOptions(merge: true));

    final monthTotal =
        monthSnap.exists ? (monthSnap.data()?['total_sale'] ?? 0) : 0;
    transaction.set(
        monthRef, {'total_sale': monthTotal + amount}, SetOptions(merge: true));
  });

  await firestore.collection('sales').doc(todayKey).collection('entries').add({
    'bill_no': billNo,
    'amount': amount,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

/// Returns today's date key in 'yyyy-MM-dd' format.
String getTodayKey() {
  return DateFormat('MM-dd-yyyy').format(DateTime.now());
}

String getMonthKey() {
  return DateFormat('MM-yyyy').format(DateTime.now());
}

Future<double> fetchTodayTotalSales() async {
  final doc = await FirebaseFirestore.instance
      .collection('sales')
      .doc(getTodayKey())
      .get();

  if (doc.exists && doc.data()?['total_sale'] != null) {
    return (doc.data()!['total_sale'] as num).toDouble();
  }
  return 0.0;
}

Future<double> fetchMonthlyTotalSales() async {
  final doc = await FirebaseFirestore.instance
      .collection('sales')
      .doc('monthly')
      .collection('months')
      .doc(getMonthKey())
      .get();

  if (doc.exists && doc.data()?['total_sale'] != null) {
    return (doc.data()!['total_sale'] as num).toDouble();
  }
  return 0.0;
}

Future<Map<String, double>> fetchMonthlySales() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('sales')
      .doc('monthly')
      .collection('months')
      .get();

  Map<String, double> monthlySales = {};
  for (var doc in snapshot.docs) {
    final month = doc.id; // e.g., '06-2025'
    final sale = doc.data()['total_sale']?.toDouble() ?? 0.0;
    monthlySales[month] = sale;
  }

  return monthlySales;
}
