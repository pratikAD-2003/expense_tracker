import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTheme {
  static const Color background = Color(0xFFF5F5F5); // Main screen bg
  static const Color primary = Color(0xff8B5CF6);
  static const Color secondary = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xff1F2937);
  static const Color textSecondary = Color(0xff6B7280);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static LinearGradient bkgGradient = const LinearGradient(
    colors: [Color(0xFFD1A7FF), Color(0xFFF3F4F6), Color(0xffF9FAFB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
