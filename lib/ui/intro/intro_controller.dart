import 'package:expense_tracker/services/shared_pref_service.dart';
import 'package:expense_tracker/ui/bottom_nav/bottom_nav_screen.dart';
import 'package:get/get.dart';

import '../../route/app_routes.dart';
import '../../utils/navigation_helper.dart';

class IntroController extends GetxController {
  Future<void> completeIntro() async {
    await SharedPrefService.setIsNewUser(false);
    NavigationHelper.navigateTo(AppRoutes.bottomNavScreen);
  }
}
