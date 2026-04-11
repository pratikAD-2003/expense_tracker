import 'package:expense_tracker/services/shared_pref_service.dart';
import 'package:expense_tracker/ui/bottom_nav/bottom_nav_screen.dart';
import 'package:expense_tracker/ui/intro/intro_screen.dart';
import 'package:get/get.dart';

import '../../route/app_routes.dart';
import '../../utils/navigation_helper.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final isNewUser = await SharedPrefService.isNewUser();

    if (isNewUser) {
      NavigationHelper.navigateTo(AppRoutes.introScreen);
    } else {
      NavigationHelper.navigateTo(AppRoutes.bottomNavScreen);
    }
  }
}
