import 'package:ezzybill/Controller/AuthController.dart';
import 'package:ezzybill/Screens/Home.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgetsCommon/AppLogo.dart';
import '../../../widgetsCommon/BgWidget.dart';
import '../../../widgetsCommon/ButtonComm.dart';
import '../../widgetsCommon/CustomTextFieldAuth.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isCheck = false;
  bool _isEmailEmpty = false;
  bool _isEmailVerifyed = false;

  final controller = Get.put(AuthController());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordRetypeController = TextEditingController();

  // Dispose controllers
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordRetypeController.dispose();
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
                  "SignUp to $appname",
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
                          title: name,
                          hint: nameHint,
                          controller: nameController,
                          isPass: false,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: customTextFieldAuth(
                                title: email,
                                hint: emailHints,
                                controller: emailController,
                                isPass: false,
                              ),
                            ),
                            InkWell(
                              onTap: () => {},
                              child: Padding(
                                // Responsive padding to align icon
                                padding: EdgeInsets.only(
                                    left: screenWidth * 0.02,
                                    top: screenHeight * 0.02),
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: _isEmailEmpty
                                      ? Colors.grey
                                      : (_isEmailVerifyed
                                          ? Colors.green
                                          : Colors.red),
                                  size: screenWidth *
                                      0.07, // Responsive icon size
                                ),
                              ),
                            ),
                          ],
                        ),
                        customTextFieldAuth(
                          title: Password,
                          hint: passwordHint,
                          controller: passwordController,
                          isPass: true,
                        ),
                        customTextFieldAuth(
                          title: retypepassword,
                          hint: passwordHint,
                          controller: passwordRetypeController,
                          isPass: true,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: primaryColor2,
                              checkColor: Colors.white,
                              value: isCheck,
                              onChanged: (newValue) {
                                setState(() {
                                  isCheck = newValue ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "I agree to the ",
                                      style: TextStyle(
                                        color: fontGrey,
                                        fontFamily: regular,
                                      ),
                                    ),
                                    TextSpan(
                                      text: TermsAndConditions,
                                      style: TextStyle(
                                        color: primaryColor2,
                                        fontFamily: regular,
                                      ),
                                      // TODO: Add TapGestureRecognizer for clickable terms
                                    ),
                                    TextSpan(
                                      text: " & ",
                                      style: TextStyle(
                                        color: fontGrey,
                                        fontFamily: regular,
                                      ),
                                    ),
                                    TextSpan(
                                      text: PrivacyPolicy,
                                      style: TextStyle(
                                        color: primaryColor2,
                                        fontFamily: regular,
                                      ),
                                      // TODO: Add TapGestureRecognizer for clickable privacy policy
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Sign Up button or loading indicator
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor2),
                              )
                            : SizedBox(
                                width: screenWidth - 50,
                                child: ButtonComm(
                                  color: isCheck ? primaryColor2 : lightopaque,
                                  title: signUp,
                                  textColor:
                                      isCheck ? Colors.white : primaryColor2,
                                  onPress: () async {
                                    if (!isCheck) return; // Must agree first

                                    // Validation checks
                                    if (nameController.text.trim().isEmpty ||
                                        emailController.text.trim().isEmpty ||
                                        passwordController.text
                                            .trim()
                                            .isEmpty ||
                                        passwordRetypeController.text
                                            .trim()
                                            .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Please fill all fields"),
                                        ),
                                      );
                                      return;
                                    }

                                    if (passwordController.text !=
                                        passwordRetypeController.text) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Passwords do not match"),
                                        ),
                                      );
                                      return;
                                    }

                                    controller.isLoading(true);
                                    try {
                                      final userCredential =
                                          await controller.signUpMethod(
                                        context: context,
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                      );
                                      if (userCredential != null) {
                                        await controller.storeUserData(
                                          name: nameController.text.trim(),
                                          email: emailController.text.trim(),
                                        );

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Sign up successful!"),
                                          ),
                                        );
                                        Get.offAll(() => Home());
                                      }
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
                                alreadAcc,
                                style: TextStyle(color: fontGrey),
                              ),
                              SizedBox(width: 5),
                              Text(
                                logIn,
                                style: TextStyle(color: primaryColor2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
