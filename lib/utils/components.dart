import 'package:expense_tracker/route/app_routes.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Components {
  static void showTransactionDetails(
    BuildContext context,
    Map transaction, {
    VoidCallback? onDelete,
  }) {
    final bool isExpense =
        transaction['type'].toString().toUpperCase() == 'EXPENSE';
    final DateTime dateTime = _parseDate(transaction['dateTime']);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: MyTheme.textSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _detailHeader(
                  transaction['title'] ?? "Transaction",
                  transaction['source'] ?? "MANUAL",
                ),
                _amountDisplay(transaction['amount'], isExpense),
              ],
            ),
            const Divider(height: 30),
            _infoRow(
              Icons.calendar_today_rounded,
              "Date",
              DateFormat('dd MMM yyyy').format(dateTime),
            ),
            _infoRow(
              Icons.access_time_rounded,
              "Time",
              DateFormat('hh:mm a').format(dateTime),
            ),
            _infoRow(
              Icons.category_outlined,
              "Category",
              transaction['category'] ?? "Others",
            ),
            _infoRow(
              Icons.compare_arrows_rounded,
              "Type",
              transaction['type'].toString().capitalizeFirst ?? "",
            ),

            if (transaction['rawSms'] != null &&
                transaction['rawSms'].toString().isNotEmpty) ...[
              const Divider(height: 30),
              Text(
                "Original Message",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: MyTheme.background,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Text(
                  transaction['rawSms'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: MyTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    "Delete",
                    Icons.delete_outline_rounded,
                    Colors.redAccent,
                    () {
                      Get.back();
                      if (onDelete != null) onDelete();
                    },
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: _actionButton(
                    "Edit",
                    Icons.edit_outlined,
                    MyTheme.primary,
                    () {
                      Get.back();
                      Get.toNamed(
                        AppRoutes.addTransactionScreen,
                        arguments: transaction,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static DateTime _parseDate(dynamic date) {
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      return DateTime.fromMillisecondsSinceEpoch(
        int.tryParse(date.toString()) ?? DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Widget _detailHeader(String title, String source) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: MyTheme.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: MyTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            source,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _amountDisplay(dynamic amount, bool isExpense) {
    return Text(
      "${isExpense ? '-' : '+'} ₹$amount",
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: isExpense ? Colors.redAccent : Colors.green,
      ),
    );
  }

  static Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.w, color: MyTheme.textSecondary),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: MyTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.w, color: color),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
