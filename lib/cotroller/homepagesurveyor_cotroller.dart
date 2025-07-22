import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class HomepagesurveyorCotroller extends GetxController {
  var allRoutes = <RouteDataModel>[].obs;

  int get currentUserId => CommonUtils.getUserId()!;

  RxList<RouteDataModel> pendingRoutes = <RouteDataModel>[].obs;
  RxList<RouteDataModel> inProgressRoutes = <RouteDataModel>[].obs;
  RxList<RouteDataModel> completedRoutes = <RouteDataModel>[].obs;
  RxList<RouteDataModel> unCompletedRoutes = <RouteDataModel>[].obs;
  var errorMessage = "".obs;
  RxBool isLoading = true.obs;

  DatabaseHelper databaseHelper = DatabaseHelper();
  var isAccept = false.obs;
  LocationData? currentLocation;

  var userList = <User>[].obs;
  final selectedAdminId = RxnInt();
  final selectedSubAdminId = RxnInt();
  final selectedSurveyorId = RxnInt();

  RxList<User> adminList = <User>[].obs;
  RxList<User> subAdminList = <User>[].obs;
  RxList<User> surveyorList = <User>[].obs;


  @override
  void onInit() {
    super.onInit();
    if(CommonUtils.getUserRole() != UrlConstants.SURVEYOR) {
      if (CommonUtils.getUserRole() == UrlConstants.SUPER_ADMIN) {
        fetchUsersByRole(UrlConstants.ADMIN);
      } else if (CommonUtils.getUserRole() == UrlConstants.ADMIN) {
        fetchUsersByRole(UrlConstants.SUB_ADMIN);
      } else {
        fetchUsersByRole(UrlConstants.SURVEYOR);
      }
    }
    loadRouteData(0, 0, currentUserId, 0);
  }

  Map<String, dynamic> isNearDestination({
    required double currentLat,
    required double currentLng,
    required double destLat,
    required double destLng,
    double thresholdInMeters = 100,
  }) {
    const earthRadius = 6371000;

    final dLat = _degreesToRadians(destLat - currentLat);
    final dLng = _degreesToRadians(destLng - currentLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(currentLat)) *
            cos(_degreesToRadians(destLat)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;

    return {
      'isNear': distance <= thresholdInMeters,
      'distance': distance,
    };
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location service is not enabled');
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('Location permission not granted');
        return;
      }
    }

    // Get the current location
    try {
      currentLocation = await location.getLocation();
      print('Current location: Lat: ${currentLocation!.latitude}, Lng: ${currentLocation!.longitude}');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> acceptBtnCall(int routeId) async {
    isLoading.value = true;
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.routeMapAccept,
      body: {"user_id": CommonUtils.getUserId(), "route_id": routeId},
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
      isLoading.value = false;
      return;
    }
    if (response.status == 1) {
      errorMessage(response.message ?? 'Route Accept successfully!');
      CommonUtils.buildSnackBar(
        errorMessage.value,
        "Success",
        AppColors.green,
        2,
      );
    } else {
      errorMessage(response.message ?? 'Failed to fetch route data.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }

    isLoading.value = false;
  }
  Future<void> fetchUsersByRole(String role, {int? selectedUserId}) async {
    final adminId = CommonUtils.getUserId().toString();
    var url = '${UrlConstants.getUsersList}/$role/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');

    if (response == null) {
      errorMessage('Failed to fetch users. Please check your connection.');
      return;
    }

    if (response.status == 1 && response.userList != null) {
      // Clear and populate the relevant user list based on the role
      if (role == UrlConstants.ADMIN) {
        adminList.clear();
        adminList.addAll(response.userList!);
      } else if (role == UrlConstants.SUB_ADMIN) {
        subAdminList.clear();
        subAdminList.addAll(response.userList!);
      } else if (role == UrlConstants.SURVEYOR) {
        surveyorList.clear();
        surveyorList.addAll(response.userList!);
      }
    } else {
      errorMessage(response.message ?? "No users found.");
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }
  }
  Future<void> loadSubAdminList(String adminId) async {
    final url =
        '${UrlConstants.getUsersList}/${UrlConstants.SUB_ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);

    if (response != null && response.status == 1 && response.userList != null) {
      subAdminList.clear();
      subAdminList.assignAll(response.userList!);
    } else {
      subAdminList.clear();
    }
  }
  Future<void> loadSurveyorList(String adminId) async {
    final url =
        '${UrlConstants.getUsersList}/${UrlConstants.SURVEYOR}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);

    if (response != null && response.status == 1 && response.userList != null) {
      surveyorList.clear();
      surveyorList.addAll(response.userList!);
    } else {
      surveyorList.clear();
    }
  }

  Future<void> loadRouteData(
      int? surveyorId,
      int? subAdminId,
      int? userId,
      int? adminId,
      ) async {
    isLoading.value = true;
    errorMessage("");
    pendingRoutes.value.clear();
    inProgressRoutes.value.clear();
    completedRoutes.value.clear();
    unCompletedRoutes.value.clear();
    final response = await CommonUtils.callApi(
      url: UrlConstants.routeMapFetchAll,
      body: {
        "user_id": userId,
        "sub_admin_id": subAdminId,
        "surveyor_id": surveyorId,
        "admin_id": adminId,
      },
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
      isLoading.value = false;
      return;
    }

    if (response.status == 1) {
      pendingRoutes.value = response.routePendingList ?? [];
      inProgressRoutes.value = response.routeProcessingList ?? [];
      completedRoutes.value = response.routeCompleteList ?? [];
      unCompletedRoutes.value = response.routeUncompleteList ?? [];

      Future<void> fillLocationData(List<RouteDataModel> routes) async {
        for (var route in routes) {
          route.zoneName = await databaseHelper.getLocationNameById(
            route.zoneId,
          );
          route.wardName = await databaseHelper.getLocationNameById(
            route.wardId,
          );
          route.cityName = await databaseHelper.getLocationNameById(
            route.cityId,
          );
          route.areaName = await databaseHelper.getLocationNameById(
            route.areaId,
          );
        }
      }

      await fillLocationData(pendingRoutes.value);
      await fillLocationData(inProgressRoutes.value);
      await fillLocationData(completedRoutes.value);
      await fillLocationData(unCompletedRoutes.value);

      if (pendingRoutes.isEmpty &&
          inProgressRoutes.isEmpty &&
          completedRoutes.isEmpty &&
          unCompletedRoutes.isEmpty) {
        errorMessage("No route data available.");
      }
    } else {
      errorMessage(response.message ?? 'Failed to fetch route data.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }

    isLoading.value = false;
  }
}
