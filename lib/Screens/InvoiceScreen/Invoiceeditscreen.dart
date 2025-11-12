import 'package:ezzybill/DataBase/firebaseDatabase.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/widgetsCommon/BgWidget.dart';
import 'package:ezzybill/widgetsCommon/CustomTextFieldInvoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InvoiceEditScreen extends StatefulWidget {
  @override
  State<InvoiceEditScreen> createState() => _InvoiceEditScreenState();
}

class _InvoiceEditScreenState extends State<InvoiceEditScreen> {
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchAllShopData().then((data) {
      if (data.isNotEmpty) {
        // Set values to controllers (show latest or first)
        shopnameController.text = data[0]["shop_name"] ?? "";
        retailerController.text = data[0]["retailer"] ?? "";
        websiteController.text = data[0]["website"] ?? "";
      }
    });
  }

  final shopnameController = TextEditingController(text: shopname);
  final retailerController = TextEditingController(text: retailer);
  final websiteController = TextEditingController(text: website);

  @override
  void dispose() {
    shopnameController.dispose();
    retailerController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

    return BgWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Center(
            child: Text(
              "Customize Invoice       ",
              style: TextStyle(
                color: primaryColor,
                fontSize: screenWidth * 0.06,
              ),
            ),
          ),
          backgroundColor: secondaryColor,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(50),
                                  bottomLeft: Radius.circular(50)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isEditing ? 'Disable' : 'Enable',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Switch(
                                  value: isEditing,
                                  onChanged: (value) async {
                                    setState(() {
                                      isEditing = value;
                                    });

                                    if (!isEditing) {
                                      // Save only when editing is turned OFF
                                      await saveShopDetails(
                                        shopnameController.text,
                                        retailerController.text,
                                        websiteController.text,
                                      );
                                    }
                                  },
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

// invoice
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: isEditing
                                ? customTextFieldInvoice(
                                    controller: shopnameController,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05,
                                  )
                                : Text(
                                    shopnameController.text,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.05),
                                  ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Center(
                            child: isEditing
                                ? customTextFieldInvoice(
                                    controller: retailerController)
                                : Text(retailerController.text),
                          ),
                          Divider(),
                          Text(
                            "$invoice $detail",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Date: $formattedDate"),
                          Text("Bill No: 00"),
                          Text("Cashier: 60778457"),
                          Divider(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.005),
                                child: Row(
                                  children: [
                                    Text("item $index"),
                                    Spacer(),
                                    Text(
                                      "$index x ₹100",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: screenWidth * 0.05),
                                    Text(
                                        "₹${(index * 100).toStringAsFixed(2)}"),
                                  ],
                                ),
                              );
                            },
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045)),
                              Text("₹600",
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.045)),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Center(
                            child: Column(
                              children: [
                                Text("Scan to Pay via UPI",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: screenHeight * 0.015),
                                QrImageView(
                                  data: "QR Expired",
                                  size: screenWidth * 0.45,
                                  backgroundColor: Colors.white,
                                ),
                                Text("UPI ID: $upiId"),
                              ],
                            ),
                          ),
                          Text("Payment Reference: T42I103000224012025"),
                          Text("Tax Invoice: T42I10325501399"),
                          Divider(),
                          Center(
                            child: Text("Thank You for Shopping with Us!",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Center(
                            child: isEditing
                                ? customTextFieldInvoice(
                                    controller: websiteController,
                                    color: Colors.blue)
                                : Text("Visit: ${websiteController.text}",
                                    style: TextStyle(color: Colors.blue)),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO
                              },
                              child: Text("Print Invoice",
                                  style:
                                      TextStyle(fontSize: screenWidth * 0.04)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
