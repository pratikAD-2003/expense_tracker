import 'package:expense_tracker/ui/settings/settings_controller.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(gradient: MyTheme.bkgGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 10.h,
                  ),
                  children: [
                    _buildBuyMeCoffeeSection(),
                    SizedBox(height: 20.h),
                    Obx(
                      () => _buildSettingTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        trailing: Switch(
                          value: controller.isNotificationsEnabled.value,
                          onChanged: controller.toggleNotifications,
                          activeColor: MyTheme.primary,
                        ),
                      ),
                    ),
                    Obx(
                      () => _buildSettingTile(
                        icon: Icons.music_note,
                        title: 'Sound',
                        trailing: Switch(
                          value: controller.isSoundEnabled.value,
                          onChanged: controller.toggleSoundEnable,
                          activeColor: MyTheme.primary,
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: Icons.upload_rounded,
                      title: 'Export Data',
                      onTap: () => controller.exportData(),
                      trailing: Obx(() => controller.isExporting.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: MyTheme.primary,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.w,
                              color: MyTheme.textSecondary,
                            )),
                    ),
                    _buildSettingTile(
                      icon: Icons.download_rounded,
                      title: 'Import Data',
                      onTap: () => controller.importData(),
                      trailing: Obx(() => controller.isImporting.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: MyTheme.primary,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.w,
                              color: MyTheme.textSecondary,
                            )),
                    ),
                    _buildSettingTile(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About App',
                      onTap: () {},
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 10.h),
      child: Row(
        children: [
          _headerAction(Icons.arrow_back_ios_new_rounded, () => Get.back()),
          SizedBox(width: 20.w),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onClick) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: MyTheme.cardDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, color: MyTheme.textSecondary, size: 20.w),
      ),
    );
  }

  Widget _buildBuyMeCoffeeSection() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, top: 4.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [MyTheme.primary, MyTheme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: MyTheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.coffee_rounded,
                color: Colors.white,
                size: 24.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buy Me a Coffee',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Support solo developer & keep it ad-free!',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: MyTheme.cardDecoration,
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        leading: Container(
          height: 40.w,
          width: 40.w,
          decoration: BoxDecoration(
            color: MyTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: MyTheme.primary, size: 20.w),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: MyTheme.textPrimary,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.w,
              color: MyTheme.textSecondary,
            ),
      ),
    );
  }
}
