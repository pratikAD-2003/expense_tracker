import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionHistoryController extends GetxController {
  var allTransactions = <Map>[].obs;
  var groupedTransactions = <String, List<Map>>{}.obs;
  var isLoading = true.obs;
  var selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _handleArgs();
    fetchTransactions();
  }

  void _handleArgs() {
    if (Get.arguments != null) {
      if (Get.arguments is DateTime) {
        selectedDate.value = Get.arguments;
      } else if (Get.arguments is String) {
        try {
          // Attempt to parse the date string passed from Analytics summary
          selectedDate.value = DateFormat('dd MMM yyyy').parse(Get.arguments);
        } catch (e) {
          selectedDate.value = DateTime.tryParse(Get.arguments);
        }
      }
    }
  }

  Future<void> fetchTransactions() async {
    try {
      isLoading.value = true;
      final data = await NativeTransactions.getTransactions();
      allTransactions.assignAll(data);
      _groupTransactions();
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

  void _groupTransactions() {
    final Map<String, List<Map>> groups = {};
    
    // Filter by selectedDate if it exists
    Iterable<Map> filtered = allTransactions;
    if (selectedDate.value != null) {
      filtered = allTransactions.where((tx) {
        final date = parseDate(tx['dateTime']);
        if (date == null) return false;
        return date.year == selectedDate.value!.year &&
               date.month == selectedDate.value!.month &&
               date.day == selectedDate.value!.day;
      });
    }

    // Sort: latest first
    final sortedList = filtered.toList();
    sortedList.sort((a, b) {
      final da = parseDate(a['dateTime']) ?? DateTime(2000);
      final db = parseDate(b['dateTime']) ?? DateTime(2000);
      return db.compareTo(da);
    });

    for (var tx in sortedList) {
      final date = parseDate(tx['dateTime']);
      if (date == null) continue;
      
      final dateStr = _getDateHeader(date);
      if (groups.containsKey(dateStr)) {
        groups[dateStr]!.add(tx);
      } else {
        groups[dateStr] = [tx];
      }
    }
    groupedTransactions.assignAll(groups);
  }

  String _getDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return "Today";
    } else if (transactionDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
    _groupTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await NativeTransactions.deleteTransaction(id);
    fetchTransactions();
  }
}
