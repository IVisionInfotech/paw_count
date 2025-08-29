import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/City/locationListScreen.dart';
import 'package:survey_dogapp/components/Dashboard/HomePageSurveyor.dart';
import 'package:survey_dogapp/components/Manage/survey_route_page.dart';
import 'package:survey_dogapp/components/dog_type_management_screen.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/components/users_list.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
class ManageController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var roleType = ''.obs;
  var manageItems = <Map<String, dynamic>>[].obs;
  final List<Map<String, dynamic>> allItems = [
    {'title': 'State Admin', 'icon': Icons.admin_panel_settings, 'screen': UsersList(title: 'State Admin List'), 'count': 0},
    {'title': 'City Admin', 'icon': Icons.supervised_user_circle, 'screen': UsersList(title: 'City Admin List'), 'count': 0},
    {'title': 'Surveyor', 'icon': Icons.badge, 'screen': UsersList(title: 'Surveyor List'), 'count': 0},
    {'title': 'Associates', 'icon': Icons.person_pin_sharp, 'screen': UsersList(title: 'Associates List'), 'count': 0},
    {'title': 'Dog Type', 'icon': Icons.pets, 'screen': DogTypeManagementScreen(), 'count': 0},
    {'title': 'Location Manage', 'icon': Icons.location_on, 'screen': Locationlistscreen()},
    {'title': 'Survey Route', 'icon': Icons.route, 'screen': Homepagesurveyor(flag: "Manage",), 'count': 0},
  ];
  @override
  void onInit() {
    super.onInit();
    fetchRoleAndLoadItems();
  }
  void fetchRoleAndLoadItems() async {
    roleType.value = CommonUtils.getUserRole() ?? "";
    loadManageItems();
  }
  void loadManageItems() {
    switch (roleType.value) {
      case UrlConstants.SUPER_ADMIN:
        manageItems.assignAll(allItems);
        break;
      case UrlConstants.ADMIN:
        manageItems.assignAll(allItems.where((item) => item['title'] != 'State Admin').toList());
        break;
      case UrlConstants.SUB_ADMIN:
        manageItems.assignAll(allItems.where((item) => item['title'] != 'State Admin' && item['title'] != 'City Admin').toList());
        break;
      default:
        manageItems.clear();
    }
  }
  Future<void> fetchCountById() async {
    isLoading(true);
    final userId = CommonUtils.getUserId().toString();
    final response = await CommonUtils.callApi(
      url: UrlConstants.countManage,
      body: {'user_id': userId},
    );
    isLoading(false);
    if (response == null) {
      errorMessage('Failed to fetch users. Please check your connection.');
      return;
    }
    if (response.status == 1 && response.countModel != null) {
      for (var item in allItems) {
        final title = item['title'] == 'Staff' ? 'Associates' : item['title'];
        final countData = response.countModel;
        if (item.containsKey('count')) {
          item['count'] = {
            'State Admin': countData!.adminCount ?? 0,
            'City Admin': countData.subadminCount ?? 0,
            'Surveyor': countData.surveyorCount ?? 0,
            'Dog Type': countData.dogTypeCount ?? 0,
            'Survey Route': countData.surveyRouteCount ?? 0,
            'Associates': countData.staffCount ?? 0,
          }[title] ?? 0;
        }
      }
      loadManageItems();
    } else {
      CommonUtils.buildSnackBar(response.message ?? "No users found.", "Error", AppColors.red, 2);
    }
  }
}