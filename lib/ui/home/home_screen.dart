import 'package:expense_tracker/services/permission/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => PermissionDialog()),
            icon: const Icon(Icons.security),
          ),
          IconButton(
            onPressed: controller.fetchTransactions,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "No transactions found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: controller.fetchTransactions,
                  child: const Text("Refresh"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(tx['time'] ?? 0);
            final String formattedDate = DateFormat('dd MMM, hh:mm a').format(date);
            
            final String type = (tx['type'] ?? 'DEBIT').toString().toUpperCase();
            final bool isCredit = type == 'CREDIT';
            final double amount = tx['amount'] ?? 0.0;
            final String? merchant = tx['merchant'];
            final String? category = tx['category'];
            final String? account = tx['account'];
            final double? balance = tx['balance'];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(
                    isCredit ? Icons.add : Icons.remove,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  "₹$amount",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isCredit ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant ?? tx['sender'] ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(fontSize: 10, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                  onPressed: () => controller.markAsSynced(tx['id']),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (account != null) detailRow("Account", account),
                        if (balance != null) detailRow("Balance", "₹$balance"),
                        detailRow("Sender", tx['sender'] ?? "N/A"),
                        const SizedBox(height: 8),
                        const Text("Message:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          tx['message'] ?? "",
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
