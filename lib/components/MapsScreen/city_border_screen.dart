import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/city_border_controller.dart';
import 'package:survey_dogapp/components/MapsScreen/viewcity_border_screen.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';

class CityBorderScreen extends StatefulWidget {
  final String cityname;
  final int cityId;
  final bool isUpdate;

  const CityBorderScreen({
    super.key,
    required this.cityname,
    required this.cityId,
    required this.isUpdate,
  });

  @override
  _CityBorderScreenState createState() => _CityBorderScreenState();
}

class _CityBorderScreenState extends State<CityBorderScreen> {
  late final CityBorderController controller;

  @override
  void initState() {
    widget.isUpdate
        ? controller = Get.find()
        : controller = Get.put(CityBorderController());
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
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
                    onPressed: () {
                      Get.back();
                    },
                    iconSize: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Draw Border",
                    style: FontHelper.semiBold(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white),
                    onPressed: () {
                      controller.undoLastPoint();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo, color: Colors.white),
                    onPressed: () {
                      controller.redoLastPoint();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      controller.clearPoints(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Obx(
                () => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: controller.cameraTarget.value,
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController mapCtrl) async {
                    controller.onMapCreated(mapCtrl);
                    await controller.setCityCameraPosition(
                      widget.cityname,
                    ); // Move it here
                  },

                  onTap: controller.addPoint,
                  polylines: controller.createPolyline(),
                  polygons: controller.createPolygon(
                    Colors.green,
                    AppColors.green.withOpacity(0.2),
                    controller.borderPoints,
                  ),
                ),
              ),
            ),
            controller.isLoading.value?
                CircularProgressIndicator(color: AppColors.primary,):
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomFormButton(
                innerText: widget.isUpdate ?"Save Border":"View Border",
                onPressed: () async {
                  if (controller.borderPoints.isNotEmpty) {
                    widget.isUpdate
                        ?await controller.updateBorderPoints(widget.cityId)
                        : Get.to(
                      ViewcityBorderScreen(
                        isCreated: false,
                        cityName: widget.cityname,
                        savedBorder: controller.borderPoints,
                        cityId: widget.cityId,
                      ),
                    );
                  } else {
                    CommonUtils.buildSnackBar(
                      "Border is Empty",
                      "Warning",
                      Colors.red,
                      2,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
