/*
import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var transactions = <Map>[].obs;
  var isLoading = true.obs;

  var totalSpent = 0.0.obs;
  var totalReceived = 0.0.obs;

  var selectedPeriod = "Today".obs;
  final List<String> periods = ["Today", "Week", "Month"];

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final data = await NativeTransactions.getTransactions();
      transactions.value = data;
      print(transactions);
      calculateTotals();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void calculateTotals() {
    double spent = 0;
    double received = 0;
    for (var tx in transactions) {
      final double amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      final String type = (tx['type'] ?? '').toString().toUpperCase();
      if (type == 'EXPENSE') {
        spent += amt;
      } else if (type == 'INCOME') {
        received += amt;
      }
    }
    totalSpent.value = spent;
    totalReceived.value = received;
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    // You might want to re-filter transactions based on period here
  }

  Future<void> markAsSynced(int id) async {
    try {
      await NativeTransactions.markSynced(id);
      // Refresh the list after marking as synced
      await fetchTransactions();
    } catch (e) {
      Get.snackbar("Error", "Failed to update transaction: $e");
    }
  }
}
*/
import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var allTransactions = <Map>[].obs;
  var transactions = <Map>[].obs;
  var isLoading = true.obs;

  var totalSpent = 0.0.obs;
  var totalReceived = 0.0.obs;

  var selectedPeriod = "Today".obs;
  final List<String> periods = ["Today", "Week", "Month"];

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final data = await NativeTransactions.getTransactions();

      print("RAW DATA: $data");

      allTransactions.value = data;
      applyFilter();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 FIXED DATE PARSER (handles timestamp + ISO)
  DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;

    final str = raw.toString();

    // ✅ case 1: timestamp (milliseconds)
    if (RegExp(r'^\d+$').hasMatch(str)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(str));
    }

    // ✅ case 2: ISO string
    return DateTime.tryParse(str);
  }

  void applyFilter() {
    final now = DateTime.now();

    DateTime start;
    DateTime end = now;

    if (selectedPeriod.value == "Today") {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
    } else if (selectedPeriod.value == "Week") {
      start = now.subtract(const Duration(days: 7));
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    final filtered = allTransactions.where((tx) {
      final date = parseDate(tx['dateTime']);

      if (date == null) return true; // never hide data

      return date.isAfter(start) && date.isBefore(end);
    }).toList();

    // ✅ sort latest first
    filtered.sort((a, b) {
      final da = parseDate(a['dateTime']) ?? DateTime(2000);
      final db = parseDate(b['dateTime']) ?? DateTime(2000);
      return db.compareTo(da);
    });

    transactions.value = filtered;
    calculateTotals();
  }

  void calculateTotals() {
    double spent = 0;
    double received = 0;

    for (var tx in transactions) {
      final double amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      final String type = (tx['type'] ?? '').toString().toUpperCase();

      if (type == 'EXPENSE') {
        spent += amt;
      } else if (type == 'INCOME') {
        received += amt;
      }
    }

    totalSpent.value = spent;
    totalReceived.value = received;
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    applyFilter();
  }

  Future<void> markAsSynced(int id) async {
    try {
      await NativeTransactions.markSynced(id);
      await fetchTransactions();
    } catch (e) {
      Get.snackbar("Error", "Failed to update transaction: $e");
    }
  }
}