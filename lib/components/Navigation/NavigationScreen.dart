import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/Navigation/NavigationController.dart';
import 'package:survey_dogapp/components/Navigation/RoutePreviewScreenTest.dart';
import 'package:survey_dogapp/components/addDogOwnerPage.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class NavigationScreen extends StatefulWidget {
  final RouteDataModel routeData;
  final String routeType;

  const NavigationScreen({
    super.key,
    required this.routeData,
    required this.routeType,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late NavigationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      NavigationController(widget.routeData, widget.routeType),
    );
    controller.dogTypeFetch(widget.routeData.cityId);
  }

  @override
  void dispose() {
    Get.delete<NavigationController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: screenWidth * 0.17,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Get.back(),
                    iconSize: screenWidth * 0.06,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.routeData.routeName,
                      style: FontHelper.semiBold(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showRouteBottomSheet(context);
                    },
                    icon: Icon(Icons.remove_red_eye, color: AppColors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(
                () => Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target:
                            controller.currentPosition.value ??
                            LatLng(21.1702, 72.8311),
                        zoom: 17,
                      ),
                      onMapCreated: (mapController) {
                        controller.setMapController(mapController);
                        controller.getCurrentLocationAndMoveCamera();
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: controller.markers.toSet(),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: controller.routePoints,
                          color: Colors.blue,
                          width: 5,
                          geodesic: true,
                          jointType: JointType.round,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                        ),
                      },
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 20,
                      child: CustomFormButton(
                        innerText:
                            controller.isNavigating.value
                                ? 'Stop Tracking'
                                : 'Start Tracking',
                        onPressed: () async {
                          if (controller.isNavigating.value) {
                            if (controller.trackingStart.value) {
                              controller.stopNavigation();
                              Get.to(
                                () => RoutePreviewScreenTest(
                                  routePoints: controller.routePoints.toList(),
                                  markers: controller.markers.toSet(),
                                ),
                              );
                            }
                            return;
                          }
                          String formattedTime = DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(DateTime.now());
                          final isProcessing =
                              widget.routeType == UrlConstants.routeProcessing;
                          final isPending =
                              widget.routeType == UrlConstants.routePending;

                          if (isProcessing) {
                            if (controller.trackingStart.value) {
                              await controller.checkRouteTime(
                                UrlConstants.routeFlagEnd,
                                widget.routeData.routeId,
                                UrlConstants.routeProcessing,
                                endTime: formattedTime,
                              );
                            } else {
                              if (widget.routeData.startDate.isEmpty) {
                                CommonUtils.buildSnackBar(
                                  "Start DateTime not set for this route.",
                                  "Warning",
                                  AppColors.orange,
                                  5,
                                );
                                return;
                              }

                              if (controller.isNearRouteStart()) {
                                await controller.checkRouteTime(
                                  UrlConstants.routeFlagStart,
                                  widget.routeData.routeId,
                                  UrlConstants.routeProcessing,
                                  startTime: formattedTime,
                                );
                              } else {
                                CommonUtils.buildSnackBar(
                                  "You're not within 50 meters of the route, so you cannot start the route.",
                                  "Warning",
                                  AppColors.orange,
                                  2,
                                );
                              }
                            }
                          } else if (isPending) {
                            if (controller.trackingStart.value) {
                              showCommonDialog(
                                context: context,
                                icon: Icons.save_rounded,
                                iconColor: AppColors.primary,
                                title: "Confirmation",
                                subTitle: "Route Confirm or Reject?",
                                negativeText: "Reject",
                                positiveText: "Confirm",
                                onPositivePressed: () async {
                                  Get.back();
                                  await controller.checkRouteTime(
                                    UrlConstants.routeFlagConfirm,
                                    widget.routeData.routeId,
                                    UrlConstants.routePending,
                                  );
                                  await controller.checkRouteTime(
                                    UrlConstants.routeFlagEnd,
                                    widget.routeData.routeId,
                                    UrlConstants.routePending,
                                    endTime: formattedTime,
                                  );
                                  controller.trackingStart.value = false;
                                },
                                onNegativeWithRemarkPressed: (
                                  String remark,
                                ) async {
                                  Get.back();
                                  await controller.checkRouteTime(
                                    UrlConstants.routeFlagReject,
                                    widget.routeData.routeId,
                                    UrlConstants.routePending,
                                    remarkText: remark,
                                  );
                                  await controller.checkRouteTime(
                                    UrlConstants.routeFlagEnd,
                                    widget.routeData.routeId,
                                    UrlConstants.routePending,
                                    endTime: formattedTime,
                                  );
                                  controller.trackingStart.value = false;
                                },
                              );
                            } else {
                              if (widget.routeData.startDate.isEmpty) {
                                CommonUtils.buildSnackBar(
                                  "Start DateTime not set for this route.",
                                  "Warning",
                                  AppColors.orange,
                                  5,
                                );
                                return;
                              }

                              await controller.checkRouteTime(
                                UrlConstants.routeFlagStart,
                                widget.routeData.routeId,
                                UrlConstants.routePending,
                                startTime: formattedTime,
                              );
                              controller.trackingStart.value = true;
                            }
                          } else {
                            CommonUtils.buildSnackBar(
                              "Route is not valid for processing.",
                              "Error",
                              AppColors.red,
                              5,
                            );
                          }
                        },
                      ),
                    ),

                    if (widget.routeType == UrlConstants.routeProcessing &&
                        CommonUtils.getUserRole() == UrlConstants.SURVEYOR)
                      Positioned(
                        top: 30,
                        right: 10,
                        bottom: 120,
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  if (controller.isDogTypeLoading.value) {
                                    return ListView.builder(
                                      itemCount: 8,
                                      itemBuilder:
                                          (context, index) => Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CommonShimmer(
                                                width: 50,
                                                height: 70,
                                              ),
                                            ),
                                          ),
                                    );
                                  }

                                  if (controller.dogTypeList.isEmpty) {
                                    return const Center(
                                      child: Text("No dog types"),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: controller.dogTypeList.length,
                                    itemBuilder: (context, index) {
                                      final markerData =
                                          controller.dogTypeList[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          if (controller.trackingStart.value &&
                                              controller
                                                      .currentPosition
                                                      .value !=
                                                  null) {
                                            if (markerData.imageStatus == 1) {
                                              bool? captured = await controller
                                                  .showImageCapturePopup(
                                                    markerData.id ?? 0,
                                                    controller
                                                        .currentPosition
                                                        .value,
                                                  );
                                              if (captured == null) {
                                                CommonUtils.buildSnackBar(
                                                  "Image capture cancelled.",
                                                  "Warning",
                                                  AppColors.orange,
                                                  2,
                                                );
                                                return;
                                              }
                                            } else {
                                              controller.updateDogDataList(
                                                markerData.id ?? 0,
                                                controller
                                                    .currentPosition
                                                    .value,
                                              );
                                            }
                                            final markerId = MarkerId(
                                              "marker_${DateTime.now().millisecondsSinceEpoch}",
                                            );
                                            final icon = await controller
                                                .loadIconFromUrl(
                                                  markerData.imagePath ?? "",
                                                );

                                            final marker = Marker(
                                              markerId: markerId,
                                              position:
                                                  controller
                                                      .currentPosition
                                                      .value!,
                                              icon: icon,
                                              infoWindow: InfoWindow(
                                                title: markerData.name,
                                              ),
                                            );

                                            controller.markers.add(marker);

                                            controller.update();

                                            CommonUtils.buildSnackBar(
                                              "Marker added successfully.",
                                              "Success",
                                              AppColors.green,
                                              2,
                                            );
                                          } else {
                                            CommonUtils.buildSnackBar(
                                              "Route not started.",
                                              "Warning",
                                              AppColors.orange,
                                              2,
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  markerData.imagePath ?? "",
                                              height: 70,
                                              width: 50,
                                              fit: BoxFit.fill,
                                              placeholder:
                                                  (context, url) =>
                                                      CommonShimmer(
                                                        width: 50,
                                                        height: 70,
                                                      ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).marginAll(8);
                                }),
                              ),
                              const SizedBox(height: 8),
                              if ((CommonUtils.getCurrentUser()?.ownership ??
                                      0) ==
                                  1) ...[
                                GestureDetector(
                                  onTap: () => Get.to(AddDogOwnerPage()),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ownership",
                                  textAlign: TextAlign.center,
                                  style: FontHelper.regular(
                                    color: AppColors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showRouteBottomSheet(BuildContext context) {
    List<LatLng> routeLatLngList =
        widget.routeData.map
            .map((point) => LatLng(point.lat, point.lng))
            .toList();

    if (routeLatLngList.isEmpty) {
      CommonUtils.buildSnackBar(
        "No route data available.",
        "Warning",
        AppColors.orange,
        3,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, sheetController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: routeLatLngList.first,
                    zoom: 15,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route_preview"),
                      points: routeLatLngList,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("start"),
                      position: routeLatLngList.first,
                      infoWindow: const InfoWindow(title: "Start"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId("end"),
                      position: routeLatLngList.last,
                      infoWindow: const InfoWindow(title: "End"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: (mapController) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    LatLngBounds bounds = _createLatLngBounds(routeLatLngList);
                    mapController.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
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

  void showCommonDialog({
    required BuildContext context,
    IconData? icon,
    required Color iconColor,
    required String title,
    required String subTitle,
    required String negativeText,
    required String positiveText,
    required VoidCallback onPositivePressed,
    Function(String)? onNegativeWithRemarkPressed,
  }) {
    final TextEditingController remarkController = TextEditingController();
    final ValueNotifier<bool> showRemarkField = ValueNotifier(false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ValueListenableBuilder<bool>(
              valueListenable: showRemarkField,
              builder: (context, showRemark, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(child: Icon(icon, size: 48, color: iconColor)),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        title,
                        style: FontHelper.bold(fontSize: 20, color: iconColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        subTitle,
                        textAlign: TextAlign.center,
                        style: FontHelper.regular(
                          fontSize: 16,
                          color: const Color(0xFF444444),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Optional Remark Field
                    if (showRemark)
                      TextField(
                        controller: remarkController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Enter Remark",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Buttons
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (!showRemark) {
                                showRemarkField.value = true;
                              } else {
                                if (onNegativeWithRemarkPressed != null) {
                                  onNegativeWithRemarkPressed(
                                    remarkController.text.trim(),
                                  );
                                }
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              showRemark ? "Submit Remark" : negativeText,
                              style: FontHelper.regular(),
                            ),
                          ),
                        ),
                        if (!showRemark) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: iconColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                onPositivePressed();
                              },
                              child: Text(
                                positiveText,
                                style: FontHelper.bold(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
