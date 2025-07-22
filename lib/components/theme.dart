import 'package:flutter/material.dart';


class AppColors {
  static const Color primary = Color(0xff748288);
  static const Color lightGrey = Color(0xff939393);
  static const Color cameraIconBg = Color(0xff42A5F5);
  static const Color greyBg = Color(0xffeeeeee);

  static const Color background = Color(0xFFF4F4F4);
  static const Color cardShadow = Color(0xFFE0E0E0);
  static const Color logoutRed = Color(0xfff44336);
  static const Color iconDefault = Color(0xff607D8B);
  static const Color titleText = Color(0xFF333333);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color green = Colors.green;
  static const Color blue = Colors.blue;
  static const Color red = Colors.red;
  static const Color grey = Colors.grey;
  static final Color grey400 = Colors.grey.shade400;
  static final Color grey300 = Colors.grey.shade300;
  static final Color grey700 = Colors.grey[700]!;
  static const Color transparent = Colors.transparent;
  static const Color purple = Colors.purple;
  static const Color orange = Colors.orange;


  static const TextStyle titleStyle = TextStyle(
    color: AppColors.titleText,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: AppColors.lightGrey,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle inputLabel = TextStyle(
    color: AppColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}
