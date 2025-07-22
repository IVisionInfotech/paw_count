import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/models/markerData.dart';

class SavedRouteCotroller extends GetxController {
  final List<Map<String, dynamic>>? savedRoute;
  RxList<LatLng> latLngPoints = <LatLng>[].obs;
  RxSet<Marker> markers = <Marker>{}.obs;
  RxSet<Polyline> polylines = <Polyline>{}.obs;

  final List<MarkerData> markerList = [
    MarkerData(name: "Female sterile", imageUrl: "https://cdn0.iconfinder.com/data/icons/creatype-pet-shop-glyph/64/1_dog_gender_pet_shop_female-512.png"),
    MarkerData(name: "Lactating", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
    MarkerData(name: "Female", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
    MarkerData(name: "Male sterile", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
    MarkerData(name: "Male", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
    MarkerData(name: "Unknown adult", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
    MarkerData(name: "Pup", imageUrl: "https://cdn.iconscout.com/icon/premium/png-256-thumb/male-dog-2792778-2325431.png"),
  ];

  SavedRouteCotroller(this.savedRoute);

  @override
  void onInit() {
    super.onInit();
    loadPolylineRoute();
  }

  void loadPolylineRoute() async {
    try {
      // Safely parse and load polyline points
      latLngPoints.value = savedRoute!
          .map((e) => LatLng(
        double.tryParse(e['lat'].toString()) ?? 0,
        double.tryParse(e['lng'].toString()) ?? 0,
      ))
          .toList();

      // Add polyline
      polylines.add(
        Polyline(
          polylineId: PolylineId("demo_route"),
          color: Colors.orange,
          width: 6,
          points: latLngPoints,
        ),
      );

      // Add start and end markers
      if (latLngPoints.length >= 2) {
        final start = latLngPoints.first;
        final end = latLngPoints.last;

        markers.add(
          Marker(
            markerId: MarkerId("start"),
            position: start,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: "Start"),
          ),
        );

        markers.add(
          Marker(
            markerId: MarkerId("end"),
            position: end,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: "End"),
          ),
        );
      }
    } catch (e) {
      print("Error loading polyline: $e");
    }
  }


  Future<void> handleMapTap(LatLng tappedPoint, BuildContext context) async {
    bool isOnRoute = false;

    for (int i = 0; i < latLngPoints.length - 1; i++) {
      if (_isPointNearLine(tappedPoint, latLngPoints[i], latLngPoints[i + 1], thresholdMeters: 2)) {
        isOnRoute = true;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _buildMarkerSelectionBottomSheet(context, tappedPoint),
        );
        break;
      }
    }

    if (!isOnRoute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are outside of your route")),
      );
    }
  }

  Widget _buildMarkerSelectionBottomSheet(BuildContext context, LatLng tappedPoint) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Marker Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            itemCount: markerList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final markerData = markerList[index];
              return GestureDetector(
                onTap: () async {
                  final icon = await _loadIconFromUrl(markerData.imageUrl);
                  markers.add(
                    Marker(
                      markerId: MarkerId("marker_${markers.length}"),
                      position: tappedPoint,
                      infoWindow: InfoWindow(title: markerData.name),
                      icon: icon,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.network(markerData.imageUrl, fit: BoxFit.contain),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(markerData.name, textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> _loadIconFromUrl(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final Uint8List imageBytes = await file.readAsBytes();

    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 100);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  bool _isPointNearLine(LatLng tap, LatLng start, LatLng end, {double thresholdMeters = 30.0}) {
    return _distanceToLineSegment(tap, start, end) <= thresholdMeters;
  }

  double _distanceToLineSegment(LatLng p, LatLng v, LatLng w) {
    const earthRadius = 6371000;

    double lat1 = _degToRad(v.latitude);
    double lon1 = _degToRad(v.longitude);
    double lat2 = _degToRad(w.latitude);
    double lon2 = _degToRad(w.longitude);
    double lat3 = _degToRad(p.latitude);
    double lon3 = _degToRad(p.longitude);

    double dx = lon2 - lon1;
    double dy = lat2 - lat1;

    double t = ((lon3 - lon1) * dx + (lat3 - lat1) * dy) / (dx * dx + dy * dy);
    t = max(0, min(1, t));

    double projLon = lon1 + t * dx;
    double projLat = lat1 + t * dy;

    double dLat = lat3 - projLat;
    double dLon = lon3 - projLon;

    double a = pow(sin(dLat / 2), 2) + cos(lat3) * cos(projLat) * pow(sin(dLon / 2), 2);
    return 2 * earthRadius * asin(sqrt(a));
  }

  double _degToRad(double deg) => deg * pi / 180.0;

  void saveRouteData(BuildContext context) {
    final savedPolyline = latLngPoints.map((point) {
      return {
        'lat': point.latitude,
        'lng': point.longitude,
      };
    }).toList();

    final savedMarkers = markers.map((marker) {
      return {
        'lat': marker.position.latitude,
        'lng': marker.position.longitude,
        'type': marker.infoWindow.title,
      };
    }).toList();

    final routeData = {
      'polyline': savedPolyline,
      'markers': savedMarkers,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print("Saved Data:\n$routeData");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Route and markers saved!"),
        duration: Duration(seconds: 2),
      ),
    );

    // You can save `routeData` to a local database or file here
  }
}
