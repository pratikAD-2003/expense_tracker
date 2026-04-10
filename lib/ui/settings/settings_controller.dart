import 'package:get/get.dart';

class SettingsController extends GetxController {
  var isNotificationsEnabled = true.obs;
  var isDarkMode = false.obs;
  var selectedCurrency = 'USD'.obs;

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
  }

  void updateCurrency(String value) {
    selectedCurrency.value = value;
  }
}
