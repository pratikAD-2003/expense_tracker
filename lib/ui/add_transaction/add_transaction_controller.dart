import 'package:expense_tracker/services/native_transactions.dart';
import 'package:expense_tracker/ui/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTransactionController extends GetxController {
  final RxString amount = "0".obs;

  final List<String> types = ["Expense", "Income"];
  final RxString selectedType = "Expense".obs;

  final List<String> categories = [
    "Cash",
    "Food",
    "Transport",
    "Shopping",
    "Entertainment",
    "Health",
    "Bills",
    "Others",
  ];
  final RxString selectedCategory = "Cash".obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // For editing
  Map? editingTransaction;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      editingTransaction = Get.arguments as Map;
      _setupEditingData();
    }
  }

  void _setupEditingData() {
    if (editingTransaction == null) return;

    amount.value = editingTransaction!['amount'].toString().replaceAll(
      '.0',
      '',
    );
    selectedType.value =
        editingTransaction!['type'].toString().capitalizeFirst ?? "Expense";
    selectedCategory.value = editingTransaction!['category'] ?? "Cash";

    final rawDate = editingTransaction!['dateTime'];
    if (rawDate != null) {
      final str = rawDate.toString();
      if (RegExp(r'^\d+$').hasMatch(str)) {
        selectedDate.value = DateTime.fromMillisecondsSinceEpoch(
          int.parse(str),
        );
      } else {
        selectedDate.value = DateTime.tryParse(str) ?? DateTime.now();
      }
    }
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  String get formattedAmount {
    if (amount.value.isEmpty || amount.value == "0") return "0";
    try {
      final formatter = NumberFormat('#,##,###');
      return formatter.format(double.parse(amount.value));
    } catch (e) {
      return amount.value;
    }
  }

  void onNumberPress(String val) {
    if (amount.value == "0") {
      if (val != "0" && val != "00") {
        amount.value = val;
      }
    } else {
      String newAmount = amount.value + val;
      if (newAmount.length < 9) {
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

  Future<void> saveTransaction() async {
    if (amount.value == "0" || amount.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter an amount",
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
      );
      return;
    }

    try {
      final homeController = Get.find<HomeController>();

      final txData = {
        "title": selectedCategory.value,
        "amount": double.parse(amount.value),
        "type": selectedType.value.toUpperCase(),
        "category": selectedCategory.value,
        "dateTime": selectedDate.value.millisecondsSinceEpoch.toString(),
        "source": editingTransaction?['source'] ?? "MANUAL",
        "rawSms": editingTransaction?['rawSms'] ?? "",
      };

      if (editingTransaction != null) {
        txData['id'] = editingTransaction!['id'];
        await NativeTransactions.updateTransaction(txData);
      } else {
        final id = await NativeTransactions.addTransaction(txData);
        txData['id'] = id;
      }

      await homeController.fetchTransactions();

      Get.back();
      Get.snackbar(
        "Success",
        editingTransaction != null
            ? "Transaction updated"
            : "Transaction added",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to save: $e");
    }
  }

  Future<void> deleteTransaction() async {
    if (editingTransaction == null) return;

    try {
      await NativeTransactions.deleteTransaction(editingTransaction!['id']);
      final homeController = Get.find<HomeController>();
      await homeController.fetchTransactions();
      Get.back();
      Get.snackbar("Success", "Deleted");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete: $e");
    }
  }
}
