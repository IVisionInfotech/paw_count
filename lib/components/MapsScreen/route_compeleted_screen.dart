import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/theme.dart';

class RouteCompeletedScreen extends StatefulWidget {
  final RouteDataModel routeData;
  final String routeType;

  const RouteCompeletedScreen({
    super.key,
    required this.routeData,
    required this.routeType,
  });

  @override
  State<RouteCompeletedScreen> createState() => _RouteCompeletedScreenState();
}

class _RouteCompeletedScreenState extends State<RouteCompeletedScreen> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  CameraPosition? _initialCameraPosition;
  bool _isLoading = true;
  double _totalDistanceInKm = 0.0;


  @override
  void initState() {
    super.initState();
    _prepareMapData();
  }

  double calculateDistanceInMeters(LatLng p1, LatLng p2) {
    const R = 6371000; // Earth's radius in meters
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLon = (p2.longitude - p1.longitude) * pi / 180;

    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }


  Future<void> _prepareMapData() async {
    final surveyorMapPoints = widget.routeData.surveyorMap ?? [];
    final dogMarkers = widget.routeData.dogMarkers ?? [];

    List<LatLng> polylinePoints = surveyorMapPoints
        .map((point) => LatLng(point.lat, point.lng))
        .toList();

    Set<Polyline> tempPolylines = {};
    if (polylinePoints.isNotEmpty) {
      tempPolylines.add(Polyline(
        polylineId: const PolylineId('surveyor_route'),
        points: polylinePoints,
        color: Colors.blue,
        width: 5,
      ));

      _initialCameraPosition = CameraPosition(
        target: polylinePoints.first,
        zoom: 16,
      );
    }

    Set<Marker> tempMarkers = {};

    if (polylinePoints.isNotEmpty) {
      tempMarkers.add(Marker(
        markerId: const MarkerId('start_point'),
        position: polylinePoints.first,
        infoWindow: const InfoWindow(title: 'Start Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (polylinePoints.length > 1) {
      tempMarkers.add(Marker(
        markerId: const MarkerId('end_point'),
        position: polylinePoints.last,
        infoWindow: const InfoWindow(title: 'End Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    double totalDistance = 0.0;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      totalDistance += calculateDistanceInMeters(polylinePoints[i], polylinePoints[i + 1]);
    }
    _totalDistanceInKm = totalDistance / 1000;

    for (var dogMarker in dogMarkers) {
      final position = LatLng(dogMarker.lat, dogMarker.lng);
      final markerId = MarkerId('${dogMarker.lat}_${dogMarker.lng}');

      try {
        final Uint8List markerIcon = await _getBytesFromNetworkImage(
          dogMarker.dogTypeImg,
          targetWidth: 100,
        );

        tempMarkers.add(Marker(
          markerId: markerId,
          position: position,
          infoWindow: InfoWindow(
            title: dogMarker.dogType,
            snippet: dogMarker.surveyorName,
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        ));
      } catch (e) {
        debugPrint("Error loading marker icon: $e");

        tempMarkers.add(Marker(
          markerId: markerId,
          position: position,
          infoWindow: InfoWindow(
            title: dogMarker.dogType,
            snippet: dogMarker.surveyorName,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      }
    }

    if (mounted) {
      setState(() {
        _polylines = tempPolylines;
        _markers = tempMarkers;
        _isLoading = false;
      });
    }
  }


  Future<Uint8List> _getBytesFromNetworkImage(String url, {int targetWidth = 100}) async {
    final http.Response response = await http.get(Uri.parse(url));
    final Uint8List bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    if (_initialCameraPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget("Completed Route", 10, context, () {
              Get.back();
            }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total Distance: ${_totalDistanceInKm.toStringAsFixed(2)} km",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _initialCameraPosition!,
                    polylines: _polylines,
                    markers: _markers,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
