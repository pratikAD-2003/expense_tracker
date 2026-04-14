import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../native_transactions.dart';

class PermissionController extends GetxController {
  RxBool notification = false.obs;
  RxBool sms = false.obs;
  RxBool battery = false.obs;
  RxBool autoStart = false.obs;

  static const String _autoStartKey = 'auto_start_granted';

  double get progress {
    int count = 0;
    if (notification.value) count++;
    if (sms.value) count++;
    if (battery.value) count++;
    if (autoStart.value) count++;

    return count / 4;
  }

  bool get allGranted => notification.value && sms.value && battery.value && autoStart.value;

  Future<void> checkPermissions() async {
    notification.value = await Permission.notification.isGranted;
    sms.value = await Permission.sms.isGranted;
    battery.value = await Permission.ignoreBatteryOptimizations.isGranted;
    
    final prefs = await SharedPreferences.getInstance();
    autoStart.value = prefs.getBool(_autoStartKey) ?? false;
  }

  /// Generic handler
  Future<void> handlePermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted) {
      await checkPermissions();
      return;
    }

    if (status.isDenied) {
      var result = await permission.request();

      if (result.isGranted) {
        await checkPermissions();
      }
    }

    /// permanently denied → open settings
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> requestNotification() async {
    await handlePermission(Permission.notification);
  }

  Future<void> requestSms() async {
    await handlePermission(Permission.sms);
  }

  Future<void> requestBatteryOptimization() async {
    await handlePermission(Permission.ignoreBatteryOptimizations);
  }

  Future<void> requestAutoStart() async {
    await NativeTransactions.openAutoStartSettings();
    
    // Save to shared preferences so it doesn't ask again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartKey, true);
    autoStart.value = true;
    update();
  }
}
