import 'package:expense_tracker/route/app_routes.dart';
import 'package:expense_tracker/ui/analytics/analytics_screen.dart';
import 'package:expense_tracker/ui/home/home_screen.dart';
import 'package:expense_tracker/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../services/permission/permission_controller.dart';
import '../../services/permission/permission_dialog.dart';
import '../../utils/my_theme.dart';
import 'bottom_nav_controller.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final BottomNavController controller = Get.find<BottomNavController>();

  final List<Widget> screens = [HomeScreen(), AnalyticsScreen()];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permController = Get.put(PermissionController());

      permController.checkPermissions().then((_) {
        if (!permController.allGranted) {
          Get.dialog(PermissionDialog(), barrierDismissible: false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: MyTheme.background,
        body: Stack(
          children: [
            // Main Screens
            Obx(
              () => IndexedStack(
                index: controller.selectedIndex.value,
                children: screens,
              ),
            ),

            // Responsive Floating Bottom Nav
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      clipBehavior: Clip.none,
                      children: [
                        // Main Navigation Bar
                        Container(
                          constraints: BoxConstraints(maxWidth: 400.w),
                          width: 0.55.sw,
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 10.w,
                          ),
                          decoration: MyTheme.cardDecoration.copyWith(
                            borderRadius: BorderRadius.circular(35.r),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 4),
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNavItem(Icons.home_outlined, Icons.home, 0),
                              const SizedBox(width: 40), // Space for FAB
                              _buildNavItem(
                                Icons.analytics_outlined,
                                Icons.analytics,
                                1,
                              ),
                            ],
                          ),
                        ),

                        // Floating Action Button
                        Positioned(
                          bottom: 20.h,
                          child: InkWell(
                            onTap: () => NavigationHelper.navigateTo(
                              AppRoutes.addTransactionScreen,
                            ),
                            borderRadius: BorderRadius.circular(999.r),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: MyTheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 4),
                                    color: MyTheme.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        bool isSelected = controller.selectedIndex.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isSelected
                ? MyTheme.primary.withOpacity(0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? MyTheme.primary : MyTheme.textSecondary,
            size: 24.sp,
          ),
        );
      }),
    );
  }
}
