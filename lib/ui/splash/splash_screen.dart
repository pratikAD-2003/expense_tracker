import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/my_theme.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<double> _word1Opacity;
  late Animation<double> _word2Opacity;
  late Animation<double> _word3Opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Title animation (0.0s to 0.6s)
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // "Auto" animation (0.6s to 1.0s)
    _word1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );

    // "Offline" animation (1.0s to 1.4s)
    _word2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );

    // "Simple" animation (1.4s to 1.8s)
    _word3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller is initialized via SplashBinding
    Get.find<SplashController>();

    return Scaffold(
      backgroundColor: MyTheme.primary,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Image.asset(
              'assets/icons/cash.png',
              width: 80.w,
              height: 80.w,
              color: const Color(0xffffffff),
            ),
            SizedBox(height: 24.h),
            FadeTransition(
              opacity: _titleOpacity,
              child: Text(
                'PocketCA',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedWord('Auto', _word1Opacity),
                _buildSeparator(_word2Opacity),
                _buildAnimatedWord('Offline', _word2Opacity),
                _buildSeparator(_word3Opacity),
                _buildAnimatedWord('Simple', _word3Opacity),
              ],
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedWord(String word, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Text(
        word,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSeparator(Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Text(
        ' - ',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}
