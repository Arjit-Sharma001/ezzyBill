import 'package:ezzybill/Screens/SplashScreen/SplashScreen.dart';
import 'package:ezzybill/consts/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge); // Hides status bar

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Makes status bar transparent
    systemNavigationBarColor: primaryColor, // Makes nav bar transparent
  ));

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    ),
  );
}
