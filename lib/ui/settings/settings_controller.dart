import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  static const _channel = MethodChannel('native_notification');

  var isNotificationsEnabled = true.obs;
  var isSoundEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final Map? settings = await _channel.invokeMapMethod('getSettings');
      if (settings != null) {
        isNotificationsEnabled.value = settings['isNotificationsEnabled'] ?? true;
        isSoundEnabled.value = settings['isSoundEnabled'] ?? true;
      }
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
}
