import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTheme {
  static const Color background = Color(0xFFF5F5F5); // Main screen bg
  static const Color primary = Color(0xFFFF6A3D);
  static const Color secondary = Color(0xFFF5F5F5);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8A8A8A);

  static TextStyle heading = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle subHeading = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle body = TextStyle(fontSize: 14.sp, color: textPrimary);

  static TextStyle small = TextStyle(fontSize: 12.sp, color: textSecondary);

  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFFFF6A3D), Color(0xFFFF8E53)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
