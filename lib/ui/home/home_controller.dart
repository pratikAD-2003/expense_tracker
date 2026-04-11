import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeChartData {
  final String label;
  final double amount;
  HomeChartData({required this.label, required this.amount});
}

class HomeController extends GetxController {
  var allTransactions = <Map>[].obs;
  var transactions = <Map>[].obs;
  var isLoading = true.obs;

  var totalSpent = 0.0.obs;
  var totalReceived = 0.0.obs;

  var selectedPeriod = "Today".obs;
  final List<String> periods = ["Today", "Week", "Month"];
  
  var chartData = <HomeChartData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final data = await NativeTransactions.getTransactions();
      allTransactions.value = data;
      applyFilter();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString();
    if (RegExp(r'^\d+$').hasMatch(str)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(str));
    }
    return DateTime.tryParse(str);
  }

  void applyFilter() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now.add(const Duration(minutes: 1));

    if (selectedPeriod.value == "Today") {
      start = DateTime(now.year, now.month, now.day);
    } else if (selectedPeriod.value == "Week") {
      start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    final filtered = allTransactions.where((tx) {
      final date = parseDate(tx['dateTime']);
      if (date == null) return true;
      return date.isAfter(start.subtract(const Duration(seconds: 1))) && date.isBefore(end);
    }).toList();

    filtered.sort((a, b) {
      final da = parseDate(a['dateTime']) ?? DateTime(2000);
      final db = parseDate(b['dateTime']) ?? DateTime(2000);
      return db.compareTo(da);
    });

    transactions.value = filtered;
    calculateTotals();
    calculateChartData(start, end);
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

  void calculateChartData(DateTime start, DateTime end) {
    Map<String, double> tempMap = {};
    List<HomeChartData> list = [];

    if (selectedPeriod.value == "Today") {
      // 24 Hours
      for (int i = 0; i < 24; i++) {
        tempMap[i.toString().padLeft(2, '0')] = 0.0;
      }
      for (var tx in transactions) {
        final date = parseDate(tx['dateTime']);
        if (date != null && (tx['type'] ?? '').toString().toUpperCase() == 'EXPENSE') {
          String hour = DateFormat('HH').format(date);
          tempMap[hour] = (tempMap[hour] ?? 0) + ((tx['amount'] as num?)?.toDouble() ?? 0.0);
        }
      }
      tempMap.keys.toList()..sort()..forEach((key) {
        list.add(HomeChartData(label: key, amount: tempMap[key]!));
      });
    } else if (selectedPeriod.value == "Week") {
      // 7 Days
      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        tempMap[DateFormat('E').format(date)] = 0.0;
      }
      for (var tx in transactions) {
        final date = parseDate(tx['dateTime']);
        if (date != null && (tx['type'] ?? '').toString().toUpperCase() == 'EXPENSE') {
          String day = DateFormat('E').format(date);
          if (tempMap.containsKey(day)) {
            tempMap[day] = (tempMap[day] ?? 0) + ((tx['amount'] as num?)?.toDouble() ?? 0.0);
          }
        }
      }
      // Keep chronological order from start to end
      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        String day = DateFormat('E').format(date);
        list.add(HomeChartData(label: day, amount: tempMap[day]!));
      }
    } else {
      // Month
      int daysInMonth = DateTime(start.year, start.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        tempMap[i.toString().padLeft(2, '0')] = 0.0;
      }
      for (var tx in transactions) {
        final date = parseDate(tx['dateTime']);
        if (date != null && (tx['type'] ?? '').toString().toUpperCase() == 'EXPENSE') {
          String day = DateFormat('dd').format(date);
          tempMap[day] = (tempMap[day] ?? 0) + ((tx['amount'] as num?)?.toDouble() ?? 0.0);
        }
      }
      tempMap.keys.toList()..sort()..forEach((key) {
        list.add(HomeChartData(label: key, amount: tempMap[key]!));
      });
    }
    chartData.assignAll(list);
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    applyFilter();
  }

  Future<void> deleteNotification(int id) async {
    await NativeTransactions.deleteTransaction(id);
    fetchTransactions();
  }
}
