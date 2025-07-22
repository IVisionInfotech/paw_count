import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/report_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class FilterController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final roleType = CommonUtils.getUserRole();
  final currentUserId = CommonUtils.getUserId().toString();
  var filteredRoles = <String>[].obs;
  var selectedRole = ''.obs;

  bool get shouldShowAdminDropdown {
    return roleType == UrlConstants.SUPER_ADMIN ;
  }

  bool get shouldShowSubAdminDropdown {
    return roleType == UrlConstants.SUPER_ADMIN || roleType == UrlConstants.ADMIN;
  }

  bool get shouldShowSurveyorDropdown {
    return roleType == UrlConstants.SUPER_ADMIN  || roleType == UrlConstants.ADMIN || roleType == UrlConstants.SUB_ADMIN;
  }


  var states = <LocationModel>[].obs;
  var cities = <LocationModel>[].obs;
  var zones = <LocationModel>[].obs;
  var wards = <LocationModel>[].obs;
  var areas = <LocationModel>[].obs;

  var userList = <User>[].obs;
  var adminList = <User>[].obs;
  var subAdminList = <User>[].obs;

  final dogTypeList = <DogTypeModel>[].obs;

  var selectedStates = <LocationModel>[].obs;
  var selectedCities = <LocationModel>[].obs;
  var selectedZones = <LocationModel>[].obs;
  var selectedWards = <LocationModel>[].obs;
  var selectedAreas = <LocationModel>[].obs;

  var selectedAdmins = <User>[].obs;
  var selectedSubadmins = <User>[].obs;
  var selectedSurveyors = <User>[].obs;

  var selectedDogTypes = <DogTypeModel>[].obs;

  var selectedStartDate = Rxn<DateTime>();
  var selectedEndDate = Rxn<DateTime>();

  var selectedCategoryData = <DogCatchDataModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadStates();

    if (shouldShowAdminDropdown) {
      loadAdminList();
    } else if (shouldShowSubAdminDropdown) {
      loadSubAdminList(currentUserId);
    }else if (shouldShowSurveyorDropdown) {
      loadSurveyorList(currentUserId);
    }
    ever(selectedStates, (_) {
      if (selectedStates.isNotEmpty) {
        final stateIds = selectedStates.map((e) => e.locationId).toList();
        loadCitiesByState(stateIds);
      } else {
        cities.clear();
        zones.clear();
        wards.clear();
        selectedCities.clear();
        selectedZones.clear();
        selectedWards.clear();
      }
      selectedAreas.clear();
    });

    ever(selectedCities, (_) {
      if (selectedCities.isNotEmpty) {
        final cityIds = selectedCities.map((e) => e.locationId).toList();
        loadZonesByCity(cityIds);
      } else {
        zones.clear();
        wards.clear();
        selectedZones.clear();
        selectedWards.clear();
      }
      selectedAreas.clear();
    });

    ever(selectedZones, (_) {
      if (selectedZones.isNotEmpty) {
        final zoneIds = selectedZones.map((e) => e.locationId).toList();
        loadWardsByZone(zoneIds);
      } else {
        wards.clear();
        selectedWards.clear();
      }
      selectedAreas.clear();
    });

    ever(selectedWards, (_) {
      if (selectedWards.isNotEmpty) {
        final wardIds = selectedWards.map((e) => e.locationId).toList();
        loadAreasByWards(wardIds);
      } else {
        selectedAreas.clear();
      }
    });

    ever(selectedAdmins, (_) {
      if (selectedAdmins.isNotEmpty) {
        loadSubAdminList(selectedAdmins.map((e) => e.userId.toString()).join(','));
      } else {
        subAdminList.clear();
        userList.clear();
        selectedSubadmins.clear();
        selectedSurveyors.clear();
      }
    });

    ever(selectedSubadmins, (_) {
      if (selectedSubadmins.isNotEmpty) {
        loadSurveyorList(selectedSubadmins.map((e) => e.userId.toString()).join(','));
      } else {
        userList.clear();
        selectedSurveyors.clear();
      }
    });

    loadDogTypes();
  }

  Future<void> loadStates() async {
    states.value = await _dbHelper.getStatesList();
  }

  Future<void> loadCitiesByState(List<int> statesIds) async {
    cities.value = await _dbHelper.getCitiesByStates(statesIds);
    zones.clear();
    wards.clear();
    selectedCities.clear();
    selectedZones.clear();
    selectedWards.clear();
    selectedAreas.clear();
  }

  Future<void> loadZonesByCity(List<int> cityIds) async {
    zones.value = await _dbHelper.getZonesByCities(cityIds);
    wards.clear();
    selectedZones.clear();
    selectedWards.clear();
    selectedAreas.clear();
  }

  Future<void> loadWardsByZone(List<int> zoneIds) async {
    wards.value = await _dbHelper.getWardsByZones(zoneIds);
    selectedWards.clear();
    selectedAreas.clear();
  }

  Future<void> loadAreasByWards(List<int> wardIds) async {
    areas.value = await _dbHelper.getAreasByWards(wardIds);
  }

  Future<void> loadAdminList() async {
    final adminId = CommonUtils.getUserId().toString();
    final url = '${UrlConstants.getUsersList}/${UrlConstants.ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);
    adminList.clear();
    if (response != null && response.status == 1 && response.userList != null) {
      adminList.assignAll(response.userList!);
    }
  }

  Future<void> loadSubAdminList(String adminIds) async {

    final response = await CommonUtils.callApi(
      url: UrlConstants.getAssignUsersList,
      body: {'user_ids': adminIds},
    );
    isLoading(false);
    subAdminList.clear();
    if (response != null && response.status == 1 && response.userList != null) {
      subAdminList.assignAll(response.userList!);
    }
  }

  Future<void> loadSurveyorList(String subAdminIds) async {

    final response = await CommonUtils.callApi(
      url: UrlConstants.getAssignUsersList,
      body: {'user_ids': subAdminIds},
    );
    isLoading(false);
    userList.clear();
    if (response != null && response.status == 1 && response.userList != null) {
      userList.assignAll(response.userList!);
    }
  }

  Future<void> loadDogTypes() async {
    dogTypeList.clear();
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", AppColors.red, 2);
      return;
    }

    if (response.status == 1) {
      dogTypeList.addAll(response.dogTypeList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }
  var downloadProgress = 0.0.obs;

  Future<void> fetchReport(BuildContext context) async {
    try {
      isLoading(true);
      downloadProgress.value = 0.0;

      Map<String, dynamic> body = {
        'state_id': selectedStates.map((e) => e.locationId).join(','),
        'city_id': selectedCities.map((e) => e.locationId).join(','),
        'zone_id': selectedZones.map((e) => e.locationId).join(','),
        'ward_id': selectedWards.map((e) => e.locationId).join(','),
        'area_id': selectedAreas.map((e) => e.locationId).join(','),
        'admin_id': selectedAdmins.map((e) => e.userId).join(','),
        'sub_admin_id': selectedSubadmins.map((e) => e.userId).join(','),
        'surveyor_id': selectedSurveyors.map((e) => e.userId).join(','),
        'dog_type_id': selectedDogTypes.map((f) => f.id).join(','),
        'start_date': selectedStartDate.value?.toIso8601String().split('T').first ?? '',
        'end_date': selectedEndDate.value?.toIso8601String().split('T').first ?? '',
      };

      final response = await CommonUtils.callApi(
        url: '${UrlConstants.baseUrl}export-pdf',
        method: 'POST',
        body: body,
      );

      if (response != null && response.status == 1 && response.pdfurl != null) {
        final fileName = "PawCount_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
        final downloads = Directory('/storage/emulated/0/Download/PawCount');

        if (!(await downloads.exists())) {
          await downloads.create(recursive: true);
        }

        final savePath = "${downloads.path}/$fileName";

        final dio = Dio();

        // Show progress dialog
        Get.dialog(
          Obx(() => AlertDialog(
            title: const Text("Downloading..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: downloadProgress.value,
                ),
                const SizedBox(height: 10),
                Text("${(downloadProgress.value * 100).toStringAsFixed(0)}%"),
              ],
            ),
          )),
          barrierDismissible: false,
        );

        // Start file download with progress
        final res = await dio.download(
          response.pdfurl!,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              downloadProgress.value = received / total;
            }
          },
        );

        if (Get.isDialogOpen!) Get.back();

        if (res.statusCode == 200) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Download Complete'),
              content: Text('Saved to:\n$savePath'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    OpenFilex.open(savePath);
                  },
                  child: const Text('Open'),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar("Download Failed", "Could not download the PDF.");
        }
      } else {
        Get.snackbar("Failed", response?.message ?? 'Something went wrong');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }



}
