import 'dart:math';

import 'package:expense_tracker/route/app_routes.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:expense_tracker/utils/navigation_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(gradient: MyTheme.bkgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      _tabBar(),
                      SizedBox(height: 20.h),
                      _statsWidget(),
                      SizedBox(height: 20.h),
                      const WeeklyExpenseBarChart(),
                      SizedBox(height: 30.h),
                      _recentTransactions(),
                      SizedBox(height: 80.h),
                    ],
                  ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerAction(
            Icons.settings_outlined,
            () => NavigationHelper.navigateTo(AppRoutes.settingsScreen),
          ),
          Text(
            DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
          _headerAction(
            Icons.notifications_none_rounded,
            () => NavigationHelper.navigateTo(AppRoutes.notificationScreen),
          ),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onClick) {
    return InkWell(
      onTap: () => onClick(),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: MyTheme.cardDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, color: MyTheme.textSecondary, size: 24.w),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Obx(
        () => Row(
          children: controller.periods.map((period) {
            bool isSelected = controller.selectedPeriod.value == period;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changePeriod(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? MyTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: MyTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? Colors.white : MyTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _statsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(
          () => Text(
            "This ${controller.selectedPeriod.value} Spend",
            style: TextStyle(
              fontSize: 15.sp,
              color: MyTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Obx(
          () => Text(
            "₹${controller.totalSpent.value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "67% below last month",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _recentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: MyTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: MyTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () {
            // Show only first 10 transactions
            final displayList = controller.transactions.take(10).toList();
            
            if (displayList.isEmpty) {
              return Container(
                height: 100.h,
                alignment: Alignment.center,
                child: Text(
                  "No transactions for this period",
                  style: TextStyle(color: MyTheme.textSecondary, fontSize: 13.sp),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              itemCount: displayList.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final tx = displayList[index];
                return _transactionItem(tx);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _transactionItem(Map tx) {
    final bool isExpense = tx['type'].toString().toUpperCase() == 'EXPENSE';
    final amount = tx['amount']?.toString() ?? "0.0";

    final dynamic rawTime = tx['dateTime'] ?? tx['time'];
    final int timeInt = (rawTime is String) ? (int.tryParse(rawTime) ?? 0) : (rawTime as int? ?? 0);
    final date = DateTime.fromMillisecondsSinceEpoch(timeInt);

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: MyTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            height: 48.w,
            width: 48.w,
            decoration: BoxDecoration(
              color: MyTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getCategoryIcon(tx['category'] ?? ''),
              color: MyTheme.primary,
              size: 24.w,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'] ?? tx['merchant'] ?? tx['sender'] ?? "Unknown",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: MyTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${isExpense ? '-' : '+'} ₹$amount",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.redAccent : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return Icons.restaurant_rounded;
      case 'SHOPPING':
        return Icons.shopping_bag_rounded;
      case 'UPI':
        return Icons.qr_code_scanner_rounded;
      case 'BILL':
        return Icons.receipt_long_rounded;
      case 'RECHARGE':
        return Icons.phone_android_rounded;
      case 'SUBSCRIPTION':
        return Icons.subscriptions_rounded;
      case 'ATM':
      case 'CARD':
        return Icons.credit_card_rounded;
      case 'OTHERS':
      case 'CASH':
        return Icons.payments_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}

class WeeklyExpenseBarChart extends StatelessWidget {
  const WeeklyExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Analytics",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: MyTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: MyTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 0.w),
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          decoration: MyTheme.cardDecoration,
          child: SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (index + 1) * 10.0 + Random().nextInt(50),
                        color: MyTheme.primary,
                        width: 15.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
