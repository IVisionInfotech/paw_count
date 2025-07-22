import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/models/CityBorderModel.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class RouteTrackingController extends GetxController {
  GoogleMapController? mapController;

  RxString currentLocationText = 'Route Tracker'.obs;
  RxBool isTracking = false.obs;
  RxBool isLoading = true.obs;

  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  List<Map<String, dynamic>> trackedRoute = [];

  StreamSubscription<Position>? positionStream;
  var errorMessage = "".obs;
  RxList<CityBorderModel> cityBorderList = <CityBorderModel>[].obs;

  Future<void> fetchCityBorder(int cityId) async {
    isLoading.value = true;
    errorMessage("");
    final response = await CommonUtils.callApi(
      url: "${UrlConstants.cityBorderEdit}/$cityId",
      method: "GET",
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("${response!.message}", "Error", Colors.red, 2);
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
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }

    isLoading.value = false;
  }

  Set<Polygon> createPolygon() {
    if (cityBorderList.length < 3) return {};

    List<LatLng> polygonPoints = cityBorderList
        .map((e) => LatLng(e.lat!, e.lng!))
        .toList();

    return {
      Polygon(
        polygonId: PolygonId("saved_border"),
        points: polygonPoints,
        strokeColor: Colors.purple,
        strokeWidth: 2,
        fillColor: Colors.purple.withOpacity(0.2),
      ),
    };
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;

    if (cityBorderList.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 300), () async {
        final bounds = getBoundsFromLatLngList(
          cityBorderList.map((e) => LatLng(e.lat!, e.lng!)).toList(),
        );
        await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  LatLngBounds getBoundsFromLatLngList(List<LatLng> points) {
    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();

    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  @override
  void onClose() {
    positionStream?.cancel();
    super.onClose();
  }
}
