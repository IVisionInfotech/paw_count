import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/RouteDetailsController.dart';
import 'package:survey_dogapp/components/MapsScreen/dog_caughted_screen.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/addDogOwnerPage.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class RouteDetailsScreen extends StatefulWidget {
  final RouteDataModel routeData;
  final String routeType;

  const RouteDetailsScreen({
    super.key,
    required this.routeData,
    required this.routeType,
  });

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  late RouteDetailsController controller;
  late StreamSubscription<LocationData> locationSubscription;
  List<LatLng> snappedPolylinePoints = [];
  late Set<Polyline> polylineSet = {};
  late Set<Marker> markerSet = {};

  @override
  void initState() {
    super.initState();
    controller = Get.put(RouteDetailsController());
    controller.initRoute(widget.routeData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drawStraightLine();
      if (widget.routeData.routeConfirm == 1) {
        controller.dogTypeFetch();
      }
      _addExistingMarkers();
    });

    locationSubscription = Location().onLocationChanged.listen((location) {
      controller.currentLocation = location;
    });
  }

  Future<void> _addExistingMarkers() async {
    final markers = widget.routeData.dogMarkers;
    print("qaqaqaqaqa ${markers}");
    if (markers == null || markers.isEmpty) return;

    for (int i = 0; i < markers.length; i++) {
      final data = markers[i];
      final icon = await controller.loadIconFromUrl(data.dogTypeImg ?? '');

      final marker = Marker(
        markerId: MarkerId("dog_saved_$i"),
        position: LatLng(data.lat, data.lng),
        icon: icon,
        infoWindow: InfoWindow(title: data.dogType),
      );

      controller.markers.add(marker);
    }

    controller.update();
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  Future<void> _drawSnappedRoute() async {
    const apiKey = 'AIzaSyCTxSa2jViHaPwRrbjy55psU760-suFaE4';

    final rawPoints = controller.latLngPoints;
    if (rawPoints.length < 2) return;

    final path = rawPoints.map((e) => '${e.latitude},${e.longitude}').join('|');

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

      // Map of original index to snapped point list
      final Map<int, List<LatLng>> snappedMap = {};

      for (var p in data['snappedPoints']) {
        final loc = p['location'];
        final latLng = LatLng(
          (loc['latitude'] as num).toDouble(),
          (loc['longitude'] as num).toDouble(),
        );

        final index = p['originalIndex'] ?? -1;

        if (!snappedMap.containsKey(index)) {
          snappedMap[index] = [];
        }
        snappedMap[index]!.add(latLng);
      }

      // Build full route preserving original order
      final List<LatLng> fullRoute = [];

      for (int i = 0; i < rawPoints.length; i++) {
        if (snappedMap.containsKey(i)) {
          fullRoute.addAll(snappedMap[i]!);
        } else {
          // This point was off-road (not in snapped list)
          fullRoute.add(rawPoints[i]);
        }
      }

      snappedPolylinePoints = fullRoute;

      _setPolylineAndMarkers(fullRoute, rawPoints.first, rawPoints.last);
    } catch (e) {
      print("SnapToRoads failed: $e");
      _drawStraightLine();
    }
  }

  void _drawStraightLine() {
    _setPolylineAndMarkers(
      controller.latLngPoints,
      controller.latLngPoints.first,
      controller.latLngPoints.last,
    );
  }

  void _setPolylineAndMarkers(
      List<LatLng> points, LatLng origin, LatLng destination) {
    setState(() {
      // Create the polyline
      polylineSet = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      };

      // Create markers for each point
      markerSet = {
        for (int i = 0; i < points.length; i++)
          Marker(
            markerId: MarkerId('point_$i'),
            position: points[i],
            infoWindow: InfoWindow(title: 'Point $i'),
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

    if (controller.mapController != null) {
      final bounds = _getBounds(points);
      controller.mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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
            CustomAppbar.cusAppBarWidget(
              widget.routeData.routeName,
              10,
              context,
              () {
                Get.back();
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: GetBuilder<RouteDetailsController>(
                builder: (controller) {
                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: controller.initialCameraPosition,
                        onMapCreated: (GoogleMapController mapController) {
                          controller.mapController = mapController;
                        },
                        polylines: polylineSet,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: controller.markers,
                        zoomControlsEnabled: false,
                      ),

                      if (widget.routeType == UrlConstants.routeProcessing &&
                          CommonUtils.getUserRole() == UrlConstants.SURVEYOR)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 10),
                            padding: const EdgeInsets.all(8),
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => Expanded(
                                    child:
                                        controller.dogTypeList.value.isEmpty
                                            ? ListView.builder(
                                              itemCount: 8,
                                              // Number of shimmer placeholders
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                      ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CommonShimmer(
                                                      width: 50,
                                                      height: 70,
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                            : ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                                  controller
                                                      .dogTypeList
                                                      .value
                                                      .length,
                                              itemBuilder: (context, index) {
                                                final markerData =
                                                    controller
                                                        .dogTypeList
                                                        .value[index];
                                                return GestureDetector(
                                                  onTap: () async {
                                                    if (controller
                                                        .trackingStart
                                                        .value) {
                                                      if (controller
                                                              .currentLocation !=
                                                          null) {
                                                        final LatLng
                                                        currentLatLng = LatLng(
                                                          controller
                                                              .currentLocation!
                                                              .latitude!,
                                                          controller
                                                              .currentLocation!
                                                              .longitude!,
                                                        );

                                                        if (controller
                                                            .isLocationNearPolyline()) {
                                                          final icon = await controller
                                                              .loadIconFromUrl(
                                                                markerData
                                                                        .imagePath ??
                                                                    "",
                                                              );

                                                          final marker = Marker(
                                                            markerId: MarkerId(
                                                              "marker_${controller.markers.length}",
                                                            ),
                                                            position:
                                                                currentLatLng,
                                                            icon: icon,
                                                            infoWindow:
                                                                InfoWindow(
                                                                  title:
                                                                      markerData
                                                                          .name,
                                                                ),
                                                          );

                                                          controller.markers
                                                              .add(marker);
                                                          controller.update();
                                                        } else {
                                                          CommonUtils.buildSnackBar(
                                                            "You're not within 50 meters of the route.",
                                                            "Warning",
                                                            AppColors.orange,
                                                            2,
                                                          );
                                                        }
                                                      } else {
                                                        CommonUtils.buildSnackBar(
                                                          "Current location not found.",
                                                          "Warning",
                                                          AppColors.orange,
                                                          2,
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                        ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            markerData
                                                                .imagePath ??
                                                            "",
                                                        height: 70,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                CommonShimmer(
                                                                  width: 40,
                                                                  height: 40,
                                                                ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if ((CommonUtils.getCurrentUser()?.ownership ??
                                        0) ==
                                    1)
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(AddDogOwnerPage());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 6,
                                      ),
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
                                if ((CommonUtils.getCurrentUser()?.ownership ??
                                        0) ==
                                    1)
                                  Text(
                                    "Ownership",
                                    style: FontHelper.regular(
                                      color: AppColors.black,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            widget.routeType != UrlConstants.routeComplete &&
                    CommonUtils.getUserRole() == UrlConstants.SURVEYOR
                ? Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        controller.isCheckingTime.value
                            ? const Center(child: CircularProgressIndicator())
                            : CustomFormButton(
                              innerText:
                                  controller.trackingStart.value
                                      ? "Stop Route"
                                      : "Start Route",
                              onPressed: () async {
                                String formattedTime = DateFormat(
                                  'yyyy-MM-dd HH:mm:ss',
                                ).format(DateTime.now());

                                if (widget.routeType ==
                                    UrlConstants.routeProcessing) {
                                  if (controller.trackingStart.value) {
                                    // Stop Route
                                    await controller.checkRouteTime(
                                      UrlConstants.routeFlagEnd,
                                      widget.routeData.routeId,
                                      UrlConstants.routeProcessing,
                                      endTime: formattedTime,
                                    );

                                    // After stopping, navigate to DogCaughtScreen
                                    if (!controller.trackingStart.value) {
                                      Get.to(
                                        () => DogCaughtScreen(
                                          routeData: widget.routeData,
                                          markers: controller.markers,
                                          polylines: controller.polylines,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Start Route
                                    if (widget.routeData.startDate.isEmpty) {
                                      CommonUtils.buildSnackBar(
                                        "Start DateTime not set for this route.",
                                        "Warning",
                                        AppColors.orange,
                                        5,
                                      );
                                    } else if (controller
                                        .isLocationNearPolyline()) {
                                      await controller.checkRouteTime(
                                        UrlConstants.routeFlagStart,
                                        widget.routeData.routeId,
                                        UrlConstants.routeProcessing,
                                        startTime: formattedTime,
                                      );
                                      controller.startRouteTracking();
                                    } else {
                                      CommonUtils.buildSnackBar(
                                        "You're not within 50 meters of the route, So You cannot start the route.",
                                        "Warning",
                                        AppColors.orange,
                                        2,
                                      );
                                    }
                                  }
                                } else if (widget.routeType ==
                                    UrlConstants.routePending) {
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
                )
                : SizedBox(),
          ],
        ),
      ),
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
