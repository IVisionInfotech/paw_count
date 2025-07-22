import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/RouteDetailsController.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';

class DogCaughtScreen extends StatefulWidget {
  final RouteDataModel routeData;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  const DogCaughtScreen({
    Key? key,
    required this.routeData,
    required this.markers,
    required this.polylines,
  }) : super(key: key);

  @override
  State<DogCaughtScreen> createState() => _DogCaughtScreenState();
}

class _DogCaughtScreenState extends State<DogCaughtScreen> {
  GoogleMapController? _mapController;

  RouteDetailsController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitCameraToPolylines();
    });
  }

  void _fitCameraToPolylines() {
    if (widget.polylines.isNotEmpty && _mapController != null) {
      List<LatLng> allPoints = [];
      for (var polyline in widget.polylines) {
        allPoints.addAll(polyline.points);
      }

      if (allPoints.isNotEmpty) {
        final bounds = _getLatLngBounds(allPoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double x0 = points.first.latitude;
    double x1 = points.first.latitude;
    double y0 = points.first.longitude;
    double y1 = points.first.longitude;

    for (LatLng latLng in points) {
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
    }

    return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget("Route Preview", 20, context, () {
              Get.back();
            }),
            const SizedBox(height: 10),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.routeData.map.first.lat,
                    widget.routeData.map.first.lng,
                  ),
                  zoom: 19.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _fitCameraToPolylines();
                },
                markers: widget.markers,
                polylines: Set<Polyline>.from(controller.polylines),
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomFormButton(
                  innerText: controller.isLoading.value ? "Saving..." : "Save",
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
                        await controller.saveFinalCatchRoute(
                          widget.routeData.routeId,
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
    );
  }
}
