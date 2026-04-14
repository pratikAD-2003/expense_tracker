import 'package:flutter/services.dart';

class NativeTransactions {
  static const MethodChannel _channel = MethodChannel("native_notification");

  static Future<List<Map>> getTransactions() async {
    final List data = await _channel.invokeMethod("getSms");
    return data.map((e) => Map.from(e)).toList();
  }

  static Future<void> markSynced(int id) async {
    await _channel.invokeMethod(
      "markSmsSynced",
      {"id": id},
    );
  }

  static Future<int> addTransaction(Map<String, dynamic> tx) async {
    return await _channel.invokeMethod("addTransaction", tx);
  }

  static Future<bool> updateTransaction(Map<String, dynamic> tx) async {
    return await _channel.invokeMethod("updateTransaction", tx);
  }

  static Future<bool> deleteTransaction(int id) async {
    return await _channel.invokeMethod("deleteTransaction", {"id": id});
  }

  static Future<void> openAutoStartSettings() async {
    await _channel.invokeMethod("openAutoStartSettings");
  }
}
