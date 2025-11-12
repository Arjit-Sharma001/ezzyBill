import 'package:ezzybill/Screens/AutyhScreen/LoginScreen.dart';
import 'package:ezzybill/Screens/Home.dart';
import 'package:ezzybill/consts/consts.dart';
import 'package:ezzybill/consts/firebaseConst.dart';
import 'package:ezzybill/widgetsCommon/AppLogo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  // Method for change screen
  void changeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (auth.currentUser == null) {
        Get.off(() => LoginScreen());
      } else {
        Get.off(() => Home());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    changeScreen();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Image
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                icSplashBg,
                height: screenHeight * 0.3,
                width: screenWidth * 0.7,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // App Logo
            AppLogo(),
            SizedBox(height: screenHeight * 0.02),
            // App Name
            Text(
              appname,
              style: TextStyle(
                fontFamily: bold,
                fontSize: screenHeight * 0.03,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.008),
            // Version
            Text(
              appversion,
              style: TextStyle(
                fontSize: screenHeight * 0.02,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            // Credits at bottom
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: Text(
                credits,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: semibold,
                  fontSize: screenHeight * 0.018,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
