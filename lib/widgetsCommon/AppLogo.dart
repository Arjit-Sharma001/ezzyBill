import 'package:flutter/material.dart';
import 'package:ezzybill/consts/consts.dart';

Widget AppLogo() {
  return Container(
    padding: EdgeInsets.all(8),
    width: 77,
    height: 77,
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(12), // adjust for your design
    ),
    child: Image.asset(icAppLogo),
  );
}
