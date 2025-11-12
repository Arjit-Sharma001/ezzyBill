// import 'dart:async';
// import 'package:ezzybill/Screens/Home.dart';
// import 'package:ezzybill/consts/colors.dart';
// import 'package:ezzybill/consts/styles.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   const VerifyEmailScreen({Key? key}) : super(key: key);

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   final auth = FirebaseAuth.instance;
//   late User user;
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     user = auth.currentUser!;
//     user.sendEmailVerification();

//     // check every 5 seconds if email is verified
//     timer = Timer.periodic(Duration(seconds: 5), (_) => checkEmailVerified());
//   }

//   Future<void> checkEmailVerified() async {
//     await user.reload();
//     if (user.emailVerified) {
//       timer?.cancel();
//       Get.snackbar("Verified", "Email verified successfully!",
//           snackPosition: SnackPosition.BOTTOM);

//       // store user data and navigate to Home
//       Get.offAll(() => Home());
//     }
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.mark_email_unread, size: 80, color: primaryColor2),
//               SizedBox(height: 20),
//               Text(
//                 "Verify your email",
//                 style: TextStyle(fontFamily: bold, fontSize: 22),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "A verification link has been sent to ${user.email}. "
//                 "Please check your inbox or spam folder.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: fontGrey),
//               ),
//               SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: () async {
//                   await user.sendEmailVerification();
//                   Get.snackbar("Sent", "Verification email resent");
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor2,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                 ),
//                 child: Text("Resend Email"),
//               ),
//               SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: () => checkEmailVerified(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                 ),
//                 child: Text("Continue"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:ezzybill/Controller/AuthController.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgetsCommon/AppLogo.dart';
import '../../../widgetsCommon/BgWidget.dart';
import '../../../widgetsCommon/ButtonComm.dart';
import '../../widgetsCommon/CustomTextFieldAuth.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final controller = Get.put(AuthController());
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BgWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                AppLogo(),
                SizedBox(height: 10),
                Text(
                  "Verify your email",
                  style: TextStyle(
                    fontFamily: bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                // Obx(() {
                // return
                Container(
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
                      SizedBox(height: 20),
                      SizedBox(
                        width: screenWidth - 50,
                        child: ButtonComm(
                          color: primaryColor2,
                          title: "Send Verification Link",
                          textColor: Colors.white,
                          onPress: () async {
                            final email = emailController.text.trim();

                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please enter your email"),
                                ),
                              );
                              return;
                            }

                            controller.isLoading(true);
                            try {
                              await controller.sendEmailVerification(
                                  context, email);
                              await controller.storeUserData(
                                name: "",
                                email: emailController.text.trim(),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error1: $e")),
                              );
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
                            Text(alreadAcc, style: TextStyle(color: fontGrey)),
                            SizedBox(width: 5),
                            Text(logIn, style: TextStyle(color: primaryColor2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
