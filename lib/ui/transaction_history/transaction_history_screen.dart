import 'package:expense_tracker/ui/transaction_history/transaction_history_controller.dart';
import 'package:expense_tracker/utils/components.dart';
import 'package:expense_tracker/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  TransactionHistoryScreen({super.key});

  final controller = Get.put(TransactionHistoryController());

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.groupedTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 60.w,
                            color: MyTheme.textSecondary.withOpacity(0.3),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              color: MyTheme.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final dates = controller.groupedTransactions.keys.toList();

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchTransactions(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 0.h,
                      ),
                      itemCount: dates.length,
                      itemBuilder: (context, dateIndex) {
                        final date = dates[dateIndex];
                        final items = controller.groupedTransactions[date]!;

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
                            ...items.map((tx) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _transactionItem(tx, context),
                              );
                            }),
                          ],
                        );
                      },
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

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 10.h),
      child: Row(
        children: [
          _headerAction(Icons.arrow_back_ios_new_rounded, () => Get.back()),
          SizedBox(width: 20.w),
          Text(
            'History',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Obx(
            () => controller.selectedDate.value != null
                ? _headerAction(
                    Icons.close_rounded,
                    () => controller.updateSelectedDate(null),
                    color: Colors.redAccent,
                  )
                : const SizedBox(),
          ),
          SizedBox(width: 10.w),
          _headerAction(Icons.calendar_month_rounded, () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: MyTheme.primary,
                      onPrimary: Colors.white,
                      onSurface: MyTheme.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              controller.updateSelectedDate(picked);
            }
          }),
        ],
      ),
    );
  }

  Widget _headerAction(IconData icon, VoidCallback onClick, {Color? color}) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: MyTheme.cardDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(icon, color: color ?? MyTheme.textSecondary, size: 20.w),
      ),
    );
  }

  Widget _transactionItem(Map tx, BuildContext context) {
    final bool isExpense = tx['type'].toString().toUpperCase() == 'EXPENSE';
    final amount = tx['amount']?.toString() ?? "0.0";
    final DateTime date =
        controller.parseDate(tx['dateTime']) ?? DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(date);

    return InkWell(
      onTap: () {
        Components.showTransactionDetails(
          context,
          tx,
          onDelete: () => controller.deleteTransaction(tx['id']),
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
                    formattedTime,
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
