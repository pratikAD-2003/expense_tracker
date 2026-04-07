import 'package:expense_tracker/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
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

  final List<Widget> screens = [
    HomeScreen(),
    Container(),
    Container(),
    Container(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.put(PermissionController());

      controller.checkPermissions().then((_) {
        if (!controller.allGranted) {
          Get.dialog(PermissionDialog(), barrierDismissible: false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: MyTheme.background,
      body: Stack(
        children: [
          // 🔥 Main Screens
          Obx(
            () => IndexedStack(
              index: controller.selectedIndex.value,
              children: screens,
            ),
          ),

          // 🔥 Floating Bottom Nav
          Positioned(
            bottom: 10.h,
            left: 0.w,
            right: 0.w,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: MyTheme.cardDecoration.copyWith(
                  borderRadius: BorderRadius.circular(35.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_outlined, Icons.home, 0),
                    _buildNavItem(Icons.favorite_outline, Icons.favorite, 1),
                    _buildNavItem(
                      Icons.shopping_cart_outlined,
                      Icons.shopping_cart,
                      2,
                    ),
                    _buildNavItem(Icons.person_outline, Icons.person, 3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index) {
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Obx(() {
        bool isSelected = controller.selectedIndex.value == index;
        return Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isSelected
                ? MyTheme.primary.withOpacity(0.1)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? MyTheme.primary : MyTheme.textSecondary,
            size: 26.sp,
          ),
        );
      }),
    );
  }
}
