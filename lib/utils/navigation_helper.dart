import 'package:get/get.dart';

class NavigationHelper {
  static navigateTo(String route, {dynamic args}) =>
      Get.toNamed(route, arguments: args);

  static navigateAndReplace(String route) => Get.offNamed(route);

  static navigateAndClear(String route) => Get.offAllNamed(route);

  static backToPrevious() => Get.back();
}
