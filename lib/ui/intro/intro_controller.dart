import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../route/app_routes.dart';
import '../../services/shared_pref_service.dart';
import '../../utils/navigation_helper.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeIntro();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> completeIntro() async {
    await SharedPrefService.setIsNewUser(false);
    NavigationHelper.navigateAndClear(AppRoutes.bottomNavScreen);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
