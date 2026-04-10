import 'package:expense_tracker/ui/add_transaction/add_transaction_screen.dart';
import 'package:expense_tracker/ui/analytics/analytics_screen.dart';
import 'package:expense_tracker/ui/notification/notification_screen.dart';
import 'package:expense_tracker/ui/settings/settings_screen.dart';
import 'package:get/get.dart';

import '../binding.dart';
import '../ui/bottom_nav/bottom_nav_screen.dart';
import '../ui/home/home_screen.dart';
import 'app_routes.dart';

class AppBinding {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.analyticsScreen,
      page: () => AnalyticsScreen(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.addTransactionScreen,
      page: () => AddTransactionScreen(),
      binding: AddTransactionBinding(),
    ),
    GetPage(
      name: AppRoutes.bottomNavScreen,
      page: () => BottomNavScreen(),
      binding: BottomNavBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsScreen,
      page: () => SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationScreen,
      page: () => NotificationScreen(),
      binding: NotificationBinding(),
    ),
  ];
}
