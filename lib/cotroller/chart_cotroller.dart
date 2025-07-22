import 'dart:convert';

import 'package:get/get.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/model/report_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class ChartController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  var states = <LocationModel>[].obs;
  var cities = <LocationModel>[].obs;
  var zones = <LocationModel>[].obs;
  var wards = <LocationModel>[].obs;
  var areas = <LocationModel>[].obs;

  var selectedState = Rxn<LocationModel>();
  var selectedCity = Rxn<LocationModel>();
  var selectedZone = Rxn<LocationModel>();
  var selectedWard = Rxn<LocationModel>();
  var selectedArea = Rxn<LocationModel>();

  var selectedCategoryData = <DogCatchDataModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadStates();
  }

  Future<void> loadStates() async {
    states.value = await _dbHelper.getStates();

    if (states.isNotEmpty) {
      selectedState.value = states.first;

      cities.value = await _dbHelper.getCitiesByState(selectedState.value?.locationId ?? 0);
      zones.clear();
      areas.clear();
      wards.clear();
      await fetchReport();
    }
  }

  Future<void> updateState(LocationModel state) async {
    selectedState.value = state;
    selectedCity.value = null;
    selectedZone.value = null;
    selectedArea.value = null;
    selectedWard.value = null;
    cities.value = await _dbHelper.getCitiesByState(state.locationId ?? 0);
    zones.clear();
    areas.clear();
    wards.clear();
    await fetchReport();
  }

  Future<void> updateCity(LocationModel city) async {
    selectedCity.value = city;
    selectedZone.value = null;
    selectedArea.value = null;
    selectedWard.value = null;
    zones.value = await _dbHelper.getZonesByCity(city.locationId ?? 0);
    areas.clear();
    wards.clear();
    await fetchReport();
  }

  Future<void> updateZone(LocationModel zone) async {
    selectedZone.value = zone;
    selectedArea.value = null;
    selectedWard.value = null;
    wards.value = await _dbHelper.getWardsByZone(zone.locationId ?? 0);
    areas.clear();
    await fetchReport();
  }

  Future<void> updateWard(LocationModel ward) async {
    selectedWard.value = ward;
    selectedArea.value = null;
    areas.value = await _dbHelper.getAreaByWards(ward.locationId ?? 0);
    await fetchReport();
  }

  Future<void> updateArea(LocationModel area) async {
    selectedArea.value = area;
    await fetchReport();
  }

  Future<void> fetchReport() async {
    isLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.viewReport,
      body: {
        'state_id': selectedState.value?.locationId,
        'city_id': selectedCity.value?.locationId,
        'zone_id': selectedZone.value?.locationId,
        'ward_id': selectedWard.value?.locationId,
        'area_id': selectedArea.value?.locationId,
      },
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      isLoading(false);
      return;
    }

    if (response.status == 1 && response.dogCatchList != null) {
      selectedCategoryData.value = response.dogCatchList ?? [];
    } else {
      selectedCategoryData.clear();
      errorMessage(response.message ?? 'No data found.');
    }

    isLoading(false);
  }
}
