import 'package:expense_tracker/route/app_routes.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:expense_tracker/utils/navigation_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../utils/components.dart';
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
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchTransactions(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        _tabBar(),
                        SizedBox(height: 20.h),
                        _statsWidget(),
                        SizedBox(height: 20.h),
                        const DynamicHomeBarChart(),
                        SizedBox(height: 30.h),
                        _recentTransactions(),
                        SizedBox(height: 80.h),
                      ],
                    ),
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
                        color: isSelected
                            ? Colors.white
                            : MyTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
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
            "₹${NumberFormat('#,##,###.##').format(controller.totalSpent.value)}",
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Tracking your spending habits",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF10B981),
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
              TextButton(
                onPressed: () => NavigationHelper.navigateTo(AppRoutes.transactionHistoryScreen),
                child: Text(
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
        Obx(() {
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
              return _transactionItem(tx, context);
            },
          );
        }),
      ],
    );
  }

  Widget _transactionItem(Map tx, BuildContext context) {
    final bool isExpense = tx['type'].toString().toUpperCase() == 'EXPENSE';
    final amount = tx['amount']?.toString() ?? "0.0";
    final DateTime date =
        controller.parseDate(tx['dateTime']) ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return InkWell(
      onTap: () {
        Components.showTransactionDetails(
          context,
          tx,
          onDelete: () => controller.deleteNotification(tx['id']),
        );
      },
      child: Container(
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
                    tx['title'] ?? "Transaction",
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
      case 'TRANSPORT':
        return Icons.directions_bus_rounded;
      case 'HEALTH':
        return Icons.medical_services_rounded;
      case 'ENTERTAINMENT':
        return Icons.movie_creation_rounded;
      case 'CASH':
        return Icons.payments_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}

class DynamicHomeBarChart extends GetView<HomeController> {
  const DynamicHomeBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Obx(
            () => Text(
              "${controller.selectedPeriod.value} Analytics (${controller.selectedPeriod.value == "Today"
                  ? "Hour Wise"
                  : controller.selectedPeriod.value == "Week"
                  ? "Day Wise"
                  : "Date Wise"})",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.fromLTRB(10.w, 20.h, 20.w, 10.h),
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          decoration: MyTheme.cardDecoration,
          child: SizedBox(
            height: 180.h,
            child: Obx(() {
              if (controller.chartData.isEmpty) {
                return const Center(child: Text("No data available"));
              }
              return BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= controller.chartData.length) {
                            return const SizedBox();
                          }

                          String label = controller.chartData[index].label;

                          // Optimization for Month view to avoid overlap
                          if (controller.selectedPeriod.value == "Month") {
                            if (index % 5 != 0 &&
                                index != controller.chartData.length - 1) {
                              return const SizedBox();
                            }
                          }

                          // Optimization for Today view to avoid overlap
                          if (controller.selectedPeriod.value == "Today") {
                            if (index % 4 != 0) return const SizedBox();
                          }

                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: MyTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: controller.chartData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.amount,
                          color: MyTheme.primary,
                          width: controller.selectedPeriod.value == "Today"
                              ? 6.w
                              : controller.selectedPeriod.value == "Week"
                              ? 14.w
                              : 4.w,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
