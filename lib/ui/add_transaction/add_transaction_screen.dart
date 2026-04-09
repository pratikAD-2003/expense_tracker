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
                            SizedBox(height: 30.h),
                            _sectionLabel("Category"),
                            SizedBox(height: 10.h),
                            _categorySection(),
                            SizedBox(height: 20.h),
                            _sectionLabel("Date"),
                            SizedBox(height: 10.h),
                            _dateSection(context),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                    _numericKeyboard(context),
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
          GestureDetector(
            onTap: () => Get.back(),
            child: _headerAction(Icons.arrow_back_ios_new_rounded),
          ),
          SizedBox(width: 20.w),
          Text(
            "Add Transaction",
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

  Widget _headerAction(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: MyTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(icon, color: MyTheme.textSecondary, size: 20.w),
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
          SizedBox(height: 10.h),
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
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            bool isSelected = controller.selectedCategory.value == category;
            return GestureDetector(
              onTap: () => controller.changeCategory(category),
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: isSelected ? MyTheme.primary : Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? MyTheme.primary : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : MyTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            );
          });
        },
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
                colorScheme: ColorScheme.light(
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
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: MyTheme.cardDecoration,
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: MyTheme.primary, size: 18.sp),
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
            Icon(Icons.arrow_forward_ios_rounded, color: MyTheme.textSecondary, size: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _numericKeyboard(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['00', '0', 'delete'],
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
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
        children: keys.map((row) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: row.map((key) {
                return Expanded(child: _keyboardButton(context, key));
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _keyboardButton(BuildContext context, String label) {
    bool isDelete = label == 'delete';
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => isDelete
          ? controller.onDigitClear()
          : controller.onNumberPress(label),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        height: screenWidth * 0.15,
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
                  size: 24.w,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
