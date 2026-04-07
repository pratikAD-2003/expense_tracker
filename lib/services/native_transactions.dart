import 'package:flutter/services.dart';

class NativeTransactions {

  static const MethodChannel _channel =
  MethodChannel("native_notification");

  static Future<List<Map>> getTransactions() async {

    final List data =
    await _channel.invokeMethod("getSms");

    return data.map((e) => Map.from(e)).toList();
  }

  static Future<void> markSynced(int id) async {

    await _channel.invokeMethod(
      "markSmsSynced",
      {"id": id},
    );
  }
}