import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../utils/my_theme.dart';
import 'intro_controller.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntroController>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: MyTheme.bkgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  children: [
                    _buildPage(
                      lottie: 'assets/raw/sms.json',
                      title: 'Auto Read Your SMS',
                      subtitle:
                          'PocketCA reads your bank SMS and detects transactions automatically.',
                      visualSection: _buildSmsExample(),
                      highlights: [
                        _HighlightItem('No manual entry', '❌'),
                        _HighlightItem('Works instantly', '⚡'),
                        _HighlightItem('Saves your time', '⏱️'),
                      ],
                    ),
                    _buildPage(
                      lottie: 'assets/raw/save.json',
                      title: 'Everything Saved Automatically',
                      subtitle:
                          'All your expenses and income are stored neatly on your device.',
                      visualSection: _buildTransactionsExample(),
                      highlights: [
                        _HighlightItem('Auto categorization', '📂'),
                        _HighlightItem('Easy tracking', '📊'),
                        _HighlightItem('Clean & simple view', '✨'),
                      ],
                    ),
                    _buildPage(
                      lottie: 'assets/raw/upload.json',
                      title: 'Backup Anytime, Stay Safe',
                      subtitle:
                          'Export and import your data anytime. No data loss, even if you change your phone.',
                      visualSection: _buildBackupExample(),
                      highlights: [
                        _HighlightItem('Fully offline', '🔒'),
                        _HighlightItem('No cloud needed', '☁️'),
                        _HighlightItem('One-tap backup', '🔘'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildBottomSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String lottie,
    required String title,
    required String subtitle,
    required Widget visualSection,
    required List<_HighlightItem> highlights,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Flexible(flex: 10, child: Lottie.asset(lottie, fit: BoxFit.contain)),
          const Spacer(flex: 1),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: MyTheme.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const Spacer(flex: 1),
          visualSection,
          const Spacer(flex: 1),
          Wrap(
            spacing: 12.w,
            runSpacing: 10.h,
            alignment: WrapAlignment.center,
            children: highlights.map((h) => _buildHighlightChip(h)).toList(),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildHighlightChip(_HighlightItem item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11.sp,
              color: MyTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Text(item.icon, style: TextStyle(fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildSmsExample() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: MyTheme.cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SMS: "₹499 spent on Amazon"',
            style: TextStyle(
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: MyTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Icon(
            Icons.arrow_downward_rounded,
            color: MyTheme.primary,
            size: 16.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                'Auto Entry Created',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsExample() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: MyTheme.cardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTransactionRow('Food', '₹250', Colors.orange),
          SizedBox(height: 4.h),
          _buildTransactionRow('Travel', '₹120', Colors.blue),
          SizedBox(height: 4.h),
          _buildTransactionRow('Recharge', '₹199', Colors.green),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String title, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          amount,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBackupExample() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          Icons.phone_android_rounded,
          size: 30.sp,
          color: MyTheme.textSecondary,
        ),
        Icon(Icons.arrow_forward_rounded, color: MyTheme.primary, size: 16.sp),
        Icon(
          Icons.insert_drive_file_rounded,
          size: 40.sp,
          color: MyTheme.primary,
        ),
        Icon(Icons.arrow_forward_rounded, color: MyTheme.primary, size: 16.sp),
        Icon(
          Icons.phone_android_rounded,
          size: 30.sp,
          color: MyTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildBottomSection(IntroController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: controller.currentPage.value == index ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: controller.currentPage.value == index
                        ? MyTheme.primary
                        : MyTheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: controller.nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Obx(
                () => Text(
                  controller.currentPage.value == 2
                      ? 'Get Started'
                      : 'Continue',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: controller.currentPage.value == 2
                  ? controller.previousPage
                  : controller.completeIntro,
              style: TextButton.styleFrom(
                minimumSize: Size(100.w, 36.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                controller.currentPage.value == 2 ? 'Back' : 'Skip',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: MyTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightItem {
  final String label;
  final String icon;

  _HighlightItem(this.label, this.icon);
}
