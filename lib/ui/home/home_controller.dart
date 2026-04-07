import 'package:expense_tracker/services/native_transactions.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var transactions = <Map>[].obs;
  var isLoading = true.obs;

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
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch transactions: $e");
    } finally {
      isLoading.value = false;
    }
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
