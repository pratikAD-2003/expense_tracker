import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:expense_tracker/services/native_transactions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  static const _channel = MethodChannel('native_notification');

  var isNotificationsEnabled = true.obs;
  var isSoundEnabled = true.obs;
  var isExporting = false.obs;
  var isImporting = false.obs;
  var isAutoStartEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final Map? settings = await _channel.invokeMapMethod('getSettings');
      if (settings != null) {
        isNotificationsEnabled.value =
            settings['isNotificationsEnabled'] ?? true;
        isSoundEnabled.value = settings['isSoundEnabled'] ?? true;
      }
      
      final prefs = await SharedPreferences.getInstance();
      isAutoStartEnabled.value = prefs.getBool('auto_start_granted') ?? false;
    } catch (e) {
      print("Error loading native settings: $e");
    }
  }

  Future<void> toggleNotifications(bool value) async {
    isNotificationsEnabled.value = value;
    try {
      await _channel.invokeMethod('updateSetting', {
        'key': 'isNotificationsEnabled',
        'value': value,
      });
    } catch (e) {
      print("Error updating notification setting: $e");
    }
  }

  Future<void> toggleSoundEnable(bool value) async {
    isSoundEnabled.value = value;
    try {
      await _channel.invokeMethod('updateSetting', {
        'key': 'isSoundEnabled',
        'value': value,
      });
    } catch (e) {
      print("Error updating sound setting: $e");
    }
  }

  Future<void> openAutoStartSettings() async {
    await NativeTransactions.openAutoStartSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_granted', true);
    isAutoStartEnabled.value = true;
  }

  Future<void> exportData() async {
    try {
      isExporting.value = true;
      final transactions = await NativeTransactions.getTransactions();

      if (transactions.isEmpty) {
        Get.snackbar("Export", "No transactions to export");
        return;
      }

      final jsonString = jsonEncode(transactions);
      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      // On Android/iOS, 'bytes' parameter is required for saveFile to work correctly
      String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select where to save your backup',
        fileName: 'pocketca_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (selectedPath != null) {
        Get.snackbar("Export Success", "Backup saved successfully");
      }
    } catch (e) {
      Get.snackbar("Export Error", e.toString());
      print("Export Error $e");
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> importData() async {
    try {
      isImporting.value = true;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        List<dynamic> data = jsonDecode(content);

        int count = 0;
        for (var item in data) {
          if (item is Map) {
            final tx = Map<String, dynamic>.from(item);
            // Remove ID to let DB generate a new one, or handle duplicates
            tx.remove('id');
            await NativeTransactions.addTransaction(tx);
            count++;
          }
        }
        Get.snackbar("Import Success", "Imported $count transactions");
      }
    } catch (e) {
      Get.snackbar("Import Error", "Failed to import data: $e");
    } finally {
      isImporting.value = false;
    }
  }
}
