import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTransactionController extends GetxController {
  final RxList<String> manualKeywords = <String>[].obs;

  final RxString amount = "0".obs;
  
  final List<String> types = ["Send", "Receive"];
  final RxString selectedType = "Send".obs;

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Health",
    "Bills",
    "Others"
  ];
  final RxString selectedCategory = "Food".obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  String get formattedDate => DateFormat('dd MMM yyyy').format(selectedDate.value);

  String get formattedAmount {
    if (amount.value.isEmpty) return "0";
    final formatter = NumberFormat('#,##,###');
    return formatter.format(int.parse(amount.value));
  }

  void onNumberPress(String val) {
    if (amount.value == "0") {
      if (val != "0") {
        amount.value = val;
      }
    } else {
      String newAmount = amount.value + val;
      // Condition: amount should only be under lakhs (max 999,999)
      if (int.tryParse(newAmount) != null && int.parse(newAmount) < 10000000) {
        amount.value = newAmount;
      }
    }
  }

  void onDigitClear() {
    if (amount.value.length > 1) {
      amount.value = amount.value.substring(0, amount.value.length - 1);
    } else {
      amount.value = "0";
    }
  }

  void changeType(String type) {
    selectedType.value = type;
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
