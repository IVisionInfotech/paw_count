import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class LocationController extends GetxController {
  RxString selectedLocationType = ''.obs;
  RxnInt selectedStateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxnInt selectedZoneId = RxnInt();
  RxnInt selectedWardId = RxnInt();
  RxnInt selectedAreaId = RxnInt();
  TextEditingController nameController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool isLoadingChange = false.obs;
  RxBool isLoadingEdit = false.obs;
  RxString errorMessage = ''.obs;

  final dogTypeList = <DogTypeModel>[].obs;
  var canAddPhoto = 0.obs;
  final selectedDogTypeIds = <int>[].obs;

  List<String> locationTypes = ['State', 'City', 'Zone', 'Ward', 'Area'];
  var states = <LocationModel>[].obs;
  var cities = <LocationModel>[].obs;
  var zones = <LocationModel>[].obs;
  var wards = <LocationModel>[].obs;
  var areas = <LocationModel>[].obs;

  final dbHelper = DatabaseHelper();

  Widget getLocationIcon(String locationType) {
    switch (locationType.toLowerCase()) {
      case 'state':
        return const Icon(Icons.map, color: AppColors.primary);
      case 'city':
        return const Icon(Icons.location_city, color: AppColors.primary);
      case 'zone':
        return const Icon(Icons.grid_view, color: AppColors.primary);
      case 'area':
        return const Icon(Icons.area_chart, color: AppColors.primary);
      case 'ward':
        return const Icon(Icons.account_tree, color: AppColors.primary);
      default:
        return const Icon(Icons.location_on, color: AppColors.primary);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadDogTypes();
    fetchAllLocation();
  }

  Future<void> loadDogTypes() async {
    isLoading(true);
    errorMessage("");
    dogTypeList.clear();
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
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
      dogTypeList.addAll(response.dogTypeList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }

  List<int> getDogTypeIdList(String? idsString) {
    if (idsString == null || idsString.isEmpty) return [];
    return idsString
        .split(",")
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id != 0)
        .toList();
  }

  void resetDropdownValues() {
    selectedStateId.value = null;
    selectedCityId.value = null;
    selectedZoneId.value = null;
    selectedAreaId.value = null;
  }

  Future<void> fetchAllLocation() async {
    isLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.allLocation,
      method: "GET",
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      isLoading(false);
      return;
    }

    if (response.status == 1 && response.locationsList != null) {
      await dbHelper.clearAllLocations();
      final List<LocationModel> fetchedLocations = response.locationsList!;

      await dbHelper.insertAll(fetchedLocations);
      states.value = await dbHelper.getStates();
    } else {
      errorMessage(response.message ?? 'No data found.');
    }
    isLoading(false);
  }

  Future<void> deleteLocation({
    required int locationId,
    required String locationType,
    required int parentId,
  }) async {
    isLoading(true);
    errorMessage("");

    try {
      final response = await CommonUtils.callApi(
        url: "${UrlConstants.deleteLocation}/$locationId",
        method: "GET",
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
        isLoading(false);
        return;
      }

      if (response.status == 1) {
        CommonUtils.buildSnackBar(
          "Success",
          response.message ?? 'Location deleted successfully',
          AppColors.green,
          2,
        );
        await dbHelper.deleteLocation(locationId);

        await refreshLocationList(locationType, parentId);
      } else {
        errorMessage(response.message ?? 'Something went wrong.');
        CommonUtils.buildSnackBar("Error", errorMessage.value, Colors.red, 2);
      }
    } catch (e) {
      errorMessage("Exception: $e");
      CommonUtils.buildSnackBar("Exception", errorMessage.value, Colors.red, 2);
    } finally {
      isLoading(false);
    }
  }

  Future<void> createLocationSave({
    required String locationName,
    required String locationType,
    required int parentId,
    String? dogTypeIds,
  }) async {
    isLoadingChange(true);
    errorMessage("");

    final deviceId = await CommonUtils.getDeviceId();

    try {
      final body = {
        'location_name': locationName,
        'location_type': locationType,
        'parent_id': parentId,
        'deviceId': deviceId,
      };

      if (dogTypeIds != null && dogTypeIds.isNotEmpty) {
        body['dogtype_id'] = dogTypeIds;
      }
      final response = await CommonUtils.callApi(
        url: UrlConstants.createLocation,
        body: body,
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
        isLoadingChange(false);
        return;
      }

      if (response.status == 1) {
        CommonUtils.buildSnackBar(
          "Success",
          "$locationType created successfully",
          AppColors.green,
          2,
        );
        clearFields();
        await fetchAllLocation();
      } else {
        errorMessage(response.message ?? 'Failed to create location');
        CommonUtils.buildSnackBar("Error", errorMessage.value, Colors.red, 2);
      }
    } catch (e) {
      errorMessage("Exception: $e");
      CommonUtils.buildSnackBar("Exception", errorMessage.value, Colors.red, 2);
    } finally {
      isLoadingChange(false);
    }
  }

  Future<void> editLocation({
    required int locationId,
    required String locationName,
    required String locationType,
    required int parentId,
    String? dogTypeIds,
  }) async {
    isLoadingEdit(true);
    errorMessage("");
    final deviceId = await CommonUtils.getDeviceId();

    try {
      final body = {
        'location_id': locationId,
        'location_name': locationName,
        'parent_id': parentId,
        'location_type': locationType,
        'deviceId': deviceId,
      };

      if (dogTypeIds != null && dogTypeIds.isNotEmpty) {
        body['dogtype_id'] = dogTypeIds;
      }
      final response = await CommonUtils.callApi(
        url: UrlConstants.editLocation,
        body: body,
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
        isLoadingEdit(false);
        return;
      }

      if (response.status == 1) {
        CommonUtils.buildSnackBar(
          "Success",
          response.message ?? 'Location updated successfully',
          AppColors.green,
          2,
        );
        await dbHelper.updateLocation(locationId, locationName);
        await refreshLocationList(locationType, parentId);
      } else {
        errorMessage(response.message ?? 'Failed to update location');
        CommonUtils.buildSnackBar("Error", errorMessage.value, Colors.red, 2);
      }
    } catch (e) {
      errorMessage("Exception: $e");
      CommonUtils.buildSnackBar("Exception", errorMessage.value, Colors.red, 2);
    } finally {
      isLoadingEdit(false);
    }
  }

  void onLocationTypeChange(String type) async {
    selectedLocationType.value = type;

    if (["City", "Zone", "Ward", "Area"].contains(type)) {
      states.value = await dbHelper.getStates();
    }

    if (["Zone", "Ward", "Area"].contains(type) &&
        selectedStateId.value != null) {
      cities.value = await dbHelper.getCitiesByState(selectedStateId.value!);
    }

    if (["Ward", "Area"].contains(type) && selectedCityId.value != null) {
      zones.value = await dbHelper.getZonesByCity(selectedCityId.value!);
    }

    if (["Area"].contains(type) && selectedZoneId.value != null) {
      wards.value = await dbHelper.getWardsByZone(selectedZoneId.value!);
    }

    if (type == "Area" && selectedWardId.value != null) {
      areas.value = await dbHelper.getAreaByWards(selectedWardId.value!);
    }
  }

  Future<void> onStateChanged(int stateId) async {
    selectedStateId.value = stateId;

    cities.value = await dbHelper.getCitiesByState(stateId);

    selectedCityId.value = null;
    selectedZoneId.value = null;
    selectedWardId.value = null;
    selectedAreaId.value = null;

    zones.clear();
    wards.clear();
    areas.clear();
  }

  Future<void> onCityChanged(int cityId) async {
    selectedCityId.value = cityId;

    zones.value = await dbHelper.getZonesByCity(cityId);

    selectedZoneId.value = null;
    selectedWardId.value = null;
    selectedAreaId.value = null;

    wards.clear();
    areas.clear();
  }

  Future<void> onZoneChanged(int zoneId) async {
    selectedZoneId.value = zoneId;

    wards.value = await dbHelper.getWardsByZone(zoneId);

    selectedWardId.value = null;
    selectedAreaId.value = null;

    areas.clear();
  }

  Future<void> onWardChanged(int wardId) async {
    selectedWardId.value = wardId;

    areas.value = await dbHelper.getAreaByWards(wardId);

    selectedAreaId.value = null;
  }

  void submitLocation() async {
    final type = selectedLocationType.value;
    final name = nameController.text.trim();

    if (type.isEmpty || name.isEmpty) {
      CommonUtils.buildSnackBar(
        "Missing Fields",
        "Please complete all required fields",
        Colors.red,
        2,
      );
      return;
    }

    int? parentId;

    switch (type) {
      case "City":
        parentId = selectedStateId.value;
        break;
      case "Zone":
        parentId = selectedCityId.value;
        break;
      case "Ward":
        parentId = selectedZoneId.value;
        break;
      case "Area":
        parentId = selectedWardId.value;
        break;
      case "State":
        parentId = 0;
        break;
    }

    if (parentId == null && type != "State") {
      CommonUtils.buildSnackBar(
        "Error",
        "Please select parent location for $type",
        Colors.red,
        2,
      );
      return;
    }
    String dogTypeIds = "";
    if (type == "City" && canAddPhoto.value == 1) {
      if (selectedDogTypeIds.isEmpty) {
        CommonUtils.buildSnackBar(
          "Error",
          "Please select at least one dog type",
          Colors.red,
          2,
        );
        return;
      }
      dogTypeIds = selectedDogTypeIds.join(",");
    }

    await createLocationSave(
      locationName: name,
      locationType: type,
      parentId: parentId ?? 0,
      dogTypeIds: dogTypeIds,
    );
  }

  Future<void> refreshLocationList(String locationType, int parentId) async {
    switch (locationType) {
      case 'State':
        states.value = await dbHelper.getStates();
        break;

      case 'City':
        cities.value = await dbHelper.getCitiesByState(parentId);
        break;

      case 'Zone':
        zones.value = await dbHelper.getZonesByCity(parentId);
        break;

      case 'Area':
        areas.value = await dbHelper.getAreaByWards(parentId);
        break;

      case 'Ward':
        wards.value = await dbHelper.getWardsByZone(parentId);
        break;
    }
  }

  void clearFields() {
    selectedLocationType.value = '';
    selectedStateId.value = null;
    selectedCityId.value = null;
    selectedZoneId.value = null;
    selectedWardId.value = null;
    nameController.clear();
  }
}
