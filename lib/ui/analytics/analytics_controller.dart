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
  var selectedPeriod = "1W".obs;
  final List<String> periods = ["Today", "1W", "6M", "1Y"];

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
    bool isMonthlyGrouping = false;

    if (selectedPeriod.value == "Today") {
      start = DateTime(now.year, now.month, now.day);
    } else if (selectedPeriod.value == "1W") {
      start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));
    } else if (selectedPeriod.value == "6M") {
      start = DateTime(now.year, now.month - 5, 1);
      isMonthlyGrouping = true;
    } else if (selectedPeriod.value == "1Y") {
      start = DateTime(now.year - 1, now.month + 1, 1);
      isMonthlyGrouping = true;
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    double income = 0;
    double expense = 0;

    Map<String, DailyStats> dataMap = {};

    // Initialize dataMap for the chart based on period
    if (selectedPeriod.value == "1W") {
      for (int i = 0; i < 7; i++) {
        final date = start.add(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(date);
        dataMap[key] = DailyStats(date: date);
      }
    } else if (selectedPeriod.value == "Today") {
      dataMap[DateFormat('yyyy-MM-dd').format(now)] = DailyStats(date: now);
    } else if (isMonthlyGrouping) {
      int monthsCount = selectedPeriod.value == "6M" ? 6 : 12;
      for (int i = 0; i < monthsCount; i++) {
        final date = DateTime(start.year, start.month + i, 1);
        final key = DateFormat('yyyy-MM').format(date);
        dataMap[key] = DailyStats(date: date);
      }
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

        String key;
        if (isMonthlyGrouping) {
          key = DateFormat('yyyy-MM').format(date);
        } else {
          key = DateFormat('yyyy-MM-dd').format(date);
        }

        if (dataMap.containsKey(key)) {
          if (type == 'EXPENSE') {
            dataMap[key]!.expense += amt;
          } else if (type == 'INCOME') {
            dataMap[key]!.income += amt;
          }
        } else if (!isMonthlyGrouping &&
            selectedPeriod.value != "1W" &&
            selectedPeriod.value != "Today") {
          // For any other non-initialized daily views
          dataMap[key] = DailyStats(
            date: date,
            income: type == 'INCOME' ? amt : 0,
            expense: type == 'EXPENSE' ? amt : 0,
          );
        }
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;

    // Prepare Chart Data
    var sortedChartData = dataMap.values.toList();
    sortedChartData.sort((a, b) => a.date.compareTo(b.date));
    chartData.assignAll(sortedChartData);

    // Prepare History Data (summarized)
    var sortedHistory = dataMap.values
        .where((s) => s.income > 0 || s.expense > 0)
        .toList();
    sortedHistory.sort((a, b) => b.date.compareTo(a.date));

    history.assignAll(
      sortedHistory
          .map(
            (s) => {
              "date": isMonthlyGrouping
                  ? DateFormat('MMM yyyy').format(s.date)
                  : DateFormat('dd MMM yyyy').format(s.date),
              "income": s.income,
              "expense": s.expense,
            },
          )
          .toList(),
    );
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    calculateAnalytics();
  }

  void nextPeriod() {
    int currentIndex = periods.indexOf(selectedPeriod.value);
    if (currentIndex < periods.length - 1) {
      changePeriod(periods[currentIndex + 1]);
    }
  }

  void previousPeriod() {
    int currentIndex = periods.indexOf(selectedPeriod.value);
    if (currentIndex > 0) {
      changePeriod(periods[currentIndex - 1]);
    }
  }
}
