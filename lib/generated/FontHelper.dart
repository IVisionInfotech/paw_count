import 'package:flutter/material.dart';

class FontHelper {

  static TextStyle bold({double fontSize = 16, Color color = Colors.black}) {
    return TextStyle(
      fontFamily: "NotoSerif_Bold",
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle extraBold({
    double fontSize = 16,
    Color color = Colors.black,
  }) {
    return TextStyle(
      fontFamily: "NotoSerif_ExtraBold",
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle semiBold({
    double fontSize = 16,
    Color color = Colors.black,
  }) {
    return TextStyle(
      fontFamily: "NotoSerif_SemiBold",
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle medium({double fontSize = 16, Color color = Colors.black}) {
    return TextStyle(
      fontFamily: "NotoSerif_Medium",
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle regular({double fontSize = 16, Color color = Colors.black}) {
    return TextStyle(
      fontFamily: "NotoSerif_Regular",
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle thin({double fontSize = 16, Color color = Colors.black}) {
    return TextStyle(
      fontFamily: "NotoSerif_Thin",
      fontSize: fontSize,
      color: color,
    );
  }
}
