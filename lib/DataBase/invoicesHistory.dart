import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveInvoiceToFirestore({
  required int billNo,
  required double totalAmount,
  required item,
  required List<int> itemCounts,
  required String time,
}) async {
  final firestore = FirebaseFirestore.instance;

  // Build invoice items list 
  final List<Map<String, dynamic>> items = [];

  for (int i = 0; i < item.length; i++) {
    if (itemCounts[i] > 0) {
      items.add({
        'name': item[i].name,
        'price': item[i].price,
        'quantity': itemCounts[i],
        'subtotal': itemCounts[i] * item[i].price,
      });
    }
  }

  final invoiceData = {
    'bill_no': billNo,
    'status': false,
    'timestamp': FieldValue.serverTimestamp(),
    'total_amount': totalAmount,
    'items': items,
  };

  final invoiceRef =
      firestore.collection('invoices').doc("bill_no: $billNo"); // Auto ID
  await invoiceRef.set(invoiceData);
}

//Fatch last Bill num
Future<int> fetchLastBillNoFromFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore
      .collection('invoices')
      .orderBy('bill_no', descending: true)
      .limit(1)
      .get();
  if (snapshot.docs.isNotEmpty) {
    final data = snapshot.docs.first.data();
    return data['bill_no'] ?? 1;
  } else {
    return 0;
  }
}

//Fatch invoices data
Future<List<Map<String, dynamic>>> fetchInvoicesFromFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('invoices').get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return {
      'bill_no': data['bill_no'],
      'status': data['status'],
      'total_amount': data['total_amount'],
      'timestamp': data['timestamp'],
      'items': List<Map<String, dynamic>>.from(data['items']),
    };
  }).toList();
}

Future<void> markInvoiceAsReceived(int billNo, bool status) async {
  final collection = FirebaseFirestore.instance.collection('invoices');
  final snapshot = await collection.where('bill_no', isEqualTo: billNo).get();

  if (snapshot.docs.isNotEmpty) {
    final docId = snapshot.docs.first.id;
    await collection.doc(docId).update({'status': status});
  }
}
