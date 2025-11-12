import 'package:flutter/material.dart';

Widget customTextFieldInvoice(
    {required TextEditingController controller, fontWeight, fontSize, color}) {
  return TextFormField(
    controller: controller,
    style: TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color),
    textAlign: TextAlign.center,
    decoration: InputDecoration(border: InputBorder.none),
  );
}
