import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var transactions = <Map>[].obs;
  var isLoading = true.obs;

  var totalSpent = 0.0.obs;
  var totalReceived = 0.0.obs;

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
      _calculateTotals();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateTotals() {
    double spent = 0;
    double received = 0;
    for (var tx in transactions) {
      final double amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      final String type = (tx['type'] ?? '').toString().toLowerCase();
      if (type == 'debit') {
        spent += amt;
      } else if (type == 'credit') {
        received += amt;
      }
    }
    totalSpent.value = spent;
    totalReceived.value = received;
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
