import 'package:expense_tracker/utils/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'add_transaction_controller.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key});

  final controller = Get.put(AddTransactionController());

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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            _typeSelectionBar(),
                            SizedBox(height: 20.h),
                            _amountDisplay(),
                            SizedBox(height: 20.h),

                            Row(
                              children: [
                                Expanded(child: _sectionLabel("Category")),
                                Expanded(child: _dateSection(context)),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            _categorySection(),
                            SizedBox(height: 15.h),
                          ],
                        ),
                      ),
                    ),
                    _bottomKeyboardSection(context),
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
            controller.editingTransaction != null ? "Edit Transaction" : "Add Transaction",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MyTheme.textPrimary,
            ),
          ),
          const Spacer(),
          if (controller.editingTransaction != null)
            _headerAction(
              Icons.delete_outline_rounded,
              () => _showDeleteConfirmation(),
              color: Colors.redAccent,
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteTransaction();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
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

  Widget _typeSelectionBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Obx(
        () => Row(
          children: controller.types.map((type) {
            bool isSelected = controller.selectedType.value == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeType(type),
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
                      type,
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

  Widget _amountDisplay() {
    return Center(
      child: Column(
        children: [
          Text(
            "Enter Amount",
            style: TextStyle(
              fontSize: 14.sp,
              color: MyTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Obx(
            () => Text(
              "₹${controller.formattedAmount}",
              style: TextStyle(
                fontSize: 42.sp,
                fontWeight: FontWeight.bold,
                color: MyTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: MyTheme.textPrimary,
      ),
    );
  }

  Widget _categorySection() {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: controller.categories.map((category) {
          bool isSelected = controller.selectedCategory.value == category;
          return GestureDetector(
            onTap: () => controller.changeCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? MyTheme.primary
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: isSelected ? MyTheme.primary : Colors.transparent,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : MyTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateSection(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate.value,
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
        if (pickedDate != null) {
          controller.updateDate(pickedDate);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
        decoration: MyTheme.cardDecoration,
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: MyTheme.primary,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Obx(
              () => Text(
                controller.formattedDate,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: MyTheme.textPrimary,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: MyTheme.textSecondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomKeyboardSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _numericRows(context),
          SizedBox(height: 15.h),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _numericRows(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['00', '0', 'delete'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: row.map((key) {
              return Expanded(child: _keyboardButton(context, key));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _keyboardButton(BuildContext context, String label) {
    bool isDelete = label == 'delete';

    return GestureDetector(
      onTap: () => isDelete
          ? controller.onDigitClear()
          : controller.onNumberPress(label),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        height: 50.h,
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.transparent
              : MyTheme.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: MyTheme.textPrimary,
                  size: 22.w,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return InkWell(
      onTap: () => controller.saveTransaction(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: MyTheme.primary,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: MyTheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            controller.editingTransaction != null ? 'Update Transaction' : 'Save Transaction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
