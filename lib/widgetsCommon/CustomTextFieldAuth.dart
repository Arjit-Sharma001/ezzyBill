import 'package:ezzybill/consts/consts.dart';
import 'package:flutter/material.dart';

Widget customTextFieldAuth({
  String? title,
  String? hint,
  TextEditingController? controller,
  bool isPass = false,
  Controller,
}) {
  // print(
  //     "CCCCCCCCCCCCCCCCCCController:$Controller cccccccccccccccccccccontroller:$controller");
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title!,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'semibold',
          color: primaryColor, // Replace 'orange' with your defined color
        ),
      ),
      SizedBox(height: 5),
      TextFormField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            fontFamily: 'semibold',
            color: Colors.grey, // Replace 'textfieldGrey' with your color
          ),
          hintText: hint,
          isDense: true,
          fillColor: Colors.grey[200], // Replace 'lightGrey' with your color
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Add rounded corners
            borderSide: BorderSide.none, // No border by default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: primaryColor2), // Replace with 'yelloColor'
          ),
        ),
      ),
      SizedBox(height: 5),
    ],
  );
}
