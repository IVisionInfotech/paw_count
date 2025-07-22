import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/Navigation/NavigationController.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';

class RoutePreviewScreenTest extends StatefulWidget {
  final List<LatLng> routePoints;
  final Set<Marker> markers;

  const RoutePreviewScreenTest({
    Key? key,
    required this.routePoints,
    required this.markers,
  }) : super(key: key);

  @override
  State<RoutePreviewScreenTest> createState() => _RoutePreviewScreenTestState();
}

class _RoutePreviewScreenTestState extends State<RoutePreviewScreenTest> {
  GoogleMapController? _mapController;
  final controller = Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    final points = widget.routePoints;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget("Route Preview", 10, context, () {
              Get.back();
            }),
            Expanded(
              child:
                  points.isEmpty
                      ? const Center(child: Text("No route recorded."))
                      : Column(
                        children: [
                          Expanded(
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: points.first,
                                zoom: 16,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                                _fitRouteToScreen();
                              },
                              polylines: {
                                Polyline(
                                  polylineId: const PolylineId("route"),
                                  points: points,
                                  color: Colors.blue,
                                  width: 5,
                                  geodesic: true,
                                  jointType: JointType.round,
                                  startCap: Cap.roundCap,
                                  endCap: Cap.roundCap,
                                ),
                              },
                              markers: {
                                ...widget.markers,
                                Marker(
                                  markerId: const MarkerId("start"),
                                  position: points.first,
                                  infoWindow: const InfoWindow(title: "Start"),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen,
                                  ),
                                ),
                                Marker(
                                  markerId: const MarkerId("end"),
                                  position: points.last,
                                  infoWindow: const InfoWindow(title: "End"),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                ),
                              },
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  controller.isLoading.value
                                      ? const CircularProgressIndicator()
                                      : CustomFormButton(
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
                                              Get.close(1);
                                              await controller
                                                  .saveFinalCatchRoute(
                                                    widget.routePoints,
                                                  );
                                            },
                                          );
                                        },
                                      ),
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

  void _fitRouteToScreen() async {
    if (widget.routePoints.isEmpty || _mapController == null) return;

    LatLngBounds bounds = _createLatLngBounds(widget.routePoints);
    await Future.delayed(const Duration(milliseconds: 300));

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _createLatLngBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

    for (var point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }
}
