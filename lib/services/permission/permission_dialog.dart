import 'package:expense_tracker/services/permission/permission_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionDialog extends StatelessWidget {
  final controller = Get.put(PermissionController());

  PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    controller.checkPermissions();

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Permissions Required",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "To track expenses automatically in the background, we need the following permissions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: controller.progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 20),
                permissionTile(
                  icon: Icons.notifications_active_outlined,
                  title: "Notification Permission",
                  granted: controller.notification.value,
                  onTap: controller.requestNotification,
                ),
                permissionTile(
                  icon: Icons.sms_outlined,
                  title: "SMS Permission",
                  granted: controller.sms.value,
                  onTap: controller.requestSms,
                ),
                permissionTile(
                  icon: Icons.battery_saver_outlined,
                  title: "Disable Battery Optimization",
                  granted: controller.battery.value,
                  onTap: controller.requestBatteryOptimization,
                ),
                permissionTile(
                  icon: Icons.settings_power_outlined,
                  title: "Enable Auto Start",
                  granted: controller.autoStart.value,
                  onTap: controller.requestAutoStart,
                ),
                const SizedBox(height: 20),
                if (controller.allGranted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text("Continue"),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget permissionTile({
    required IconData icon,
    required String title,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: granted ? Colors.green : Colors.orange,
            width: 1.5,
          ),
          color: granted ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: granted ? Colors.green : Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            granted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
