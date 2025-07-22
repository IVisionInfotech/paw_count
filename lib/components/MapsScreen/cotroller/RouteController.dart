import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:survey_dogapp/components/MapsScreen/RoutePreviewScreen.dart';

class RouteController extends GetxController {
  Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);
  RxList<LatLng> points = <LatLng>[].obs;
  RxList<LatLng> undonePoints = <LatLng>[].obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);

  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isTracking = false.obs;
  final RxBool isLoading = true.obs;
  final bool isManually;
  final List<LatLng> cityBorder;

  List<Map<String, dynamic>> trackedRoute = [];
  StreamSubscription<Position>? positionStream;
  final RxList<LatLng> savedBorder = <LatLng>[].obs;

  RouteController(this.isManually, this.cityBorder);

  void setCityBorder(List<LatLng> border) {
    savedBorder.value = border;
  }

  @override
  void onInit() {
    super.onInit();
    loadSavedBorder();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLocation.value = LatLng(position.latitude, position.longitude);
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;

    if (currentLocation.value != null) {
      mapController.value?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation.value!, zoom: 16),
        ),
      );
    }
  }

  bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng vertex1 = polygon[i];
      LatLng vertex2 = polygon[(i + 1) % polygon.length];

      if ((vertex1.longitude > point.longitude) !=
          (vertex2.longitude > point.longitude)) {
        double atLat =
            (vertex2.latitude - vertex1.latitude) *
                (point.longitude - vertex1.longitude) /
                (vertex2.longitude - vertex1.longitude) +
            vertex1.latitude;
        if (point.latitude < atLat) {
          intersections++;
        }
      }
    }

    return (intersections % 2 == 1);
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double px = point.longitude;
    double py = point.latitude;
    double ax = vertA.longitude;
    double ay = vertA.latitude;
    double bx = vertB.longitude;
    double by = vertB.latitude;

    if (ay > by) {
      ax = vertB.longitude;
      ay = vertB.latitude;
      bx = vertA.longitude;
      by = vertA.latitude;
    }

    if (py == ay || py == by) py += 0.00000001;

    if ((py > by || py < ay) || (px > max(ax, bx))) return false;

    if (px < min(ax, bx)) return true;

    double red = (ax != bx) ? ((by - ay) / (bx - ax)) : double.infinity;
    double blue = (ax != px) ? ((py - ay) / (px - ax)) : double.infinity;

    return blue >= red;
  }

  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];

      if ((a.longitude > point.longitude) != (b.longitude > point.longitude)) {
        double slope = (b.latitude - a.latitude) / (b.longitude - a.longitude);
        double possibleLat =
            slope * (point.longitude - a.longitude) + a.latitude;

        if (point.latitude < possibleLat) {
          intersectCount++;
        }
      }
    }
    return (intersectCount % 2 == 1); // odd = inside
  }

  void onTap(LatLng tappedPoint) {
    // Check if tapped point is inside the border polygon
    bool isInside = _isPointInsidePolygon(tappedPoint, savedBorder);
    print("Tapped: $tappedPoint, Inside?: $isInside");

    if (!isInside) {
      Get.snackbar(
        "Out of Border",
        "You can't draw outside the city border",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        animationDuration: Duration(milliseconds: 800),
      );
      return;
    }

    // Optional: Check if the polyline between last and new point stays inside (if needed)
    if (points.isNotEmpty) {
      LatLng lastPoint = points.last;

      // Sample interpolation between lastPoint and tappedPoint
      // If any intermediate point is outside, deny it.
      int steps = 20;
      for (int i = 1; i <= steps; i++) {
        double lat =
            lastPoint.latitude +
            (tappedPoint.latitude - lastPoint.latitude) * (i / steps);
        double lng =
            lastPoint.longitude +
            (tappedPoint.longitude - lastPoint.longitude) * (i / steps);
        LatLng checkPoint = LatLng(lat, lng);
        if (!_isPointInsidePolygon(checkPoint, savedBorder)) {
          Get.snackbar(
            "Route crosses border",
            "This path goes outside city limits. Try a different route.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
          return;
        }
      }
    }

    // Add the point and update the polyline
    points.add(tappedPoint);
    updatePolyline();

    // Clear previous markers and add new ones
    markers
      ..clear()
      ..add(
        Marker(
          markerId: MarkerId('start'),
          position: points.first,
          infoWindow: InfoWindow(title: 'Start'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

    if (points.length > 1) {
      markers.add(
        Marker(
          markerId: MarkerId('end'),
          position: points.last,
          infoWindow: InfoWindow(title: 'End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  void updatePolyline() {
    polylines.clear();

    // Add polyline (blue color)
    polylines.add(
      Polyline(
        polylineId: const PolylineId("drawn_route"),
        points: points.toList(),
        color: Colors.blue,
        width: 5,
      ),
    );

    // Add start and end markers
    if (points.isNotEmpty) {
      markers.removeWhere(
        (marker) =>
            marker.markerId.value == 'start_point' ||
            marker.markerId.value == 'end_point',
      );

      markers.add(
        Marker(
          markerId: const MarkerId('start_point'),
          position: points.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: "Start Point"),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('end_point'),
          position: points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "End Point"),
        ),
      );
    }

    // Trigger the map update (if needed)
    update();
  }

  void updateMarkers() {
    markers.clear();

    if (points.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: points.first,
          infoWindow: const InfoWindow(title: 'Start Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      if (points.length > 1) {
        markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: points.last,
            infoWindow: const InfoWindow(title: 'End Point'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    }
  }

  void undo() {
    if (points.isNotEmpty) {
      undonePoints.add(points.removeLast());
      updatePolyline();
      updateMarkers();
    }
  }

  void redo() {
    if (undonePoints.isNotEmpty) {
      points.add(undonePoints.removeLast());
      updatePolyline();
      updateMarkers();
    }
  }

  void clearRoute() {
    points.clear();
    undonePoints.clear();
    polylines.clear();
    markers.clear();
  }

  void navigateRoutePreview() {
    final List<LatLng> previewPoints = isManually ? points : routePoints;

    if (previewPoints.isEmpty) {
      Get.snackbar("Error", "No points to save");
      return;
    }

    Get.to(
      () => RoutePreviewScreen(
        routePoints: previewPoints.toList(),
        isManually: isManually,
      ),
    );
  }

  Future<void> saveRoute(routePoints) async {
    final List<LatLng> previewPoints = routePoints;

    if (previewPoints.isEmpty) {
      Get.snackbar("Error", "No points to save");
      return;
    }

    Get.back(result: {'points': points, 'reallocation': isManually ? 0 : 1});

    Future.delayed(Duration(milliseconds: 100), () {
      Get.back(result: {'points': points, 'reallocation': isManually ? 0 : 1});
      Get.back(result: {'points': points, 'reallocation': isManually ? 0 : 1});
    });
  }

  void startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permission denied");
        return;
      }
    }

    routePoints.clear();
    markers.clear();
    trackedRoute.clear();
    isTracking.value = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      LatLng newPoint = LatLng(position.latitude, position.longitude);
      final timestamp = DateTime.now().toIso8601String();

      // 🔍 Check if new point is inside the city border
      if (!isPointInsidePolygon(newPoint, savedBorder)) {
        Get.snackbar("Out of bounds", "You are outside the city border!");
        return;
      }

      if (routePoints.isNotEmpty) {
        final lastPoint = routePoints.last;
        double distance = Geolocator.distanceBetween(
          lastPoint.latitude,
          lastPoint.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );
        if (distance < 20) {
          print("Skipping point (distance = ${distance.toStringAsFixed(2)} m)");
          return;
        }
      }

      if (routePoints.isEmpty) {
        markers.add(
          Marker(
            markerId: MarkerId('start'),
            position: newPoint,
            infoWindow: InfoWindow(title: 'Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }

      trackedRoute.add({
        'lat': newPoint.latitude,
        'lng': newPoint.longitude,
        'time': timestamp,
      });

      routePoints.add(newPoint);

      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: routePoints.toList(),
        ),
      );

      mapController.value!.animateCamera(CameraUpdate.newLatLng(newPoint));
    });
  }

  void stopTracking() async {
    print("Route tracking stopped");
    positionStream?.cancel();
    isTracking.value = false;

    points.value =
        trackedRoute
            .where((point) => point['lat'] != null && point['lng'] != null)
            .map(
              (point) =>
                  LatLng(point['lat']!.toDouble(), point['lng']!.toDouble()),
            )
            .toList();

    print("✅ Route saved with ${points.length} points");

    navigateRoutePreview();
  }

  Future<void> loadSavedBorder() async {
    try {
      // Use cityBorder passed into the controller instead of SharedPreferences
      if (cityBorder.isNotEmpty) {
        savedBorder.value = cityBorder;
      } else {
        print("No city border data available.");
      }

      isLoading.value = false;

      // If the map is created, update the camera view
      if (savedBorder.isNotEmpty && mapController.value != null) {
        Future.delayed(Duration(milliseconds: 300), () {
          final bounds = getBoundsFromLatLngList(savedBorder);
          print("Camera Bounds: $bounds");

          // Check if bounds are valid
          if (bounds != null) {
            mapController.value?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 30), // Add padding
            );
          } else {
            print("Error: Invalid bounds calculated.");
          }
        });
      }
    } catch (e) {
      isLoading.value = false;
      print("Error loading saved border: $e");
      Get.snackbar("Error", "Failed to load saved border data");
    }
  }

  LatLngBounds getBoundsFromLatLngList(List<LatLng> points) {
    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();

    // Calculate the southwest and northeast points based on the latitudes and longitudes
    final southwest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northeast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    // Return the LatLngBounds with southwest and northeast
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  Set<Polygon> createCityBorderPolygon() {
    return {
      Polygon(
        polygonId: PolygonId('cityBorder'),
        points: cityBorder,
        strokeColor: Colors.red,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.1),
      ),
    };
  }
}
