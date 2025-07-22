import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/MapsScreen/models/markerData.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geo;

class RouteDetailsController extends GetxController {
  late GoogleMapController mapController;
  late CameraPosition initialCameraPosition;
  RxSet<Polyline> polylines = <Polyline>{}.obs;

  late Set<Marker> markers;
  RxList<LatLng> latLngPoints = <LatLng>[].obs;
  RxSet<Marker> customMarkers = <Marker>{}.obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var dogTypeList = <DogTypeModel>[].obs;

  var trackingStart = false.obs;
  var isCheckingTime = false.obs;

  LocationData? currentLocation;
  List<LatLng> visitedPoints = [];
  PolylineId visitedPolylineId = const PolylineId("visitedPolyline");
  PolylineId remainingPolylineId = const PolylineId("remainingPolyline");

  LatLng? currentPosition;

  var isBottomSheetVisible = false.obs;

  StreamSubscription<geo.Position>? _positionStreamSubscription;

  void startRouteTracking() {
    trackingStart.value = true;
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = geo.Geolocator.getPositionStream(
      locationSettings: geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((position) {
      currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void toggleBottomSheetVisibility() {
    isBottomSheetVisible.value = !isBottomSheetVisible.value;
  }

  var selectedDogTypeId = RxnInt();
  LatLng? tappedPoint;


  Future<void> fetchExit()async {
    isLoading(true);
    errorMessage("");
    final response = await CommonUtils.callApi(
      url: UrlConstants.routeMapCatchAll,
      method: "GET",
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      dogTypeList.addAll(response.dogTypeList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
    }
  }
  void handleMapTap(
    LatLng tappedPoint,
    BuildContext context,
    int routeConfirm, {
    required int dogTypeId,
  }) async {
    if (routeConfirm != 1 || currentLocation == null) return;

    this.tappedPoint = tappedPoint; // ← Store the tapped point here

    LatLng currentLatLng = LatLng(
      currentLocation!.latitude!,
      currentLocation!.longitude!,
    );
    double distance = _calculateDistance(currentLatLng, tappedPoint);

    if (distance <= 20) {
      bool isInsideRoute = _isPointInsideRoute(tappedPoint);
      if (isInsideRoute) {
        // You can now use this.tappedPoint elsewhere
        final selectedDogType = dogTypeList.firstWhere(
          (e) => e.id == dogTypeId,
        );
        final icon = await loadIconFromUrl(selectedDogType.imagePath ?? "");
        markers.add(
          Marker(
            markerId: MarkerId("marker_${markers.length}"),
            position: tappedPoint,
            infoWindow: InfoWindow(title: selectedDogType.name),
            icon: icon,
          ),
        );
      } else {
        CommonUtils.buildSnackBar(
          "Tapped outside the route.",
          "Warning",
          AppColors.orange,
          2,
        );
      }
    } else {
      CommonUtils.buildSnackBar(
        "Please tap near your current location (within 20 meters).",
        "Warning",
        AppColors.orange,
        2,
      );
    }
  }

  bool isLocationNearPolyline([double thresholdInMeters = 50]) {
    final LatLng currentLatLng = LatLng(
      currentLocation!.latitude!,
      currentLocation!.longitude!,
    );
    for (var polyline in polylines) {
      final points = polyline.points;
      for (int i = 0; i < points.length - 1; i++) {
        double distance = _distanceFromSegment(
          currentLatLng,
          points[i],
          points[i + 1],
        );
        if (distance <= thresholdInMeters) {
          return true;
        }
      }
    }
    return false;
  }

  double _distanceFromSegment(LatLng p, LatLng v, LatLng w) {
    const double earthRadius = 6371000; // meters

    double toRadians(double degree) => degree * pi / 180;

    double distance(LatLng a, LatLng b) {
      final lat1 = toRadians(a.latitude);
      final lon1 = toRadians(a.longitude);
      final lat2 = toRadians(b.latitude);
      final lon2 = toRadians(b.longitude);
      final dLat = lat2 - lat1;
      final dLon = lon2 - lon1;
      final aCalc =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
      return 2 * earthRadius * atan2(sqrt(aCalc), sqrt(1 - aCalc));
    }

    double dot =
        ((p.latitude - v.latitude) * (w.latitude - v.latitude) +
            (p.longitude - v.longitude) * (w.longitude - v.longitude));
    double lenSq =
        (pow(w.latitude - v.latitude, 2).toDouble() +
            pow(w.longitude - v.longitude, 2).toDouble());
    double param = lenSq != 0 ? dot / lenSq : -1;

    LatLng nearest;
    if (param < 0) {
      nearest = v;
    } else if (param > 1) {
      nearest = w;
    } else {
      nearest = LatLng(
        v.latitude + param * (w.latitude - v.latitude),
        v.longitude + param * (w.longitude - v.longitude),
      );
    }

    return distance(p, nearest);
  }

  bool _isPointInsideRoute(LatLng tappedPoint) {
    for (var polyline in polylines) {
      for (int i = 0; i < polyline.points.length - 1; i++) {
        LatLng start = polyline.points[i];
        LatLng end = polyline.points[i + 1];

        if (_isPointNearLine(tappedPoint, start, end)) {
          return true;
        }
      }
    }
    return false;
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(b.latitude - a.latitude);
    double dLng = _toRadians(b.longitude - a.longitude);
    double lat1 = _toRadians(a.latitude);
    double lat2 = _toRadians(b.latitude);

    double aVal = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  bool _isPointNearLine(LatLng point, LatLng lineStart, LatLng lineEnd) {
    const double tolerance = 20.0; // Distance tolerance in meters

    double distanceToLineStart = _calculateDistance(point, lineStart);
    double distanceToLineEnd = _calculateDistance(point, lineEnd);
    double lineLength = _calculateDistance(lineStart, lineEnd);

    if (distanceToLineStart + distanceToLineEnd <= lineLength + tolerance) {
      return true;
    }

    return false;
  }

  void initRoute(RouteDataModel routeData) {
    initialCameraPosition = CameraPosition(
      target: LatLng(routeData.map.first.lat, routeData.map.first.lng),
      zoom: 19.0,
    );

    latLngPoints.value = routeData.map.map((e) => LatLng(e.lat, e.lng)).toList();

    Color polylineColor = routeData.routeConfirm == 0 ? Colors.orange : Colors.blue;

    polylines.value = {
      Polyline(
        polylineId: PolylineId('routePolyline'),
        points: latLngPoints,
        color: polylineColor,
        width: 4,
      ),
    };

    markers = {
      Marker(
        markerId: MarkerId('startMarker'),
        position: LatLng(routeData.map.first.lat, routeData.map.first.lng),
        infoWindow: InfoWindow(title: 'Start Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: MarkerId('endMarker'),
        position: LatLng(routeData.map.last.lat, routeData.map.last.lng),
        infoWindow: InfoWindow(title: 'End Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    update();
  }

  Future<BitmapDescriptor> loadIconFromUrl(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final Uint8List imageBytes = await file.readAsBytes();

    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 100);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
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
      dogTypeList.addAll(response.dogTypeList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
    }
  }

  Future<void> saveFinalCatchRoute(int routeId) async {
    isLoading(true);
    errorMessage("");

    List<Map<String, dynamic>> dogDataList = [];

    for (var marker in markers) {
      LatLng position = marker.position;

      String? dogTypeName = marker.infoWindow.title;
      if (dogTypeName == null) continue;

      int? dogTypeId =
          dogTypeList
              .firstWhere(
                (dog) => dog.name == dogTypeName,
                orElse:
                    () => DogTypeModel(
                      id: -1,
                      name: dogTypeName,
                      description: '',
                      imagePath: '',
                    ),
              )
              .id;

      if (dogTypeId == -1) {
        continue;
      }

      String datetime = DateTime.now().toString();
      dogDataList.add({
        "dog_type_id": dogTypeId,
        "lat": position.latitude.toString(),
        "lng": position.longitude.toString(),
        "datetime": datetime,
      });
    }
    if (dogDataList.isEmpty) {
      errorMessage("No dog data to send.");
      isLoading(false);
      return;
    }
    final body = {
      "route_id": routeId,
      "surveyor_id": CommonUtils.getUserId(),
      "dog": dogDataList,
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
      errorMessage(response.message ?? 'Failed to Update border');
      CommonUtils.buildSnackBar(
        response.message ?? 'Failed to Update',
        "Error",
        Colors.red,
        2,
      );
    }

    isLoading(false);
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
        "processing_route_start_time":
            flag == UrlConstants.routeFlagStart ? startTime ?? '' : '',
        "processing_route_end_time":
            flag == UrlConstants.routeFlagEnd ? endTime ?? '' : '',
        "flag": flag,
        "route_id": routeId,
      };
    }
    else if (apiName == UrlConstants.routePending) {
      url = UrlConstants.routeMapPending;
      body = {
        "check_route_start_time":
            flag == UrlConstants.routeFlagStart ? startTime ?? '' : '',
        "check_route_end_time":
            flag == UrlConstants.routeFlagEnd ? endTime ?? '' : '',
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
      isCheckingTime(false);

      if (apiName == UrlConstants.routeFlagConfirm) Get.back();
      trackingStart.value = (flag == UrlConstants.routeFlagStart);
      errorMessage(response.message ?? 'Route updated successfully.');
      CommonUtils.buildSnackBar(errorMessage.value, 'Success', Colors.green, 2);
    } else {
      isCheckingTime(false);
      errorMessage(response.message ?? 'Route check failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
    isCheckingTime(false);
  }
}
