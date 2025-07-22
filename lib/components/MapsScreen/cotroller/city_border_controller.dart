import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class CityBorderController extends GetxController {
  final RxInt cityId = 0.obs;
  final RxList<LatLng> borderPoints = <LatLng>[].obs;
  final List<List<LatLng>> _undoStack = [];
  final List<List<LatLng>> _redoStack = [];

  GoogleMapController? mapController;
  Rx<LatLng> cameraTarget = LatLng(0, 0).obs;

  var isLoading = false.obs;
  var errorMessage = "".obs;

  Future<void> setCityCameraPosition(String cityname) async {
    try {
      List<Location> locations = await locationFromAddress(cityname);
      if (locations.isNotEmpty) {
        cameraTarget.value = LatLng(locations[0].latitude, locations[0].longitude);
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(cameraTarget.value, 12),
        );
      } else {
        errorMessage("Location not found for $cityname");
      }
    } catch (e) {
      print("Geocoding error: $e");
      errorMessage("Geocoding failed: $e");
    }
  }

  void addPoint(LatLng point) {
    _undoStack.add(List.from(borderPoints)); // Save current state
    _redoStack.clear(); // Clear redo when new point is added
    borderPoints.add(point);
  }

  void undoLastPoint() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(List.from(borderPoints)); // Save current state to redo
      borderPoints.value = _undoStack.removeLast(); // Revert to previous state
    } else {
      CommonUtils.buildSnackBar("Nothing to undo", "Undo", Colors.orange, 2);
    }
  }

  void redoLastPoint() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List.from(borderPoints)); // Save current state to undo
      borderPoints.value = _redoStack.removeLast(); // Revert to redo state
    } else {
      CommonUtils.buildSnackBar("Nothing to redo", "Redo", Colors.orange, 2);
    }
  }

  void clearPoints(BuildContext context) {
    if (borderPoints.isEmpty) {
      CommonUtils.buildSnackBar(
        "Border is Already Deleted",
        "Warning",
        Colors.red,
        2,
      );
    } else {
      _undoStack.add(List.from(borderPoints)); // Save for undo
      _redoStack.clear();
      borderPoints.clear();
    }
  }

  Set<Polyline> createPolyline() {
    return {
      if (borderPoints.length > 1)
        Polyline(
          polylineId: const PolylineId("drawing_line"),
          points: borderPoints,
          color: Colors.blue,
          width: 3,
        ),
    };
  }

  Set<Polygon> createPolygon(Color strokeColor, Color fillColor,List<LatLng> savedBorder) {
    if (savedBorder.length < 3) return {};
    return {
      Polygon(
        polygonId: const PolygonId("manual_border"),
        points: savedBorder,
        strokeColor: strokeColor,
        strokeWidth: 2,
        fillColor: fillColor,
      ),
    };
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  Future<void> saveBorderPoints(int cityId) async {
    if (borderPoints.isEmpty) {
      CommonUtils.buildSnackBar(
        "Please fill all required fields.",
        "Error",
        Colors.red,
        2,
      );
      return;
    }

    isLoading(true);
    errorMessage("");

    try {
      List<Map<String, String>> locations =
      borderPoints.map((point) {
        return {
          "lat": point.latitude.toStringAsFixed(4),
          "lng": point.longitude.toStringAsFixed(4),
        };
      }).toList();

      final response = await CommonUtils.callApi(
        url: UrlConstants.cityBorderCreate,
        body: {
          "user_id": CommonUtils.getUserId().toString(),
          "city_id": cityId,
          "locations": locations,
        },
      );

      if (response == null) {
        errorMessage("Connection failed. Check your internet.");
        isLoading(false);
        return;
      }

      if (response.status == 1) {
        Get.close(2);
        CommonUtils.buildSnackBar(
          "Border saved successfully",
          "Success",
          Colors.green,
          2,
        );
      } else {
        Get.close(2);
        errorMessage(response.message ?? 'Failed to save border');
        CommonUtils.buildSnackBar(
          response.message ?? 'Failed to save',
          "Error",
          Colors.red,
          2,
        );
      }
    } catch (e) {
      errorMessage("Something went wrong");
      CommonUtils.buildSnackBar("Exception: $e", "Error", Colors.red, 2);
    } finally {
      isLoading(false);
    }
  }
  Future<void> updateBorderPoints(int cityId) async {
    if (borderPoints.isEmpty) {
      CommonUtils.buildSnackBar(
        "Please fill all required fields.",
        "Error",
        Colors.red,
        2,
      );
      return;
    }

    isLoading(true);
    errorMessage("");

    try {
      List<Map<String, String>> locations =
      borderPoints.map((point) {
        return {
          "lat": point.latitude.toStringAsFixed(4),
          "lng": point.longitude.toStringAsFixed(4),
        };
      }).toList();

      final response = await CommonUtils.callApi(
        url: UrlConstants.cityBorderUpdate,
        body: {
          "user_id": CommonUtils.getUserId().toString(),
          "city_id": cityId,
          "locations": locations,
        },
      );

      if (response == null) {
        errorMessage("Connection failed. Check your internet.");
        isLoading(false);
        return;
      }

      if (response.status == 1) {
        Get.close(1);
        CommonUtils.buildSnackBar(
          response.message ?? "Border updated successfully",
          "Success",
          Colors.green,
          2,
        );
      } else {
        Get.close(1);
        errorMessage(response.message ?? 'Failed to Update border');
        CommonUtils.buildSnackBar(
          response.message ?? 'Failed to ted',
          "Error",
          Colors.red,
          2,
        );
      }
    } catch (e) {
      errorMessage("Something went wrong");
      CommonUtils.buildSnackBar("Exception: $e", "Error", Colors.red, 2);
    } finally {
      isLoading(false);
    }
  }
  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}
