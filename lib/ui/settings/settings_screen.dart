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
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  children: [
                    _sectionLabel("Preferences"),
                    SizedBox(height: 10.h),
                    Obx(() => _buildSettingTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          trailing: Switch(
                            value: controller.isNotificationsEnabled.value,
                            onChanged: controller.toggleNotifications,
                            activeColor: MyTheme.primary,
                          ),
                        )),
                    Obx(() => _buildSettingTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: controller.isDarkMode.value,
                            onChanged: controller.toggleDarkMode,
                            activeColor: MyTheme.primary,
                          ),
                        )),
                    _buildSettingTile(
                      icon: Icons.monetization_on_outlined,
                      title: 'Currency',
                      trailing: Obx(() => Text(
                            controller.selectedCurrency.value,
                            style: TextStyle(
                              color: MyTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          )),
                      onTap: () {
                        // Show currency picker
                      },
                    ),
                    SizedBox(height: 20.h),
                    _sectionLabel("Account"),
                    SizedBox(height: 10.h),
                    _buildSettingTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile Details',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    SizedBox(height: 20.h),
                    _sectionLabel("More"),
                    SizedBox(height: 10.h),
                    _buildSettingTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildSettingTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About App',
                      onTap: () {},
                    ),
                    SizedBox(height: 30.h),
                    _buildLogoutButton(),
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
          _headerAction(
            Icons.arrow_back_ios_new_rounded,
            () => Get.back(),
          ),
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

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: MyTheme.textPrimary,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: MyTheme.textSecondary),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: MyTheme.cardDecoration.copyWith(
          color: Colors.redAccent.withOpacity(0.1),
          boxShadow: [],
        ),
        child: Center(
          child: Text(
            'Logout',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
