import 'package:expense_tracker/ui/analytics/analytics_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      _tabBar(),
                      SizedBox(height: 20.h),
                      WeeklyExpenseBarChart(),
                      SizedBox(height: 20.h),
                      _statsCards(),
                      SizedBox(height: 20.h),
                      _historySection(),
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
      child: Text(
        "Analytics",
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: MyTheme.textPrimary,
        ),
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
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              title: "Income",
              amount: "₹2,500.00",
              icon: Icons.arrow_downward_rounded,
              color: MyTheme.primary,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: _statCard(
              title: "Expense",
              amount: "₹1,200.00",
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xff10B981),
            ),
          ),
        ],
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
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "History",
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
          SizedBox(height: 10.h),
          ...controller.history.map((item) => _historyItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _historyItem(Map<String, dynamic> item) {
    return Container(
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
              fontWeight: FontWeight.w500,
              color: MyTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                "+₹${item['income']}",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "-₹${item['expense']}",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklyExpenseBarChart extends StatelessWidget {
  const WeeklyExpenseBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 0.w),
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: MyTheme.cardDecoration,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 12.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyTheme.primary,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: MyTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 12.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xff10B981),
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    "Expense",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: MyTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15.w),
            ],
          ),
          SizedBox(height: 20.w),
          SizedBox(
            height: 150.h,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                // 📅 Bottom Days
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
                        const days = [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ];

                        if (value.toInt() < 0 || value.toInt() > 6) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: MyTheme.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 👆 Tap → show amount
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "₹${rod.toY.toInt()}",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                // 📊 Bars
                barGroups: [
                  _bar(0, 200, 150),
                  _bar(1, 500, 420),
                  _bar(2, 300, 450),
                  _bar(3, 700, 300),
                  _bar(4, 400, 200),
                  _bar(5, 650, 500),
                  _bar(6, 450, 350),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barsSpace: 4.w,
      barRods: [
        BarChartRodData(
          toY: income,
          width: 10.w,
          borderRadius: BorderRadius.circular(4.r),
          color: MyTheme.primary,
        ),
        BarChartRodData(
          toY: expense,
          width: 10.w,
          borderRadius: BorderRadius.circular(4.r),
          color: const Color(0xff10B981),
        ),
      ],
    );
  }
}
