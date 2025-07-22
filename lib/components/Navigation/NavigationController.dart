import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class NavigationController extends GetxController {
  final RouteDataModel routeData;
  final String routeType;
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var isCheckingTime = false.obs;
  NavigationController(this.routeData, this.routeType);

  Rx<LatLng?> currentPosition = Rx<LatLng?>(null);
  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxBool isNavigating = false.obs;
  RxBool isCameraFollow = true.obs;
  RxBool trackingStart = false.obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionSubscription;

  RxList<DogTypeModel> dogTypeList = <DogTypeModel>[].obs;
  RxBool isDogTypeLoading = true.obs;
  Map<int, String> capturedImages = {};

  Future<bool?> showImageCapturePopup(int dogTypeId, LatLng? position) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Capture Image"),
        content: const Text("Do you want to capture an image for this marker?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Skip"),
          ),
          TextButton(
            onPressed: () async {
              await captureImage(dogTypeId, position);
              Get.back(result: true);
            },
            child: const Text("Capture"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  List<Map<String, dynamic>> dogDataList = [];

  Future<void> captureImage(int dogTypeId, LatLng? position) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final compressedBytes = await compressImage(File(image.path));

      if (compressedBytes != null && compressedBytes.lengthInBytes <= 1024 * 1024) {
        final base64Image = base64Encode(compressedBytes);

        if (position != null) {
          final datetime = DateTime.now().toString();
          dogDataList.add({
            "dog_type_id": dogTypeId,
            "lat": position.latitude.toString(),
            "lng": position.longitude.toString(),
            "datetime": datetime,
            "image": "data:image/png;base64,$base64Image",
          });
        }
      }
    }
  }

  void updateDogDataList(int dogTypeId, LatLng? position) {
    if (position != null) {
      final datetime = DateTime.now().toString();
      dogDataList.add({
        "dog_type_id": dogTypeId,
        "lat": position.latitude.toString(),
        "lng": position.longitude.toString(),
        "datetime": datetime,
        "image": "",
      });
    }
  }

  Future<Uint8List?> compressImage(File file) async {
    int quality = 90;
    Uint8List? compressed;

    while (quality >= 10) {
      compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed != null && compressed.lengthInBytes <= 512 * 1024) {
        return compressed;
      }
      quality -= 10;
    }

    if (compressed != null && compressed.lengthInBytes <= 1024 * 1024) {
      return compressed;
    }

    return null;
  }



  Future<void> getCurrentLocationAndMoveCamera() async {
    await checkPermissions();
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final current = LatLng(position.latitude, position.longitude);
    currentPosition.value = current;

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(current, 17));
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> startNavigation() async {
    try {
      await checkPermissions();

      isNavigating.value = true;
      trackingStart.value = true;
      markers.clear();
      routePoints.clear();

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        final newPos = LatLng(position.latitude, position.longitude);

        if (routePoints.isNotEmpty) {
          final last = routePoints.last;
          final distance = Geolocator.distanceBetween(
            last.latitude,
            last.longitude,
            newPos.latitude,
            newPos.longitude,
          );
          if (distance < 2) return;
        }

        currentPosition.value = newPos;
        routePoints.add(newPos);

        if (isCameraFollow.isTrue) {
          _moveCamera(newPos);
        }
      });
    } catch (e) {
      isNavigating.value = false;
      trackingStart.value = false;
      CommonUtils.buildSnackBar("Failed to start tracking: $e", "Error", Colors.red, 3);
    }
  }

  List<LatLng> interpolatePoints(List<LatLng> points, int granularity) {
    final List<LatLng> result = [];
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      for (int j = 0; j < granularity; j++) {
        final lat =
            start.latitude +
            (end.latitude - start.latitude) * (j / granularity);
        final lng =
            start.longitude +
            (end.longitude - start.longitude) * (j / granularity);
        result.add(LatLng(lat, lng));
      }
    }
    result.add(points.last);
    return result;
  }

  void stopNavigation() {
    isNavigating.value = false;
    trackingStart.value = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void _moveCamera(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> dogTypeFetch(int cityId) async {
    isDogTypeLoading.value = true;
    try {
      final response = await CommonUtils.callApi(
        url: '${UrlConstants.dogTypeFetchAll}/$cityId',
        method: "GET",
      );
      if (response == null || response.status != 1) {
        dogTypeList.clear();
        return;
      }
      dogTypeList.assignAll(response.dogTypeList!);
    } catch (_) {
      dogTypeList.clear();
    } finally {
      isDogTypeLoading.value = false;
    }
  }

  Future<BitmapDescriptor> loadIconFromUrl(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final imageBytes = await file.readAsBytes();

    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 100);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> checkRouteTime(
      String flag,
      int routeId,
      String apiName, {
        String? startTime,
        String? endTime,
        String? remarkText,
      }) async {
    isCheckingTime(true);
    errorMessage("");
    String url;
    Map<String, dynamic> body;

    if (apiName == UrlConstants.routeProcessing) {
      url = UrlConstants.routeMapProcessing;
      body = {
        "processing_route_start_time": flag == UrlConstants.routeFlagStart ? startTime ?? '' : '',
        "processing_route_end_time": flag == UrlConstants.routeFlagEnd ? endTime ?? '' : '',
        "flag": flag,
        "route_id": routeId,
      };
    } else if (apiName == UrlConstants.routePending) {
      url = UrlConstants.routeMapPending;
      body = {
        "check_route_start_time": flag == UrlConstants.routeFlagStart ? startTime ?? '' : '',
        "check_route_end_time": flag == UrlConstants.routeFlagEnd ? endTime ?? '' : '',
        "flag": flag,
        "route_id": routeId,
        "remark": flag == UrlConstants.routeFlagReject ? remarkText ?? "" : "",
      };
    } else {
      errorMessage("Invalid API name");
      isCheckingTime(false);
      return;
    }

    final response = await CommonUtils.callApi(url: url, body: body);

    if (response == null) {
      isCheckingTime(false);
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
      return;
    }

    if (response.status == 1) {
      if(flag == UrlConstants.routeFlagStart){
        startNavigation();
      }
      errorMessage(response.message ?? 'Route updated successfully.');
      CommonUtils.buildSnackBar(errorMessage.value, 'Success', Colors.green, 2);
    } else {
      errorMessage(response.message ?? 'Route check failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
    isCheckingTime(false);
  }


  bool isNearRouteStart([double thresholdInMeters = 50]) {
    if (currentPosition.value == null || routeData.map.isEmpty) {
      return false;
    }
    final current = currentPosition.value!;
    final startPoint = routeData.map[0];
    final double distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      startPoint.lat,
      startPoint.lng,
    );

    return distance <= thresholdInMeters;
  }
  Future<void> saveFinalCatchRoute(List<LatLng> routePoints) async {
    isLoading(true);
    errorMessage("");

    /*List<Map<String, dynamic>> dogDataList = [];

    for (var marker in markers) {
      LatLng position = marker.position;

      String? dogTypeName = marker.infoWindow.title;
      if (dogTypeName == null) continue;

      int? dogTypeId = dogTypeList
          .firstWhere(
            (dog) => dog.name == dogTypeName,
        orElse: () => DogTypeModel(
          id: -1,
          name: dogTypeName,
          description: '',
          imagePath: '',
        ),
      ).id;

      if (dogTypeId == -1) continue;

      String datetime = DateTime.now().toString();
      String imageBase64 = "data:image/png;base64,${capturedImages[dogTypeId]}" ?? "";


      dogDataList.add({
        "dog_type_id": dogTypeId,
        "lat": position.latitude.toString(),
        "lng": position.longitude.toString(),
        "datetime": datetime,
        "image": imageBase64,
      });
    }*/

    if (dogDataList.isEmpty) {
      errorMessage("No dog data to send.");
      isLoading(false);
      return;
    }

    List<Map<String, String>> mapPoints = routePoints
        .map((e) => {
      "lat": e.latitude.toString(),
      "lng": e.longitude.toString(),
    })
        .toList();

    final body = {
      "route_id": routeData.routeId,
      "surveyor_id": CommonUtils.getUserId(),
      "dog": dogDataList,
      "map": mapPoints,
    };

    final response = await CommonUtils.callApi(
      url: UrlConstants.routeMapCatchDog,
      body: body,
    );

    if (response == null) {
      errorMessage("Connection failed. Check your internet.");
      isLoading(false);
      return;
    }

    if (response.status == 1) {
      Get.close(2);
      CommonUtils.buildSnackBar(
        response.message ?? "",
        "Success",
        Colors.green,
        2,
      );
    } else {
      Get.close(1);
      errorMessage(response.message ?? 'Failed to update.');
      CommonUtils.buildSnackBar(
        response.message ?? 'Failed to update.',
        "Error",
        Colors.red,
        2,
      );
    }

    isLoading(false);
  }


}
