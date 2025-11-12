import 'package:flutter/material.dart';

Widget ButtonComm({
  required String title,
  required VoidCallback onPress,
  required Color textColor,
  required Color color,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: EdgeInsets.all(12),
    ),
    onPressed: onPress,
    child: Text(
      title,
      style: TextStyle(
        color: textColor,
        fontFamily: 'bold', // Replace with your actual font family if needed
      ),
    ),
  );
}
