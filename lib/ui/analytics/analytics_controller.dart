import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DailyStats {
  final DateTime date;
  double income;
  double expense;

  DailyStats({required this.date, this.income = 0.0, this.expense = 0.0});
}

class AnalyticsController extends GetxController {
  var selectedPeriod = "Week".obs;
  final List<String> periods = ["Today", "Week", "Month"];
  
  var isLoading = true.obs;
  var allTransactions = <Map>[].obs;
  
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  
  var chartData = <DailyStats>[].obs;
  var history = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final data = await NativeTransactions.getTransactions();
      allTransactions.value = data;
      calculateAnalytics();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch analytics: $e");
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString();
    if (RegExp(r'^\d+$').hasMatch(str)) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(str));
    }
    return DateTime.tryParse(str);
  }

  void calculateAnalytics() {
    final now = DateTime.now();
    DateTime start;
    
    if (selectedPeriod.value == "Today") {
      start = DateTime(now.year, now.month, now.day);
    } else if (selectedPeriod.value == "Week") {
      start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    double income = 0;
    double expense = 0;
    
    Map<String, DailyStats> dailyMap = {};
    
    // Initialize dailyMap for the chart based on period
    if (selectedPeriod.value == "Week") {
      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(date);
        dailyMap[key] = DailyStats(date: date);
      }
    } else if (selectedPeriod.value == "Today") {
      dailyMap[DateFormat('yyyy-MM-dd').format(now)] = DailyStats(date: now);
    }

    for (var tx in allTransactions) {
      final date = _parseDate(tx['dateTime']);
      if (date == null) continue;
      
      if (date.isAfter(start.subtract(const Duration(seconds: 1)))) {
        final double amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
        final String type = (tx['type'] ?? '').toString().toUpperCase();
        
        if (type == 'EXPENSE') {
          expense += amt;
        } else if (type == 'INCOME') {
          income += amt;
        }

        final key = DateFormat('yyyy-MM-dd').format(date);
        if (selectedPeriod.value == "Month") {
          if (!dailyMap.containsKey(key)) {
            dailyMap[key] = DailyStats(date: date);
          }
        }
        
        if (dailyMap.containsKey(key)) {
          if (type == 'EXPENSE') {
            dailyMap[key]!.expense += amt;
          } else if (type == 'INCOME') {
            dailyMap[key]!.income += amt;
          }
        }
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    
    // Prepare Chart Data
    var sortedChartData = dailyMap.values.toList();
    sortedChartData.sort((a, b) => a.date.compareTo(b.date));
    chartData.assignAll(sortedChartData);
    
    // Prepare History Data (Daily summarized)
    var sortedHistory = dailyMap.values.where((s) => s.income > 0 || s.expense > 0).toList();
    sortedHistory.sort((a, b) => b.date.compareTo(a.date));
    
    history.assignAll(sortedHistory.map((s) => {
      "date": DateFormat('dd MMM yyyy').format(s.date),
      "income": s.income,
      "expense": s.expense,
    }).toList());
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    calculateAnalytics();
  }
}
