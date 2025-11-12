import 'package:ezzybill/DataBase/firebaseDatabase.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/widgetsCommon/CustomTextFieldAuth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final upiIdController = TextEditingController();
  final payeeNameController = TextEditingController();

  bool _isUpiIdValid = false;
  bool _isUpiIdEmpty = true;

  static final RegExp _upiIdRegExp =
      RegExp(r"^[a-zA-Z0-9.\-]+@[a-zA-Z]{2,64}$");

  String? _validateUpiId(String? value) {
    if (value == null || value.isEmpty) {
      return 'UPI ID cannot be empty';
    }
    if (!_upiIdRegExp.hasMatch(value)) {
      return 'Enter a valid UPI ID (e.g., example@bankname)';
    }
    return null;
  }

  void _updateUpiIdValidityAndEmptyState() {
    setState(() {
      _isUpiIdEmpty = upiIdController.text.isEmpty;
      _isUpiIdValid = _validateUpiId(upiIdController.text) == null;
    });
  }

  @override
  void initState() {
    super.initState();
    upiIdController.addListener(_updateUpiIdValidityAndEmptyState);
    Future.microtask(() {
      _updateUpiIdValidityAndEmptyState();
    });
  }

  @override
  void dispose() {
    upiIdController.removeListener(_updateUpiIdValidityAndEmptyState);
    upiIdController.dispose();
    payeeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New UPI ID"),
        backgroundColor: secondaryColor,
        iconTheme: const IconThemeData(color: whiteColor),
        // Responsive title text style
        titleTextStyle: TextStyle(
            color: primaryColor,
            fontSize: screenWidth *
                0.055, // Adjust font size relative to screen width
            fontWeight: FontWeight.bold),
      ),
      body: Padding(
        // Responsive padding around the body content
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: customTextFieldAuth(
                      controller: upiIdController,
                      title: "UPI ID",
                      hint: "Enter UPI ID",
                      Controller: (value) => _validateUpiId(value),
                    ),
                  ),
                  Padding(
                    // Responsive padding to align icon
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.02, bottom: screenHeight * 0.015),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: _isUpiIdEmpty
                          ? Colors.grey
                          : (_isUpiIdValid ? Colors.green : Colors.red),
                      size: screenWidth * 0.07, // Responsive icon size
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.025), // Responsive spacing
              customTextFieldAuth(
                controller: payeeNameController,
                title: "Payee Name",
                hint: "Enter Payee Name",
                Controller: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Payee Name cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.04), // Responsive spacing
              ElevatedButton(
                onPressed: _isUpiIdValid
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          await addUpiId(upiIdController.text.trim(),
                              payeeNameController.text.trim());

                          if (mounted) {
                            // ✅ This sends the new UPI data back to the previous screen
                            Navigator.of(context).pop({
                              'upi_id': upiIdController.text.trim(),
                              'payee_name': payeeNameController.text.trim(),
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("UPI ID added successfully")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please correct the errors")),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isUpiIdValid ? primaryColor : Colors.grey,
                  // Responsive button padding
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Add UPI ID",
                  style: TextStyle(
                      color: whiteColor,
                      fontSize:
                          screenWidth * 0.04), // Responsive button text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
