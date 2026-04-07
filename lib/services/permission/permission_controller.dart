import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  RxBool notification = false.obs;
  RxBool sms = false.obs;
  RxBool battery = false.obs;

  double get progress {
    int count = 0;
    if (notification.value) count++;
    if (sms.value) count++;
    if (battery.value) count++;

    return count / 3;
  }

  bool get allGranted => notification.value && sms.value && battery.value;

  Future<void> checkPermissions() async {
    notification.value = await Permission.notification.isGranted;
    sms.value = await Permission.sms.isGranted;
    battery.value = await Permission.ignoreBatteryOptimizations.isGranted;
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
}
