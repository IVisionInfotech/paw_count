import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/city_border_screen.dart';
import 'package:survey_dogapp/components/MapsScreen/cotroller/city_border_controller.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class ViewcityBorderScreen extends StatefulWidget {
  final String cityName;
  final List<LatLng> savedBorder;
  final int cityId;
  final bool isCreated;

  ViewcityBorderScreen({
    super.key,
    required this.cityName,
    required this.savedBorder,
    required this.cityId,
    required this.isCreated,
  });

  @override
  _ViewcityBorderScreenState createState() => _ViewcityBorderScreenState();
}

class _ViewcityBorderScreenState extends State<ViewcityBorderScreen> {
  late final CityBorderController controller;

  @override
  void initState() {
    widget.isCreated == true
        ? controller = Get.put(CityBorderController())
        : controller = Get.find();
    super.initState();
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
                    "View ${widget.cityName} Border",
                    style: FontHelper.semiBold(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const SizedBox(height: 5),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                  widget.savedBorder.isNotEmpty
                      ? widget.savedBorder.first
                      : LatLng(0.0, 0.0),
                  zoom: 12,
                ),
                polygons: controller.createPolygon(
                  AppColors.purple,
                  AppColors.purple.withOpacity(0.2),
                  widget.savedBorder,
                ),
              ),
            ),
            controller.isLoading.value?
            CircularProgressIndicator(color: AppColors.primary,):
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomFormButton(
                innerText: widget.isCreated ? "Edit" : "Save",
                onPressed: () {
                  DialogHelper.showCommonDialog(
                    context: context,
                    icon: Icons.save_rounded,
                    iconColor: AppColors.primary,
                    title: widget.isCreated ? "Edit" : "Save",
                    subTitle:
                        widget.isCreated ? "Are You Sure?" : "Are You Sure?",
                    negativeText: "No",
                    positiveText: "Yes",
                    onPositivePressed: () async {
                      print("++++++++++++++6 ${widget.savedBorder}");
                      Get.back();
                      widget.isCreated
                          ? Get.off(CityBorderScreen(cityname: widget.cityName, cityId: widget.cityId,isUpdate: true,))
                          : await controller.saveBorderPoints(widget.cityId);
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
