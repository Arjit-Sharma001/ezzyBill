import 'package:ezzybill/Controller/AuthController.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgetsCommon/AppLogo.dart';
import '../../../widgetsCommon/BgWidget.dart';
import '../../../widgetsCommon/ButtonComm.dart';
import '../../widgetsCommon/CustomTextFieldAuth.dart';

class passwordForgetScreen extends StatefulWidget {
  @override
  State<passwordForgetScreen> createState() => _passwordForgetScreen();
}

class _passwordForgetScreen extends State<passwordForgetScreen> {
  bool isCheck = false;
  final controller = Get.put(AuthController());

  final emailController = TextEditingController();

  // Dispose controllers
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            // Scroll to prevent overflow on small screens
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                AppLogo(),
                SizedBox(height: 10),
                Text(
                  "Forget Your Password",
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Obx(() {
                  return Container(
                    padding: EdgeInsets.all(14),
                    width: screenWidth - 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        customTextFieldAuth(
                          title: email,
                          hint: emailHints,
                          controller: emailController,
                          isPass: false,
                        ),

                        //SendLink button or loading indicator
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor2),
                              )
                            : SizedBox(
                                width: screenWidth - 50,
                                child: ButtonComm(
                                  color: primaryColor2,
                                  title: "Send Link",
                                  textColor: Colors.white,
                                  onPress: () async {
                                    // Validation checks
                                    if (emailController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("Please fill fields"),
                                        ),
                                      );
                                      return;
                                    }

                                    controller.isLoading(true);
                                    try {
                                      await controller.forgetMethod(
                                        context: context,
                                        email: emailController.text.trim(),
                                      );
                                    } catch (e) {
                                      // Errors handled inside controller
                                    } finally {
                                      controller.isLoading(false);
                                    }
                                  },
                                ),
                              ),

                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Back to",
                                style: TextStyle(color: fontGrey),
                              ),
                              SizedBox(width: 5),
                              Text(
                                logIn,
                                style: TextStyle(
                                    color: primaryColor2, fontFamily: bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: screenHeight * 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
