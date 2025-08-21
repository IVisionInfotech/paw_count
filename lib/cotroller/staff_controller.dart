import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/staff_dog_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:survey_dogapp/utils/ImagePickerUtil.dart';

class StaffManagementController extends GetxController
    with GetTickerProviderStateMixin {
  late TabController tabController;
  var tabIndex = 0.obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var dogTypeList = <DogTypeModel>[].obs;
  var staffDogList = <StaffDogModel>[].obs;
  var showImageError = false.obs;


  var filteredStaffDogList = <StaffDogModel>[].obs;

  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var selectedDogTypeId = "".obs;

  void pickImageDialog() {
    ImagePickerUtil().pickImageDialog(
      onImageSelected: (file) {
        pickedImage.value = file;
        showImageError.value = false;
      },
      onError: (message) {
        CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
      },
    );
  }

  var pickedImage = Rx<File?>(null);
  var remark = "".obs;

  var userName = (CommonUtils.getUserName() ?? "User Name").obs;
  var userRole = (CommonUtils.getUserRole() ?? "User Role").obs;
  var userProfile = (CommonUtils.getUserProfile() ?? "").obs;
  var lat = 0.0.obs;
  var lng = 0.0.obs;

  String get displayRole {
    if (userRole.value == 'ADMIN') {
      return 'STATE ADMIN';
    } else if (userRole.value == 'SUB ADMIN') {
      return 'CITY ADMIN';
    } else {
      return userRole.value;
    }
  }

  void logout(BuildContext context) {
    CommonUtils.showLogoutDialog(context);
  }

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      tabIndex.value = tabController.index;
      if (tabIndex.value == 1) {
        staffDogFetch();
      }
    });
  }

  Future<void> dogTypeFetch() async {
    isLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      dogTypeList.assignAll(response.dogTypeList ?? []);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
    }
  }

  Future<void> staffDogFetch() async {
    isLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: "${UrlConstants.staff}?user_id=${CommonUtils.getUserId()}",
      body: {'action': "list"},
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      staffDogList.assignAll(response.staffDoglist ?? []);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
    }
  }

  Future<bool> _getCurrentLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return false;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return false;
      }

      LocationData locationData = await location.getLocation();

      lat.value = locationData.latitude ?? 0.0;
      lng.value = locationData.longitude ?? 0.0;

      print("Lat: ${lat.value}, Lng: ${lng.value}");
      return true;
    } catch (e) {
      print("Error getting location: $e");
      return false;
    }
  }


  void resetDialog() {
    pickedImage.value = null;
    remark.value = "";
  }

  Future<void> saveDogCatch({required DogTypeModel dogModel}) async {

    isLoading(true);
    errorMessage("");
    bool gotLocation = await _getCurrentLocation();
    if (!gotLocation) {
      isLoading(false);
      CommonUtils.buildSnackBar(
        "Unable to fetch location",
        "Error",
        AppColors.red,
        2,
      );
      return;
    }

    String catchDatetime = DateTime.now().toString();
    String base64Image = "";
    if (pickedImage.value != null) {
      final bytes = await pickedImage.value!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
    }

    final Map<String, dynamic> body = {
      "action": "insert",
      "dog_type_id": dogModel.id?.toString(),
      "lat": lat.toString(),
      "lng": lng.toString(),
      "surveyor_id": CommonUtils.getUserId(),
      "catch_datetime": catchDatetime,
      "remark": remark.value,
      "img": base64Image,
    };

    final response = await CommonUtils.callApi(
      url: UrlConstants.staff,
      body: body,
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar(
        "Connection failed.",
        "Error",
        AppColors.red,
        2,
      );
      return;
    }

    if (response.status == 1) {
      CommonUtils.buildSnackBar(
        "saved successfully!",
        "Success",
        AppColors.green,
        2,
      );

      pickedImage.value = null;
      remark.value = "";
    } else {
      errorMessage(response.message ?? 'Operation failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
