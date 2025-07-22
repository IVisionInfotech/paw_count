import 'package:get/get.dart';

import '../utils/Common.dart';

class DashboardController extends GetxController {
  var activePage = 0.obs;

  var userName = CommonUtils.getUserName()?.obs ?? 'User Name'.obs;
  var userRole = (CommonUtils.getUserRole() ?? 'User Role').obs;

  String get displayRole {
    if (userRole.value == 'ADMIN') {
      return 'STATE ADMIN';
    } else if (userRole.value == 'SUB ADMIN') {
      return 'CITY ADMIN';
    } else {
      return userRole.value;
    }
  }

  var userProfile = CommonUtils.getUserProfile()?.obs;

  void updatePage(int index) {
    activePage.value = index;
  }
}
