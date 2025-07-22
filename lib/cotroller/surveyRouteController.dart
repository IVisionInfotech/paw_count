import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/MapsScreen/models/CityBorderModel.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class SurveyRouteController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var adminList = <User>[].obs;
  var surveyorsList = <User>[].obs;
  var subAdminList = <User>[].obs;
  RxList<String> selectedSurveyors = <String>[].obs;
  var selectedSurveyorUsers = <User>[].obs;

  var selectedSubAdmin = 0.obs;
  var selectedAdmin = 0.obs;
  var selectedAdminint;
  var selectedZone = ''.obs;
  var selectedArea = ''.obs;
  var selectedWard = ''.obs;
  var selectedSurveyor = ''.obs;

  final routeNameController = TextEditingController();
  final coordinatesController = TextEditingController();
  RxList<LatLng> routeCoordinates = <LatLng>[].obs;

  var allowReallocation = false.obs;
  var routeConfirm = false.obs;
  var isLoading = false.obs;

  var errorMessage = "".obs;

  final roleType = CommonUtils.getUserRole();

  bool get shouldShowAdmin {
    return roleType == UrlConstants.SUPER_ADMIN;
  }

  bool get shouldShowSubAdmin {
    return roleType == UrlConstants.SUPER_ADMIN ||
        roleType == UrlConstants.ADMIN;
  }

  bool validateDateFields() {
    if (!formKey.currentState!.validate()) {
      CommonUtils.buildSnackBar(
        'Please fill in all required fields',
        'Validation',
        AppColors.red,
        2,
      );
      return false;
    }
    if (selectedStartDate.value == null) {
      CommonUtils.buildSnackBar(
        'Please select a start date',
        'Validation',
        AppColors.red,
        2,
      );
      return false;
    }
    if (selectedEndDate.value == null) {
      CommonUtils.buildSnackBar(
        'Please select an end date',
        'Validation',
        AppColors.red,
        2,
      );
      return false;
    }
    if (selectedEndDate.value!.isBefore(selectedStartDate.value!)) {
      CommonUtils.buildSnackBar(
        'End date must be after start date',
        'Validation',
        AppColors.red,
        2,
      );
      return false;
    }
    return true;
  }

  var selectedRole = ''.obs;
  final dbHelper = DatabaseHelper();
  var zoneList = <LocationModel>[].obs;
  var wardList = <LocationModel>[].obs;
  var areaList = <LocationModel>[].obs;

  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);
  RxList<CityBorderModel> cityBorderList = <CityBorderModel>[].obs;

  Future<void> initCheckCondition(RouteDataModel? routes) async {
    if (routes != null) {
      routeNameController.text = routes.routeName ?? "N/A";
      selectedZone.value = routes.zoneName ?? "N/A";
      selectedArea.value = routes.areaName ?? "N/A";
      selectedWard.value = routes.wardName ?? "N/A";
      zoneList.assign(
        LocationModel(
          locationId: routes.zoneId,
          parentId: routes.cityId,
          locationName: routes.zoneName ?? "N/A",
          locationType: "Zone",
          deleteStatus: 0,
        ),
      );
      areaList.assign(
        LocationModel(
          locationId: routes.areaId,
          parentId: routes.zoneId,
          locationName: routes.areaName ?? "N/A",
          locationType: "Area",
          deleteStatus: 0,
        ),
      );
      wardList.assign(
        LocationModel(
          locationId: routes.wardId,
          parentId: routes.areaId,
          locationName: routes.wardName ?? "N/A",
          locationType: "Ward",
          deleteStatus: 0,
        ),
      );
      selectedSubAdmin.value = routes.subAdminId;
      selectedStartDate.value = DateTime.parse(routes.startDate);
      selectedEndDate.value = DateTime.parse(routes.endDate);

      List<LatLngModel> coordinates = routes.map;
      String formattedCoordinates = coordinates
          .map((point) {
            return '(${point.lat}, ${point.lng})';
          })
          .join(", ");
      allowReallocation.value = routes.reallocation == 1;
      coordinatesController.text = formattedCoordinates;

      await loadSurveyorList(routes.subAdminId.toString(), routes);
    } else {
      if (shouldShowAdmin) {
        loadAdminList();
      }
      if (shouldShowSubAdmin) {
        loadSubAdminList(CommonUtils.getUserId().toString());
      }
      if (roleType == UrlConstants.SUB_ADMIN) {
        fetchZone(CommonUtils.getCurrentUser()!.assignCityId!);
        loadSurveyorList(CommonUtils.getUserId().toString());
      }
    }
  }

  Future<void> loadAdminList() async {
    final adminId = CommonUtils.getUserId().toString();
    final url = '${UrlConstants.getUsersList}/${UrlConstants.ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);

    if (response != null && response.status == 1 && response.userList != null) {
      adminList.assignAll(response.userList!);
    } else {
      adminList.clear();
    }
  }

  Future<void> loadSubAdminList(String adminId) async {
    final url =
        '${UrlConstants.getUsersList}/${UrlConstants.SUB_ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);

    if (response != null && response.status == 1 && response.userList != null) {
      subAdminList.assignAll(response.userList!);
    } else {
      subAdminList.clear();
    }
  }

  Future<void> loadSurveyorList(
    String subAdminId, [
    RouteDataModel? routes,
  ]) async {
    final url =
        '${UrlConstants.getUsersList}/${UrlConstants.SURVEYOR}/$subAdminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);

    if (response != null && response.status == 1 && response.userList != null) {
      surveyorsList.assignAll(response.userList!);
      selectedSurveyorUsers.value =
          surveyorsList
              .where((user) => selectedSurveyors.contains(user.name))
              .toList();
      if (routes != null) {

        adminList.assign(
          User(
            userId: surveyorsList.first.adminId,
            name: surveyorsList.first.adminName,
          ),
        );

        subAdminList.assign(
          User(
            userId: surveyorsList.first.subAdminId,
            name: surveyorsList.first.subAdminName,
          ),
        );
        selectedAdmin.value = surveyorsList.first.adminId!;
        selectedSubAdmin.value = surveyorsList.first.subAdminId!;
      }
    } else {
      surveyorsList.clear();
    }
  }

  Future<void> fetchZone(int cityId) async {
    try {
      final data = await dbHelper.getZonesByCity(cityId);
      zoneList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchArea(int zoneId) async {
    try {
      final data = await dbHelper.getAreaByWards(zoneId);
      areaList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchWard(int areaId) async {
    try {
      final data = await dbHelper.getWardsByZone(areaId);
      wardList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCityBorder(int cityId) async {
    errorMessage("");
    final response = await CommonUtils.callApi(
      url: "${UrlConstants.cityBorderEdit}/$cityId",
      method: "GET",
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar(
        "${response!.message}",
        "Error",
        AppColors.red,
        2,
      );
      isLoading.value = false;
      return;
    }

    if (response.status == 1) {
      Future.delayed(Duration(seconds: 1));
      if (response.cityBorders != null && response.cityBorders!.isNotEmpty) {
        cityBorderList.assignAll(response.cityBorders!);
      } else {
        cityBorderList.clear();
      }
    } else {
      errorMessage(response.message ?? 'Failed to fetch border data.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }

    isLoading.value = false;
  }

  Future<void> submitRoute(
    String? cityId,
    String? zoneId,
    String? areaId,
    String? wardId,
    int? subAdminId,
    String? flag, {
    int? routeId,
  }) async {
    String surveyorIds = selectedSurveyorUsers
        .map((e) => e.userId.toString())
        .join(',');

    String startDateString =
        selectedStartDate.value != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedStartDate.value!)
            : '';
    String endDateString =
        selectedEndDate.value != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedEndDate.value!)
            : '';

    int? acceptBy;
    if (selectedSurveyorUsers.length == 1) {
      acceptBy = selectedSurveyorUsers.first.userId;
    }

    isLoading(true);
    errorMessage("");

    try {
      Map<String, dynamic> body = {};

      if (flag == "Update") {
        body = {
          "route_id": routeId,
          "surveyor_id": surveyorIds,
          "start_date": startDateString,
          "end_date": endDateString,
        };
      } else {
        body = {
          "created_by": CommonUtils.getUserId(),
          "city_id": cityId,
          "sub_admin_id": subAdminId,
          "route_name": routeNameController.text.toUpperCase(),
          "zone_id": zoneId,
          "ward_id": wardId,
          "area_id": areaId,
          "surveyor_id": surveyorIds,
          "reallocation": allowReallocation.value ? 1 : 0,
          "route_confirm": routeConfirm.value ? 1 : 0,
          "start_date": startDateString,
          "end_date": endDateString,
          "map":
              routeCoordinates
                  .map(
                    (coord) => {"lat": coord.latitude, "lng": coord.longitude},
                  )
                  .toList(),
          "accept_by": acceptBy ?? 0,
        };
      }

      final response = await CommonUtils.callApi(
        url:
            flag == "Update"
                ? UrlConstants.routeMapUpdate
                : UrlConstants.routeMapCreate,
        body: body,
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
        isLoading(false);
        return;
      }

      if (response.status == 1) {
        Get.back();
        CommonUtils.buildSnackBar(
          "Success",
          "${response.message}",
          AppColors.green,
          2,
        );
        clearForm();
      } else {
        errorMessage(response.message ?? 'Failed to submit route');
        CommonUtils.buildSnackBar(
          "Error",
          errorMessage.value,
          AppColors.red,
          2,
        );
      }
    } catch (e) {
      errorMessage("Exception111: $e");
      CommonUtils.buildSnackBar(
        "Exception",
        errorMessage.value,
        AppColors.red,
        2,
      );
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    // selectedSubAdmin.value = '';
    selectedZone.value = '';
    selectedArea.value = '';
    selectedSurveyor.value = '';
    routeNameController.clear();
    // coordinatesController.clear();
    allowReallocation.value = false;
    wardList.clear();
    selectedWard.value = '';
  }

  @override
  void onClose() {
    routeNameController.dispose();
    coordinatesController.dispose();
    super.onClose();
  }
}
