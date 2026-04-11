import 'package:expense_tracker/route/app_routes.dart';
import 'package:expense_tracker/ui/analytics/analytics_controller.dart';
import 'package:expense_tracker/utils/navigation_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../utils/my_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final controller = Get.put(AnalyticsController());

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
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.fetchData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          _tabBar(),
                          SizedBox(height: 20.h),
                          const AnalyticsBarChart(),
                          SizedBox(height: 20.h),
                          _statsCards(),
                          SizedBox(height: 20.h),
                          _historySection(),
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Analytics",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => controller.fetchData(),
            icon: Icon(
              Icons.refresh_rounded,
              color: MyTheme.primary,
              size: 20.w,
            ),
          ),
        ],
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

  Widget _statsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _statCard(
                title: "Income",
                amount:
                    "₹${NumberFormat('#,##,###.##').format(controller.totalIncome.value)}",
                icon: Icons.arrow_downward_rounded,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _statCard(
                title: "Expense",
                amount:
                    "₹${NumberFormat('#,##,###.##').format(controller.totalExpense.value)}",
                icon: Icons.arrow_upward_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: MyTheme.cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          FittedBox(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: MyTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Summary",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
            if (controller.history.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text(
                    "No data available",
                    style: TextStyle(
                      color: MyTheme.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ...controller.history.map((item) => _historyItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => NavigationHelper.navigateTo(
        AppRoutes.transactionHistoryScreen,
        args: item["date"],
      ),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        decoration: MyTheme.cardDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['date'],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: MyTheme.textPrimary,
              ),
            ),
            Row(
              children: [
                if (item['income'] > 0)
                  Text(
                    "+₹${item['income']}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                if (item['income'] > 0 && item['expense'] > 0)
                  SizedBox(width: 10.w),
                if (item['expense'] > 0)
                  Text(
                    "-₹${item['expense']}",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnalyticsBarChart extends GetView<AnalyticsController> {
  const AnalyticsBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 16.h, 15.w, 10.h),
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: MyTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _legendItem("Income", MyTheme.primary),
              SizedBox(width: 10.w),
              _legendItem("Expense", const Color(0xff10B981)),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 180.h,
            child: Obx(() {
              if (controller.chartData.isEmpty) {
                return const Center(child: Text("No data for chart"));
              }
              return BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= controller.chartData.length)
                            return const SizedBox();

                          final data = controller.chartData[index];
                          String label = "";

                          if (controller.selectedPeriod.value == "Week") {
                            label = DateFormat('E').format(data.date);
                          } else if (controller.selectedPeriod.value ==
                              "Today") {
                            label = "Today";
                          } else {
                            // Month - show every 5th day to avoid clutter
                            if (index % 5 == 0 ||
                                index == controller.chartData.length - 1) {
                              label = DateFormat('dd').format(data.date);
                            }
                          }

                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: MyTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: controller.chartData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.income,
                          color: MyTheme.primary,
                          width: 8.w,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        BarChartRodData(
                          toY: data.expense,
                          color: const Color(0xff10B981),
                          width: 8.w,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          height: 8.h,
          width: 8.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: MyTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
