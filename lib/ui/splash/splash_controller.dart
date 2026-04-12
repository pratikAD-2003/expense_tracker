import 'package:get/get.dart';
import '../../route/app_routes.dart';
import '../../services/shared_pref_service.dart';
import '../../utils/navigation_helper.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    final isNewUser = await SharedPrefService.isNewUser();

    if (isNewUser) {
      NavigationHelper.navigateAndClear(AppRoutes.introScreen);
    } else {
      NavigationHelper.navigateAndClear(AppRoutes.bottomNavScreen);
    }
  }
}
