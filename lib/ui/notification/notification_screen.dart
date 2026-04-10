import 'package:expense_tracker/ui/notification/notification_controller.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

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
                child: Obx(() {
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationItem(notification, () {
                        controller.markAsRead(index);
                      });
                    },
                  );
                }),
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
            'Notifications',
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

  Widget _buildNotificationItem(NotificationModel notification, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: MyTheme.cardDecoration.copyWith(
          border: notification.isRead
              ? null
              : Border.all(color: MyTheme.primary.withOpacity(0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? MyTheme.background
                    : MyTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                notification.isRead
                    ? Icons.notifications_none_rounded
                    : Icons.notifications_active_rounded,
                color: notification.isRead ? MyTheme.textSecondary : MyTheme.primary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: MyTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: MyTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: MyTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    notification.time,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: MyTheme.textSecondary.withOpacity(0.6),
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
}
