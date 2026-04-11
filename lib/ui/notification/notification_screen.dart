import 'package:expense_tracker/ui/notification/notification_controller.dart';
import 'package:expense_tracker/utils/components.dart';
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
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.groupedNotifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications found',
                        style: TextStyle(
                          color: MyTheme.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    );
                  }

                  final dates = controller.groupedNotifications.keys.toList();

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 0.h,
                    ),
                    itemCount: dates.length,
                    itemBuilder: (context, dateIndex) {
                      final date = dates[dateIndex];
                      final items = controller.groupedNotifications[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 4.w,
                            ),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: MyTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...items.map((notification) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildNotificationItem(
                                context,
                                notification,
                                controller,
                              ),
                            );
                          }),
                        ],
                      );
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
          _headerAction(Icons.arrow_back_ios_new_rounded, () => Get.back()),
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

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    return GestureDetector(
      onTap: () => Components.showTransactionDetails(
        context,
        notification.fullData,
        onDelete: () =>
            controller.deleteNotification(int.parse(notification.id)),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: MyTheme.cardDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: MyTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                color: MyTheme.primary,
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
                  SizedBox(height: 4.h),
                  Text(
                    notification.rawMessage.isEmpty
                        ? "Cash"
                        : notification.rawMessage,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: MyTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
