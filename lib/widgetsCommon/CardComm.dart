import 'package:ezzybill/consts/colors.dart';
import 'package:ezzybill/consts/styles.dart';
import 'package:flutter/material.dart';

Widget CardComm({String? count, String? title, double? screenHeight}) {
  return Container(
    // width: width,
    height: screenHeight! * 0.14,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: secondaryColor2,
      borderRadius: BorderRadius.circular(8),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count ?? '',
          style: TextStyle(
            fontFamily: bold,
            fontSize: 22,
            color: darkFontGrey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title ?? '',
          style: TextStyle(
            color: darkFontGrey,
          ),
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}
