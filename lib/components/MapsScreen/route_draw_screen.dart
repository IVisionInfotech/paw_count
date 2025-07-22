import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/RouteController.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class RouteDrawScreen extends StatefulWidget {
  final bool isManually;
  final List<LatLng> cityBorder;

  const RouteDrawScreen({
    super.key,
    required this.isManually,
    required this.cityBorder,
  });

  @override
  State<RouteDrawScreen> createState() => _RouteDrawScreenState();
}

class _RouteDrawScreenState extends State<RouteDrawScreen> {
  late RouteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RouteController(widget.isManually,widget.cityBorder));

    if (widget.isManually && widget.cityBorder.isNotEmpty) {
      controller.setCityBorder(widget.cityBorder); // custom function
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isManually) {
      return Obx(
        () => Scaffold(
          body:
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.symmetric(
                          horizontal: BorderSide(color: AppColors.primary, width: 1),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                              iconSize: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Draw Map On Map",
                              style: FontHelper.semiBold(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: controller.currentLocation.value == null
                          ? Center(child: CircularProgressIndicator())
                          : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: controller.currentLocation.value!,
                          zoom: 18,
                        ),
                        onMapCreated: (mapCtrl) {
                              controller.mapController.value = mapCtrl;

                              if (controller.savedBorder.isNotEmpty) {
                                final bounds = controller.getBoundsFromLatLngList(
                                  controller.savedBorder,
                                );
                                Future.delayed(Duration(milliseconds: 300), () {
                                  controller.mapController.value!.animateCamera(
                                    CameraUpdate.newLatLngBounds(bounds, 50),
                                  );
                                });
                              }
                            },
                            polygons: controller.createCityBorderPolygon(),
                            polylines: controller.polylines,
                            markers: controller.markers,
                            myLocationEnabled: true,
                          ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomFormButton(
                          innerText:
                          controller.isTracking.value ? "Stop Route" : "Start Route",
                          onPressed: () {
                            controller.isTracking.value
                                ? controller.stopTracking()
                                : controller.startTracking();
                          },
                        ),
                      ),
                  ],
                ),
              ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      iconSize: 30,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 90,
                      child: Text(
                        "Draw Map Manually",
                        style: FontHelper.semiBold(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo, color: AppColors.white),
                      onPressed: controller.undo,
                      tooltip: 'Undo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.redo, color: AppColors.white),
                      onPressed: controller.redo,
                      tooltip: 'Redo',
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: AppColors.white),
                      onPressed: controller.navigateRoutePreview,
                      tooltip: 'Save',
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.white),
                      onPressed: controller.clearRoute,
                      tooltip: 'Clear',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                return controller.savedBorder.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  onMapCreated: controller.onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: controller.getBoundsFromLatLngList(controller.savedBorder).southwest
                        .latitude != controller.getBoundsFromLatLngList(controller.savedBorder).northeast
                        .latitude
                        ? LatLng(
                      (controller.getBoundsFromLatLngList(controller.savedBorder).southwest.latitude +
                          controller.getBoundsFromLatLngList(controller.savedBorder).northeast.latitude) /
                          2,
                      (controller.getBoundsFromLatLngList(controller.savedBorder).southwest.longitude +
                          controller.getBoundsFromLatLngList(controller.savedBorder).northeast.longitude) /
                          2,
                    )
                        : controller.getBoundsFromLatLngList(controller.savedBorder).southwest,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polygons: controller.createCityBorderPolygon(),
                  polylines: controller.polylines.value,
                  markers: controller.markers.value,
                  onTap: controller.onTap,
                );
              }),
            )

          ],
        ),
      ),
    );
  }
}
