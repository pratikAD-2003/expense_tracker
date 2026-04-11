import 'package:expense_tracker/ui/add_transaction/add_transaction_controller.dart';
import 'package:expense_tracker/ui/analytics/analytics_controller.dart';
import 'package:expense_tracker/ui/bottom_nav/bottom_nav_controller.dart';
import 'package:expense_tracker/ui/home/home_controller.dart';
import 'package:expense_tracker/ui/notification/notification_controller.dart';
import 'package:expense_tracker/ui/settings/settings_controller.dart';
import 'package:expense_tracker/ui/transaction_history/transaction_history_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: false);
  }
}

class AddTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AddTransactionController>(
      AddTransactionController(),
      permanent: false,
    );
  }
}

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AnalyticsController>(AnalyticsController(), permanent: false);
  }
}

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NotificationController>(NotificationController(), permanent: false);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SettingsController>(SettingsController(), permanent: false);
  }
}


class TransactionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TransactionHistoryController>(TransactionHistoryController(), permanent: false);
  }
}

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BottomNavController>(BottomNavController(), permanent: false);
    Get.put<HomeController>(HomeController(), permanent: false);
    Get.put<AnalyticsController>(AnalyticsController(), permanent: false);
  }
}
