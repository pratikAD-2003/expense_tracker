import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  var selectedPeriod = "Today".obs;
  final List<String> periods = ["Today", "Week", "Month"];

  // Static mock data for the weekly chart
  final List<double> weeklyIncome = [200, 500, 300, 700, 400, 650, 450];
  final List<double> weeklyExpense = [150, 420, 450, 300, 200, 500, 350];

  // Static mock data for history
  final List<Map<String, dynamic>> history = [
    {"date": "12 Feb 2025", "income": 500.0, "expense": 150.0},
    {"date": "11 Feb 2025", "income": 300.0, "expense": 450.0},
    {"date": "10 Feb 2025", "income": 700.0, "expense": 300.0},
    {"date": "09 Feb 2025", "income": 400.0, "expense": 200.0},
  ];

  void changePeriod(String period) {
    selectedPeriod.value = period;
  }
}
