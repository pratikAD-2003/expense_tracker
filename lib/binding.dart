
import 'package:expense_tracker/ui/bottom_nav/bottom_nav_controller.dart';
import 'package:expense_tracker/ui/home/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: false);
  }
}

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BottomNavController>(BottomNavController(), permanent: false);
    Get.put<HomeController>(HomeController(), permanent: false);
    // Get.put<FavoriteController>(FavoriteController(), permanent: false);
    // Get.put<CartController>(CartController(), permanent: false);
    // Get.put<ProfileController>(ProfileController(), permanent: false);
  }
}
