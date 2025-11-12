// Login UI for EzzyBill
import 'package:ezzybill/Controller/AuthController.dart';
import 'package:ezzybill/Screens/AutyhScreen/PasswordForgetScreen.dart';
import 'package:ezzybill/Screens/AutyhScreen/VerifyEmailScreen.dart';
import 'package:ezzybill/Screens/Home.dart';
import 'package:ezzybill/consts/list.dart';
import 'package:ezzybill/widgetsCommon/AppLogo.dart';
import 'package:ezzybill/widgetsCommon/ButtonComm.dart';
import 'package:ezzybill/widgetsCommon/CustomTextFieldAuth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/widgetsCommon/BgWidget.dart';
import 'SignupScreen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    final screenHeight = MediaQuery.of(context).size.height - 300;
    final screenWidth = MediaQuery.of(context).size.width;

    return BgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              AppLogo(),
              SizedBox(height: 10),
              Text(
                "Login to $appname",
                style: TextStyle(
                    fontFamily: bold, fontSize: 18, color: primaryColor),
              ),
              SizedBox(height: 15),
              Obx(() => Container(
                    padding: EdgeInsets.all(16),
                    width: screenWidth - 70,
                    decoration: BoxDecoration(
                      color: secondaryColor2,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        customTextFieldAuth(
                          title: email,
                          hint: emailHints,
                          isPass: false,
                          controller: controller.emailController,
                        ),
                        customTextFieldAuth(
                          title: Password,
                          hint: passwordHint,
                          isPass: true,
                          controller: controller.passwordController,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Get.to(() => passwordForgetScreen()),
                            child: Text(forgetpPass,
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        SizedBox(height: 5),
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(primaryColor2),
                              )
                            : SizedBox(
                                width: screenWidth - 50,
                                child: ButtonComm(
                                  color: primaryColor2,
                                  title: logIn,
                                  textColor: whiteColor,
                                  onPress: () async {
                                    controller.isLoading(true);
                                    print(
                                        "Email: ${controller.emailController.text}, Passworddddddddddddddddddd: ${controller.passwordController.text}");
                                    await controller
                                        .loginMethod(context: context)
                                        .then((value) {
                                      if (value != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(loggedIn),
                                        ));
                                        Get.offAll(() => Home());
                                      } else {
                                        controller.isLoading(false);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Login failed"),
                                        ));
                                      }
                                    });
                                  },
                                ),
                              ),
                        SizedBox(height: 5),
                        Text(createNewAcc, style: TextStyle(color: fontGrey)),
                        SizedBox(height: 5),
                        SizedBox(
                          width: screenWidth - 50,
                          child: ButtonComm(
                            color: lightopaque,
                            title: signUp,
                            textColor: primaryColor2,
                            onPress: () => Get.to(() => VerifyEmailScreen()),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(logInWith, style: TextStyle(color: fontGrey)),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google login
                            GestureDetector(
                              onTap: () async {
                                controller.isLoading(true);
                                await controller
                                    .googleLoginMethod(context: context)
                                    .then((value) {
                                  if (value != null) {
                                    Get.offAll(() => Home());
                                  } else {
                                    controller.isLoading(false);
                                    _showErrorToast(
                                        context, "Google login failed");
                                  }
                                });
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: lightGrey,
                                child:
                                    Image.asset(SocialIconList[0], width: 30),
                              ),
                            ),
                            // Facebook login
                            GestureDetector(
                              onTap: () async {
                                // controller.isLoading(true);
                                // await controller
                                //     .facebookLoginMethod(context: context)
                                //     .then((value) {
                                //   if (value != null) {
                                //     Get.offAll(() => Home());
                                //   } else {
                                //     controller.isLoading(false);
                                //     _showErrorToast(
                                //         context, "Facebook login failed");
                                //   }
                                // });
                              },
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: lightGrey,
                                child:
                                    Image.asset(SocialIconList[1], width: 30),
                              ),
                            ),
                            // Apple login (optional placeholder)
                            GestureDetector(
                              onTap: () {},
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: lightGrey,
                                child:
                                    Image.asset(SocialIconList[2], width: 30),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorToast(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color ?? Colors.redAccent,
    ));
  }
}
