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
      name: AppRoutes.bottomNavScreen,
      page: () => BottomNavScreen(),
      binding: BottomNavBinding(),
    ),
  ];
}
