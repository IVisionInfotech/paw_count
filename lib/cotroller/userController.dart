import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/MapsScreen/models/CityBorderModel.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/ApiResponse.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/staff_dog_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:survey_dogapp/utils/ImagePickerUtil.dart';

class UserController extends GetxController {
  final dbHelper = DatabaseHelper();
  var isLoading = false.obs;
  var isShimmerLoading = false.obs;
  var errorMessage = "".obs;

  bool get shouldShowAdminDropdown {
    return roleType == UrlConstants.SUPER_ADMIN &&
        (selectedRole.value == UrlConstants.CITY_ADMIN ||
            selectedRole.value == UrlConstants.SURVEYOR || selectedRole.value == UrlConstants.STAFF);
  }

  bool get shouldShowSubAdminDropdown {
    return (selectedRole.value == UrlConstants.SURVEYOR || selectedRole.value == UrlConstants.STAFF) &&
        roleType != UrlConstants.SUB_ADMIN;
  }

  bool get shouldShowSubAdmin {
    return selectedRole.value == UrlConstants.CITY_ADMIN;
  }

  final userImageUpdate = 0.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  var userList = <User>[].obs;
  var adminList = <User>[].obs;
  var subAdminList = <User>[].obs;

  var selectedRole = ''.obs;
  var ownership = 0.obs;
  var selectedState = 0.obs;
  var selectedCity = 0.obs;
  var selectedAdmin = 0.obs;
  var selectedSubAdmin = 0.obs;
  var canChangeBorder = 0.obs;
  var profileLogo = Rxn<File>();
  var profileLogoUri = ''.obs;
  var stateList = <LocationModel>[].obs;
  var cityList = <LocationModel>[].obs;
  RxList<CityBorderModel> cityBorderList = <CityBorderModel>[].obs;

  Future<void> fetchStates() async {
    try {
      final data = await dbHelper.getStates();
      stateList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCities(int stateId) async {
    try {
      final data = await dbHelper.getCitiesByState(stateId);
      cityList.assignAll(data);
    } finally {
      isLoading(false);
    }
  }

  final roleType = CommonUtils.getUserRole();
  var filteredRoles = <String>[].obs;

  void filterRoles() {
    if (roleType == UrlConstants.SUPER_ADMIN) {
      filteredRoles.assignAll(UrlConstants.superAdminRoles);
    } else if (roleType == UrlConstants.ADMIN) {
      selectedAdmin.value = CommonUtils.getUserId()!;
      filteredRoles.assignAll(UrlConstants.adminRoles);
    } else if (roleType == UrlConstants.SUB_ADMIN) {
      selectedSubAdmin.value = CommonUtils.getUserId()!;
      filteredRoles.assignAll(UrlConstants.subAdminRoles);
    }
  }

  void pickImageDialog() {
    ImagePickerUtil().pickImageDialog(
      onImageSelected: (file) {
        userImageUpdate.value = 1;
        profileLogo.value = file;
      },
      onError: (message) {
        CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
      },
    );
  }

  Future<void> deleteUser(int userId) async {
    errorMessage("");
    final response = await CommonUtils.callApi(
      url: "${UrlConstants.deleteUsers}/$userId",
      method: "GET",
    );

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
        response.message ?? 'User deleted Successfully',
        "Deleted",
        AppColors.red,
        2,
      );
      userList.removeWhere((user) => user.userId == userId);
      userList.refresh();
    } else {
      errorMessage(response.message ?? 'Deletion failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }
  }

  List<User> get getUsers => userList;

  void fillUserDetails(User user) {
    if (user.role == UrlConstants.ADMIN) {
      selectedRole.value = UrlConstants.STATE_ADMIN;
    } else if (user.role == UrlConstants.SUB_ADMIN) {
      selectedRole.value = UrlConstants.CITY_ADMIN;
    } else if (user.role == UrlConstants.SURVEYOR) {
      selectedRole.value = UrlConstants.SURVEYOR;
    } else {
      selectedRole.value = UrlConstants.STAFF;
    }

    nameController.text = user.name ?? '';
    emailController.text = user.email ?? '';
    passwordController.text = user.originalPassword ?? '';
    contactController.text = user.contact ?? '';
    addressController.text = user.address ?? '';
    selectedState.value = user.stateId ?? 0;
    selectedCity.value = user.assignCityId ?? 0;
    ownership.value = user.ownership ?? 0;
    canChangeBorder.value = user.changeBorder ?? 0;
    profileLogoUri.value = user.profileLogo ?? '';
    selectedAdmin.value = user.adminId ?? 0;
    selectedSubAdmin.value = user.subAdminId ?? 0;
    adminList.clear();
    subAdminList.clear();
    stateList.clear();
    cityList.clear();
    fetchStates();
    if (selectedState.value != 0) {
      fetchCities(selectedState.value);
    }
    loadAdminList(user);
    loadSubAdminList(user.subAdminId.toString(), user);
  }

  void clearInputs() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    contactController.clear();
    addressController.clear();
    adminList.clear();
    subAdminList.clear();
    selectedAdmin.value = 0;
    selectedSubAdmin.value = 0;
    selectedRole.value = '';
    ownership.value = 0;
    selectedState.value = 0;
    selectedCity.value = 0;
    canChangeBorder.value = 0;
    profileLogo.value = null;
    profileLogoUri.value = "";
  }

  bool _validateFields() {
    if (selectedRole.value.isEmpty) {
      CommonUtils.buildSnackBar(
        "Please select a role",
        "Error",
        AppColors.red,
        2,
      );
      return false;
    }

    switch (selectedRole.value) {
      case 'Admin':
        if (selectedState.value == 0) {
          CommonUtils.buildSnackBar(
            "Please select a state for Admin",
            "Error",
            AppColors.red,
            2,
          );
          return false;
        }
        break;

      case 'Sub Admin':
        if (selectedCity.value == 0) {
          CommonUtils.buildSnackBar(
            "Please select a city for Sub Admin",
            "Error",
            AppColors.red,
            2,
          );
          return false;
        }

        if (!(canChangeBorder.value == 0 || canChangeBorder.value == 1)) {
          CommonUtils.buildSnackBar(
            "Please select border change permission",
            "Error",
            AppColors.red,
            2,
          );
          return false;
        }

        if (!(ownership.value == 0 || ownership.value == 2)) {
          CommonUtils.buildSnackBar(
            "Please select ownership",
            "Error",
            AppColors.red,
            2,
          );
          return false;
        }
        break;

      case 'Surveyor':
      case 'Staff':
        if (selectedSubAdmin.value == 0) {
          CommonUtils.buildSnackBar(
            "Please select a Sub Admin for Surveyor",
            "Error",
            AppColors.red,
            2,
          );
          return false;
        }
        break;
    }

    return true;
  }

  Map<String, dynamic> _buildRequestBody(
    int userId,
    String base64image,
    int updateImageFlag,
  ) {
    String formattedRole = '';
    if (selectedRole.value == UrlConstants.STATE_ADMIN) {
      formattedRole = UrlConstants.ADMIN;
    } else if (selectedRole.value == UrlConstants.CITY_ADMIN) {
      formattedRole = UrlConstants.SUB_ADMIN;
    } else if (selectedRole.value == UrlConstants.SURVEYOR) {
      formattedRole = UrlConstants.SURVEYOR;
    }  else if (selectedRole.value == 'ASSOCIATES') {
      formattedRole = UrlConstants.STAFF;
    }

    final base = {
      "user_id": userId,
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "role": formattedRole,
      "contact": contactController.text.trim(),
      "address": addressController.text.trim(),
      "profile_logo": base64image,
      "update_image": updateImageFlag,
    };

    switch (formattedRole) {
      case UrlConstants.ADMIN:
        base["state_id"] = selectedState.value;
        break;
      case UrlConstants.SUB_ADMIN:
        base.addAll({
          "admin_id": selectedAdmin.value,
          "assign_city_id": selectedCity.value,
          "ownership": ownership.value,
          "change_border": canChangeBorder.value,
        });
        break;
      case UrlConstants.SURVEYOR:
      case UrlConstants.STAFF:
        base["admin_id"] = selectedAdmin.value;
        base["sub_admin_id"] = selectedSubAdmin.value;
        break;
    }
    print('+++++++++++++++++++  $base');
    return base;
  }

  Future<void> addUpdateUser(int userId) async {
    if (!_validateFields()) return;

    String base64Image = "";
    int updateImageFlag = 0;

    if (userImageUpdate.value == 1 && profileLogo.value != null) {
      final bytes = await profileLogo.value!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
      updateImageFlag = 1;
    }

    isLoading(true);
    final ApiResponse? response;
    if (userId != 0) {
      response = await CommonUtils.callApi(
        url: UrlConstants.editUsers,
        body: _buildRequestBody(userId, base64Image, updateImageFlag),
      );
    } else {
      response = await CommonUtils.callApi(
        url: UrlConstants.createUsers,
        body: _buildRequestBody(userId, base64Image, updateImageFlag),
      );
    }

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    final message = response.message ?? "User update processed";

    if (response.status == 1 && response.user != null) {
      int index = userList.indexWhere(
        (user) => user.userId == response!.user!.userId,
      );

      if (index != -1) {
        userList[index] = response.user!;
      } else {
        userList.insert(0, response.user!);
      }
      userList.refresh();
      Get.back();
      CommonUtils.buildSnackBar(message, "Success", AppColors.green, 2);
    } else {
      CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
    }
  }

  Future<void> fetchUsersByRole(String role) async {
    isShimmerLoading(true);
    final adminId = CommonUtils.getUserId().toString();
    final url = '${UrlConstants.getUsersList}/$role/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');

    isShimmerLoading(false);

    if (response == null) {
      errorMessage('Failed to fetch users. Please check your connection.');
      return;
    }

    if (response.status == 1 && response.userList != null) {
      userList.clear();
      userList.addAll(response.userList!);
    } else {
      CommonUtils.buildSnackBar(
        response.message ?? "No users found.",
        "Error",
        AppColors.red,
        2,
      );
    }
  }

  Future<void> loadAdminList(User? user) async {
    final adminId = CommonUtils.getUserId().toString();
    final url = '${UrlConstants.getUsersList}/${UrlConstants.ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);
    adminList.clear();
    if (response != null && response.status == 1 && response.userList != null) {
      if (user == null) {
        adminList.assignAll(response.userList!);
      } else {
        final filteredList =
            response.userList!.where((u) => u.userId != user.userId).toList();
        adminList.assignAll(filteredList);
      }
    }
  }

  Future<void> loadSubAdminList(String adminId, User? user) async {
    final url =
        '${UrlConstants.getUsersList}/${UrlConstants.SUB_ADMIN}/$adminId';

    final response = await CommonUtils.callApi(url: url, method: 'GET');
    isLoading(false);
    subAdminList.clear();
    if (response != null && response.status == 1 && response.userList != null) {
      if (user == null) {
        subAdminList.assignAll(response.userList!);
      } else {
        final filteredList =
            response.userList!.where((u) => u.userId != user.userId).toList();
        subAdminList.assignAll(filteredList);
      }
    }
  }

  Future<bool> fetchCityBOrder(int cityId) async {
    errorMessage("");
    final response = await CommonUtils.callApi(
      url: "${UrlConstants.cityBorderEdit}/$cityId",
      method: "GET",
    );
    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
      return false;
    }
    if (response.status == 1) {
      if (response.cityBorders != null && response.cityBorders!.isNotEmpty) {
        cityBorderList.assignAll(response.cityBorders!);
        return true;
      } else {
        cityBorderList.clear();
        return false;
      }
    } else {
      errorMessage(response.message ?? 'Failed to fetch border data.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
      return false;
    }
  }

  Future<bool> unRegisterUser(User user,int isRegister) async {
    try {
      isLoading.value = true;
      errorMessage("");

      final response = await CommonUtils.callApi(
        url: "${UrlConstants.userRegister}/${user.userId}/$isRegister",
        method: "GET",
      );

      if (response == null) {
        errorMessage.value = 'Connection failed. Check your internet.';
        CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
        return false;
      }

      if (response.status == 1) {
        errorMessage.value = response.message ?? 'User unregistered successfully';
        CommonUtils.buildSnackBar(errorMessage.value, "Success", Colors.green, 2);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to unregister user';
        CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
        return false;
      }
    } catch (e) {
      CommonUtils.buildSnackBar("Something went wrong", "Error", Colors.red, 2);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  var staffDogList = <StaffDogModel>[].obs;
  var filteredStaffDogList = <StaffDogModel>[].obs;
  var dogTypeList = <DogTypeModel>[].obs;

  var selectedStartDate = Rxn<DateTime>();
  var selectedEndDate = Rxn<DateTime>();

  var selectedDogTypes = <DogTypeModel>[].obs;
  var selectedAssociateList = <User>[].obs;

  var downloadProgress = 0.0.obs;

  Future<void> dogTypeFetch() async {
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
    );

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
    isShimmerLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.staff,
      body: {'action': "list"},
    );

    isShimmerLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      staffDogList.assignAll(response.staffDoglist ?? []);
      filteredStaffDogList.assignAll(response.staffDoglist ?? []);
    } else {
      errorMessage(response.message ?? 'Failed to fetch staff dogs.');
    }
  }

  void applyFilters() {
    List<StaffDogModel> list = List.from(staffDogList);

    if (selectedStartDate.value != null || selectedEndDate.value != null) {
      list = list.where((dog) {
        if (dog.createdAt == null) return false;

        DateTime dogDate = DateTime.tryParse(dog.createdAt!) ?? DateTime(2000);

        if (selectedStartDate.value != null &&
            dogDate.isBefore(selectedStartDate.value!)) {
          return false;
        }
        if (selectedEndDate.value != null &&
            dogDate.isAfter(selectedEndDate.value!)) {
          return false;
        }
        return true;
      }).toList();
    }

    if (selectedDogTypes.isNotEmpty) {
      final selectedIds = selectedDogTypes.map((e) => e.id).toList();
      list = list.where((dog) => selectedIds.contains(dog.dogTypeId)).toList();
    }

    if (selectedAssociateList.isNotEmpty) {
      final selectedIds = selectedAssociateList.map((e) => e.userId).toList();
      list = list.where((dog) => selectedIds.contains(dog.surveyorId)).toList();
    }

    filteredStaffDogList.assignAll(list);
  }

  Future<String> getAddressFromLatLng(String? lat, String? lng) async {
    try {
      if (lat == null || lng == null) return "Invalid location";

      final double latitude = double.tryParse(lat) ?? 0.0;
      final double longitude = double.tryParse(lng) ?? 0.0;

      if (latitude == 0.0 && longitude == 0.0) return "Invalid coordinates";

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        String address = [
          place.subLocality,
          place.locality,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        return address.isNotEmpty ? address : "Unknown location";
      }
      return "Unknown location";
    } catch (e) {
      return "Unable to fetch address";
    }
  }

  Future<void> fetchReport(BuildContext context) async {
    try {
      isLoading(true);
      downloadProgress.value = 0.0;

      Map<String, dynamic> body = {};

      if (selectedAssociateList.isNotEmpty) {
        body['user_id'] = selectedAssociateList.map((f) => f.userId).join(',');
      }

      if (selectedDogTypes.isNotEmpty) {
        body['dog_type_id'] = selectedDogTypes.map((f) => f.id).join(',');
      }

      if (selectedStartDate.value != null) {
        body['start_date'] = selectedStartDate.value!
            .toIso8601String()
            .split('T')
            .first;
      }

      if (selectedEndDate.value != null) {
        body['end_date'] = selectedEndDate.value!
            .toIso8601String()
            .split('T')
            .first;
      }


      final response = await CommonUtils.callApi(
        url: '${UrlConstants.staff}/report',
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
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }


}
