import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/route_tracking_controller.dart';
import 'package:survey_dogapp/components/MapsScreen/route_draw_screen.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class RouterTrackingScreen extends StatefulWidget {
  final int cityId;

  const RouterTrackingScreen({super.key, required this.cityId});
  @override
  _RouterTrackingScreenState createState() => _RouterTrackingScreenState();
}

class _RouterTrackingScreenState extends State<RouterTrackingScreen> {
  final RouteTrackingController controller = Get.put(RouteTrackingController());

  @override
  void initState() {
    print("111111111 ${widget.cityId}");
    controller.fetchCityBorder(widget.cityId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              CustomAppbar.cusAppBarWidget("Route Tracking", 20, context, () {
                Get.back();
              },),
              const SizedBox(height: 5),
              Expanded(
                child: controller.isLoading.value || controller.cityBorderList.value.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.cityBorderList.value.isNotEmpty
                        ? LatLng(controller.cityBorderList.value.first.lat!, controller.cityBorderList.value.first.lng!)
                        : LatLng(23.0225, 72.5714),
                    zoom: 15,
                  ),
                  onMapCreated: controller.onMapCreated,
                  polygons: controller.createPolygon(),
                  polylines: controller.polylines.toSet(),
                  markers: controller.markers.toSet(),
                  myLocationEnabled: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomFormButton(
                  innerText: 'Start Tracking',
                  onPressed: () {
                    _showCreateRouteBottomSheet();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRouteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: ModalRoute.of(context)!.animation!,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: const Offset(0, 0),
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeInOut,
              )),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    // Create on Map Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff1C3D49), Color(0xff233743)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.to(RouteDrawScreen(isManually: false,cityBorder: controller.cityBorderList.map((e) => LatLng(e.lat!, e.lng!)).toList(),));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map,
                                color: AppColors.white,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Create on Map",
                                style: FontHelper.bold(color: AppColors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff1C3D49), Color(0xff233743)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.to(RouteDrawScreen(isManually: true,cityBorder: controller.cityBorderList.map((e) => LatLng(e.lat!, e.lng!)).toList(),));
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.create,
                                color: AppColors.white,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Create Manually",
                                style: FontHelper.bold(color: AppColors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}