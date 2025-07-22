/*
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:survey_dogapp/components/MapsScreen/cotroller/RouteController.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';

class RoutePreviewScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final bool isManually;

  const RoutePreviewScreen({
    super.key,
    required this.routePoints,
    required this.isManually,
  });

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen> {
  late Set<Polyline> polylineSet = {};
  late Set<Marker> markerSet = {};
  GoogleMapController? mapController;
  RouteController controller = Get.find();
  List<LatLng> snappedPolylinePoints = [];

  @override
  void initState() {
    super.initState();
    _drawSnappedRoute();
  }

  Future<void> _drawSnappedRoute() async {
    const apiKey = 'AIzaSyCTxSa2jViHaPwRrbjy55psU760-suFaE4';

    if (widget.routePoints.length < 2) return;

    final path = widget.routePoints
        .map((e) => '${e.latitude},${e.longitude}')
        .join('|');

    final url =
        'https://roads.googleapis.com/v1/snapToRoads'
        '?path=$path'
        '&interpolate=true'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['snappedPoints'] == null || data['snappedPoints'].isEmpty) {
        throw Exception("No snapped points returned");
      }

      final List<LatLng> snappedPoints =
          data['snappedPoints']
              .map<LatLng>(
                (p) => LatLng(
                  p['location']['latitude'],
                  p['location']['longitude'],
                ),
              )
              .toList();
      snappedPolylinePoints = snappedPoints;
      _setPolylineAndMarkers(
        snappedPoints,
        widget.routePoints.first,
        widget.routePoints.last,
      );
    } catch (e) {
      print("Roads API error: $e");
      _drawStraightLine();
    }
  }

  void _setPolylineAndMarkers(
    List<LatLng> points,
    LatLng origin,
    LatLng destination,
  ) {
    setState(() {
      polylineSet = {
        Polyline(
          polylineId: const PolylineId('snapped_route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      };

      markerSet = {
        Marker(
          markerId: const MarkerId('start'),
          position: origin,
          infoWindow: const InfoWindow(title: 'Start'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: destination,
          infoWindow: const InfoWindow(title: 'End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    if (mapController != null) {
      final bounds = _getBounds(points);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _drawStraightLine() {
    setState(() {
      polylineSet = {
        Polyline(
          polylineId: const PolylineId('fallback_line'),
          color: Colors.blue,
          width: 4,
          points: widget.routePoints,
        ),
      };

      markerSet = {
        Marker(
          markerId: const MarkerId('start'),
          position: widget.routePoints.first,
          infoWindow: const InfoWindow(title: 'Start'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: widget.routePoints.last,
          infoWindow: const InfoWindow(title: 'End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });

    if (mapController != null) {
      final bounds = _getBounds(widget.routePoints);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    final southwestLat = points.map((p) => p.latitude).reduce(min);
    final southwestLng = points.map((p) => p.longitude).reduce(min);
    final northeastLat = points.map((p) => p.latitude).reduce(max);
    final northeastLng = points.map((p) => p.longitude).reduce(max);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget("Route Preview", 10, context, () {
              Get.back();
            }),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.routePoints.first,
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                polylines: polylineSet,
                markers: markerSet,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CustomFormButton(
                innerText: "Save",
                onPressed: () {
                  DialogHelper.showCommonDialog(
                    context: context,
                    icon: Icons.save_rounded,
                    iconColor: AppColors.primary,
                    title: "Save",
                    subTitle: "Are You Sure?",
                    negativeText: "No",
                    positiveText: "Yes",
                    onPositivePressed: () async {
                      Get.back();
                      if (snappedPolylinePoints.isEmpty) {
                        await controller.saveRoute(widget.routePoints);
                      } else {
                        await controller.saveRoute(snappedPolylinePoints);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:survey_dogapp/components/MapsScreen/cotroller/RouteController.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';

class RoutePreviewScreen extends StatefulWidget {
  final List<LatLng> routePoints;
  final bool isManually;

  const RoutePreviewScreen({
    super.key,
    required this.routePoints,
    required this.isManually,
  });

  @override
  State<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends State<RoutePreviewScreen> {
  late Set<Polyline> polylineSet = {};
  late Set<Marker> markerSet = {};
  GoogleMapController? mapController;
  RouteController controller = Get.find();
  List<LatLng> snappedPolylinePoints = [];

  @override
  void initState() {
    super.initState();
    if (widget.isManually) {
      _drawStraightLine();
    } else {
      _drawStraightLine();
    }
  }

  Future<void> _drawSnappedRoute() async {
    const apiKey = 'AIzaSyCTxSa2jViHaPwRrbjy55psU760-suFaE4';

    if (widget.routePoints.length < 2) return;

    final path = widget.routePoints
        .map((e) => '${e.latitude},${e.longitude}')
        .join('|');

    final url = 'https://roads.googleapis.com/v1/snapToRoads'
        '?path=$path'
        '&interpolate=true'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['snappedPoints'] == null || data['snappedPoints'].isEmpty) {
        throw Exception("No snapped points returned");
      }

      final List<LatLng> snappedPoints = data['snappedPoints']
          .map<LatLng>((p) => LatLng(
        p['location']['latitude'],
        p['location']['longitude'],
      ))
          .toList();

      snappedPolylinePoints = snappedPoints;
      _setPolylineAndMarkers(
        snappedPoints,
        widget.routePoints.first,
        widget.routePoints.last,
      );
    } catch (e) {
      print("Roads API error: $e");
      _drawStraightLine();
    }
  }

  void _drawStraightLine() {
    _setPolylineAndMarkers(
      widget.routePoints,
      widget.routePoints.first,
      widget.routePoints.last,
    );
  }

  void _setPolylineAndMarkers(
      List<LatLng> points, LatLng origin, LatLng destination) {
    setState(() {
      polylineSet = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      };

      markerSet = {
        for (int i = 0; i < points.length; i++)
          Marker(
            markerId: MarkerId('point_$i'),
            position: points[i],
            infoWindow: InfoWindow(
              title: i == 0
                  ? 'Start'
                  : i == points.length - 1
                  ? 'End'
                  : 'Point $i',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              i == 0
                  ? BitmapDescriptor.hueGreen
                  : i == points.length - 1
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueAzure,
            ),
          ),
      };
    });

    if (mapController != null && points.length >= 2) {
      final bounds = _getBounds(points);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    final southwestLat = points.map((p) => p.latitude).reduce(min);
    final southwestLng = points.map((p) => p.longitude).reduce(min);
    final northeastLat = points.map((p) => p.latitude).reduce(max);
    final northeastLng = points.map((p) => p.longitude).reduce(max);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget("Route Preview", 10, context, () {
              Get.back();
            }),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.routePoints.first,
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  _drawStraightLine();
                },
                polylines: polylineSet,
                markers: markerSet,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: CustomFormButton(
                innerText: "Save",
                onPressed: () {
                  DialogHelper.showCommonDialog(
                    context: context,
                    icon: Icons.save_rounded,
                    iconColor: AppColors.primary,
                    title: "Save",
                    subTitle: "Are You Sure?",
                    negativeText: "No",
                    positiveText: "Yes",
                    onPositivePressed: () async {
                      Get.back();
                      if (snappedPolylinePoints.isEmpty) {
                        await controller.saveRoute(widget.routePoints);
                      } else {
                        await controller.saveRoute(snappedPolylinePoints);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

