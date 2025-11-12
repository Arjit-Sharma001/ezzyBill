// Same imports
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:ezzybill/DataBase/firebaseDatabase.dart';
import 'package:ezzybill/DataBase/invoicesHistory.dart';
import 'package:ezzybill/Screens/InvoiceScreen/PaymentScreen.dart';
import 'package:ezzybill/widgetsCommon/BgWidget.dart';
import 'package:ezzybill/consts/consts.dart';

class Invoicescreen extends StatefulWidget {
  final List<int> itemCounts;
  final double totalAmount;
  final List<FoodItem_firebase> foodItemList;
  final int billNo;

  const Invoicescreen({
    required this.itemCounts,
    required this.totalAmount,
    required this.foodItemList,
    required this.billNo,
    Key? key,
  }) : super(key: key);

  @override
  State<Invoicescreen> createState() => _InvoicescreenState();
}

class _InvoicescreenState extends State<Invoicescreen> {
  final uuid = Uuid();
  late final String paymentReference = uuid.v4();
  late final String taxInvoice = uuid.v4();
  late final String formattedDate =
      DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  List<Map<String, String>> shopData = [];
  List<Map<String, String>> savedUpis = [];

  String shopname = '';
  String retailer = '';
  String website = '';
  String selectedUpiId = '';
  String selectedPayeeName = '';
  int selectedUpiIndex = 0;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final shops = await fetchAllShopData();
    final upis = await fetchAllPaymentOptions();
    setState(() {
      shopData = shops;
      savedUpis = upis;
      if (shopData.isNotEmpty) {
        shopname = shopData[0]["shop_name"] ?? "";
        retailer = shopData[0]["retailer"] ?? "";
        website = shopData[0]["website"] ?? "";
      }
      if (savedUpis.isNotEmpty) {
        selectedUpiId = savedUpis[0]['upi_id'] ?? '';
        selectedPayeeName = savedUpis[0]['payee_name'] ?? '';
      }
    });
  }

  void _showUpiSelector() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    Wrap(
                      spacing: 10,
                      children: List.generate(savedUpis.length, (index) {
                        final upi = savedUpis[index];
                        return ChoiceChip(
                          label: Text(upi['payee_name'] ?? ''),
                          selected: selectedUpiIndex == index,
                          onSelected: (_) {
                            setState(() {
                              selectedUpiIndex = index;
                              selectedUpiId = upi['upi_id'] ?? '';
                              selectedPayeeName = upi['payee_name'] ?? '';
                            });
                            Navigator.of(context).pop();
                          },
                          selectedColor: primaryColor,
                          checkmarkColor: greencolor,
                          labelStyle: TextStyle(
                            color: selectedUpiIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    IconButton(
                      onPressed: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PaymentScreen()),
                        );
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            savedUpis.add(result);
                            selectedUpiId = result['upi_id']!;
                            selectedPayeeName = result['payee_name']!;
                            selectedUpiIndex = savedUpis.length - 1;
                          });
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (mounted) Navigator.of(context).pop();
                          });
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveInvoice() async {
    if (isSaving) return;
    setState(() => isSaving = true);

    await saveInvoiceToFirestore(
      billNo: widget.billNo,
      totalAmount: widget.totalAmount,
      item: widget.foodItemList,
      itemCounts: widget.itemCounts,
      time: formattedDate,
    );

    setState(() => isSaving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invoice saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Center(
              child: Text("Invoice",
                  style: TextStyle(
                      color: primaryColor, fontSize: screenWidth * 0.06))),
          backgroundColor: secondaryColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _showUpiSelector,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        bottomLeft: Radius.circular(50)),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(icUpi, height: 20),
                      const Text("Change UPI"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(shopname,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20))),
                      Center(child: Text(retailer)),
                      const Divider(),
                      Text("$invoice $detail",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Date: $formattedDate"),
                      Text("Bill No: ${widget.billNo}"),
                      const Text("Cashier: 60778457"),
                      const Divider(),
                      ...List.generate(widget.foodItemList.length, (index) {
                        final item = widget.foodItemList[index];
                        final count = widget.itemCounts[index];
                        if (count <= 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(item.name),
                              const Spacer(),
                              Text("$count x ₹${item.price}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: screenWidth * 0.08),
                              Text(
                                  "₹${(count * item.price).toStringAsFixed(2)}"),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("₹${widget.totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Column(
                          children: [
                            const Text("Scan to Pay via UPI",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            QrImageView(
                              data:
                                  "upi://pay?pa=$selectedUpiId&pn=$selectedPayeeName&am=${widget.totalAmount.toStringAsFixed(2)}&cu=INR",
                              size: 180,
                              backgroundColor: Colors.white,
                            ),
                            Text("UPI ID: $selectedUpiId"),
                          ],
                        ),
                      ),
                      Text("Payment Reference: $paymentReference"),
                      Text("Tax Invoice: $taxInvoice"),
                      const Divider(),
                      const Center(
                          child: Text("Thank You for Shopping with Us!",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Center(
                          child: Text("Visit: $website",
                              style: const TextStyle(color: Colors.blue))),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveInvoice,
                          child: Text(isSaving ? "Saving..." : "Print Invoice"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
