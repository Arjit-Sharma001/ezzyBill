import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ezzybill/consts/firebaseConst.dart';
import 'package:ezzybill/consts/images.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Your model class
class FoodItem_firebase {
  final String id;
  final String name;
  final int price;
  final String imageUrl;
  final String category;

  FoodItem_firebase({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  factory FoodItem_firebase.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem_firebase(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
    );
  }
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Local fallback list
final List<Map<String, dynamic>> FooditemList_local = [
  {'image': 'icNoimage', 'name': 'No Item', 'quantity': 2, 'price': 00},
  {'image': 'icNoimage', 'name': 'No Item', 'quantity': 1, 'price': 00},
];

// Convert local list to model list
final List<FoodItem_firebase> localFoodItems = FooditemList_local.map((item) {
  return FoodItem_firebase(
    id: '', // Empty or local ID if needed
    name: item['name'],
    price: item['price'],
    imageUrl: item['image'],
    category: 'Local', // Optional fallback category
  );
}).toList();

// Fetch function with fallback
Future<List<FoodItem_firebase>> fetchFoodItems() async {
  try {
    final snapshot = await _firestore
        .collection('food_items')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return localFoodItems;
    }

    return snapshot.docs
        .map((doc) => FoodItem_firebase.fromDocument(doc))
        .toList();
  } catch (e) {
    print('Firebase fetch failed: $e');
    return localFoodItems;
  }
}

// Fetching Profile name and email
Future<Map<String, String>> fetchUserData() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return {
        "name": "Dummy user",
        "email": "user@example.com",
        "profileUrl": icProfile,
      };
    }

    final doc = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(uid)
        .get();

    if (doc.exists) {
      return {
        "name": doc.data()?['name'] ?? "Dummy user",
        "email": doc.data()?['email'] ?? "user@example.com",
        "profileUrl": doc.data()?['profileUrl'] ?? icProfile,
      };
    } else {
      return {
        "name": "Dummy user",
        "email": "user@example.com",
        "profileUrl": icProfile,
      };
    }
  } catch (e) {
    print("Error fetching user data: $e");
    return {
      "name": "Dummy user",
      "email": "user@example.com",
      "profileUrl": icProfile,
    };
  }
}

//Profile Edit
Future<void> saveUserData(Map<String, dynamic> data) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

  try {
    await userDoc.set(data, SetOptions(merge: true));
  } catch (e, stacktrace) {
    print("❌ Error saving user data: $e");
    print("Stacktrace: $stacktrace");
  }
}

Future<String?> changeUserPassword({
  required String oldPassword,
  required String newPassword,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return "User not logged in.";
    }

    // Reauthenticate
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(cred);

    // Update password
    await user.updatePassword(newPassword);
    return null; // null means success
  } on FirebaseAuthException catch (e) {
    return e.message ?? "Password update failed.";
  } catch (e) {
    return "Unexpected error: $e";
  }
}

// Saving Shop data
Future<void> saveShopDetails(
    String shopname, String retailer, String website) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    print("No user logged in");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shop_details')
        .doc('l9ADbRsJTvsWrEkUjtYp')
        .set(
      {
        'shop_name': shopname.trim(),
        'retailer': retailer.trim(),
        'website': website.trim(),
      },
    );

    print("UPI added successfully");
  } catch (e) {
    print("Error adding UPI: $e");
  }
}

// Fetching Shop Details
Future<List<Map<String, String>>> fetchAllShopData() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shop_details')
        .get();

    List<Map<String, String>> shopDetails = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      shopDetails.add({
        "shop_name": data["shop_name"] ?? "",
        "retailer": data["retailer"] ?? "",
        "website": data["website"] ?? "",
      });
    }

    return shopDetails;
  } catch (e) {
    print("Error fetching shop details: $e");
    return [];
  }
}

// Saving payment data
Future<void> addUpiId(String upiId, String payeeName) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    print("No user logged in");
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('payment_details')
        .doc('upi')
        .set({
      payeeName.trim(): {
        'upi_id': upiId.trim(),
      }
    }, SetOptions(merge: true));

    print("UPI added successfully");
  } catch (e) {
    print("Error adding UPI: $e");
  }
}

// Fetching Payment Options
Future<List<Map<String, String>>> fetchAllPaymentOptions() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('payment_details')
        .doc('upi')
        .get();

    if (!docSnapshot.exists) return [];

    final data = docSnapshot.data()!;
    List<Map<String, String>> upiList = [];

    data.forEach((payeeName, upiDetails) {
      if (upiDetails is Map && upiDetails.containsKey('upi_id')) {
        upiList.add({
          "payee_name": payeeName,
          "upi_id": upiDetails['upi_id'].toString(),
        });
      }
    });

    return upiList;
  } catch (e) {
    print("Error fetching UPI options: $e");
    return [];
  }
}
