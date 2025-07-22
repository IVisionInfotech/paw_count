import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/MapsScreen/city_border_screen.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/MapsScreen/router_tracking_screen.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/SurveyRouteController.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class SurveyRoutePage extends StatefulWidget {
  RouteDataModel? routes;

  SurveyRoutePage({super.key, this.routes});

  @override
  State<SurveyRoutePage> createState() => _SurveyRoutePageState();
}

class _SurveyRoutePageState extends State<SurveyRoutePage> {
  final SurveyRouteController controller = Get.put(SurveyRouteController());
  var selectedUser;

  @override
  void initState() {
    controller.initCheckCondition(widget.routes);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget(
              "Survey Route Management",
              20,
              context,
              () => Get.back(),
            ),
            Expanded(
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.shouldShowAdmin)
                        Obx(() {
                          final adminNames =
                              controller.adminList
                                  .map((user) => user.name)
                                  .whereType<String>()
                                  .toList();
                          final selectedAdminName =
                              controller.adminList
                                  .firstWhereOrNull(
                                    (user) =>
                                        user.userId ==
                                        controller.selectedAdmin.value,
                                  )
                                  ?.name;
                          final safeAdmin =
                              adminNames.contains(selectedAdminName)
                                  ? selectedAdminName
                                  : null;

                          return CustomInputField(
                            labelText: "Select State Admin",
                            hintText: "Select State Admin",
                            isDropdown: true,
                            items: adminNames,
                            selectedValue: safeAdmin,
                            onChanged: (val) {
                              if (widget.routes == null) {
                                final selectedUser = controller.adminList
                                    .firstWhereOrNull(
                                      (user) => user.name == val,
                                    );
                                if (selectedUser != null) {
                                  controller.selectedAdmin.value =
                                      selectedUser.userId ?? 0;
                                  controller.subAdminList.clear();
                                  controller.selectedSubAdmin.value = 0;
                                  controller.zoneList.clear();
                                  controller.selectedZone.value = '';
                                  controller.areaList.clear();
                                  controller.wardList.clear();
                                  controller.selectedWard.value = '';
                                  controller.selectedArea.value = '';
                                  if (controller.roleType ==
                                      UrlConstants.SUPER_ADMIN) {
                                    controller.loadSubAdminList(
                                      selectedUser.userId.toString(),
                                    );
                                  }
                                } else {
                                  controller.selectedAdmin.value = 0;
                                }
                              }
                            },
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Select Admin'
                                        : null,
                          );
                        }),
                      if (controller.shouldShowSubAdmin)
                        Obx(() {
                          final subAdminNames =
                              controller.subAdminList
                                  .map((user) => user.name)
                                  .whereType<String>()
                                  .toList();
                          final selectedSubAdminName =
                              controller.subAdminList
                                  .firstWhereOrNull(
                                    (user) =>
                                        user.userId ==
                                        controller.selectedSubAdmin.value,
                                  )
                                  ?.name;
                          final safeSubAdmin =
                              subAdminNames.contains(selectedSubAdminName)
                                  ? selectedSubAdminName
                                  : null;

                          return CustomInputField(
                            labelText: "Select City Admin",
                            hintText: "Select City Admin",
                            isDropdown: true,
                            items: subAdminNames,
                            selectedValue: safeSubAdmin,
                            onChanged: (val) async {
                              if (widget.routes == null) {
                              selectedUser = controller.subAdminList
                                  .firstWhereOrNull((user) => user.name == val);
                              if (selectedUser != null) {
                                controller.selectedSubAdmin.value =
                                    selectedUser.userId ?? 0;
                                controller.zoneList.clear();
                                controller.selectedZone.value = '';
                                controller.areaList.clear();
                                controller.wardList.clear();
                                controller.selectedWard.value = '';
                                controller.selectedArea.value = '';
                                controller.fetchZone(
                                  selectedUser.assignCityId!,
                                );
                                controller.selectedSurveyors.clear();
                                controller.surveyorsList.clear();
                                await controller.loadSurveyorList(
                                  selectedUser.userId.toString(),
                                );
                              } else {
                                controller.selectedSubAdmin.value = 0;
                              }
                              }
                            },
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Select Sub Admin'
                                        : null,
                          );
                        }),
                      CustomInputField(
                        labelText: "Route Name",
                        hintText: "Enter route name",
                        controller: controller.routeNameController,
                        readOnly: widget.routes != null,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Route Name is required"
                                    : null,
                      ),
                      Obx(() {
                        final zoneNames =
                            controller.zoneList
                                .map((zone) => zone.locationName)
                                .whereType<String>()
                                .toList();
                        final safeZone =
                            zoneNames.contains(controller.selectedZone.value)
                                ? controller.selectedZone.value
                                : null;

                        return CustomInputField(
                          labelText: "Select Zone",
                          hintText: "Select Zone",
                          isDropdown: true,
                          items: zoneNames,
                          selectedValue:
                              widget.routes == null
                                  ? safeZone
                                  : controller.selectedZone.value,
                          onChanged: (val) {
                            if (widget.routes == null) {
                              final selectedZone = controller.zoneList
                                  .firstWhereOrNull(
                                    (zone) => zone.locationName == val,
                                  );
                              if (selectedZone != null) {
                                controller.selectedZone.value =
                                    selectedZone.locationName ?? '';
                                controller.areaList.clear();
                                controller.wardList.clear();
                                controller.selectedArea.value = '';
                                controller.fetchWard(selectedZone.locationId);
                              } else {
                                controller.selectedZone.value = '';
                              }
                            }
                          },
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Select Zone'
                                      : null,
                        );
                      }),
                      Obx(() {
                        final areaNames =
                            controller.wardList
                                .map((area) => area.locationName)
                                .whereType<String>()
                                .toList();
                        final safeArea =
                            areaNames.contains(controller.selectedWard.value)
                                ? controller.selectedWard.value
                                : null;

                        return CustomInputField(
                          labelText: "Select Ward",
                          hintText: "Select Ward",
                          isDropdown: true,
                          items: areaNames,
                          selectedValue: safeArea,
                          onChanged: (val) {
                            if (widget.routes == null) {
                              controller.selectedWard.value = val ?? '';
                              final selectedWard = controller.wardList
                                  .firstWhereOrNull(
                                    (area) => area.locationName == val,
                                  );
                              if (selectedWard != null) {
                                controller.fetchArea(selectedWard.locationId);
                              }
                            }
                          },

                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Select Ward'
                                      : null,
                        );
                      }),
                      Obx(() {
                        final areaNames =
                            controller.areaList
                                .map((area) => area.locationName)
                                .whereType<String>()
                                .toList();
                        final safeArea =
                            areaNames.contains(controller.selectedArea.value)
                                ? controller.selectedArea.value
                                : null;

                        return CustomInputField(
                          labelText: "Select Area",
                          hintText: "Select Area",
                          isDropdown: true,
                          items: areaNames,
                          selectedValue: safeArea,
                          onChanged:
                              (val) =>
                                  controller.selectedArea.value = val ?? '',
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Select Area'
                                      : null,
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 3,
                        ),
                        child: Text(
                          "Assign Surveyor",
                          style: FontHelper.bold(fontSize: 18),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 3,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Obx(
                              () => MultiSelectDialogField<User>(
                                items:
                                    controller.surveyorsList
                                        .map(
                                          (surveyor) => MultiSelectItem<User>(
                                            surveyor,
                                            surveyor.name ?? "",
                                          ),
                                        )
                                        .toList(),
                                title: Text(
                                  "Assign Surveyor",
                                  style: FontHelper.regular(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                selectedColor: Colors.blue,
                                buttonText: Text(
                                  "Select Surveyor",
                                  style: FontHelper.regular(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                buttonIcon: const Icon(Icons.person_add),
                                searchable: true,
                                initialValue:
                                    controller.selectedSurveyorUsers.toList(),
                                // pre-fill here
                                onConfirm: (values) {
                                  controller.selectedSurveyorUsers.value =
                                      values;
                                  controller.selectedSurveyors.value =
                                      values.map((e) => e.name ?? '').toList();
                                },
                                validator:
                                    (values) =>
                                        values == null || values.isEmpty
                                            ? 'Select at least one surveyor'
                                            : null,
                                dialogWidth: constraints.maxWidth * 0.9,
                                dialogHeight: 400,
                                backgroundColor: AppColors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5,
                        ),
                        child: Text(
                          "Start Date",
                          style: FontHelper.medium(fontSize: 16),
                        ),
                      ),
                      InkWell(
                        onTap: () => pickStartDateTime(context),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Obx(() {
                            final selectedDate =
                                controller.selectedStartDate.value;
                            return Text(
                              selectedDate == null
                                  ? "Select Start Date & Time"
                                  : DateFormat(
                                    'dd-MM-yyyy HH:mm:ss',
                                  ).format(selectedDate),
                              style: FontHelper.regular(
                                fontSize: 16,
                                color:
                                    selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // End Date
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5,
                        ),
                        child: Text(
                          "End Date",
                          style: FontHelper.medium(fontSize: 16),
                        ),
                      ),
                      InkWell(
                        onTap: () => pickEndDateTime(context),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Obx(() {
                            final selectedDate =
                                controller.selectedEndDate.value;
                            return Text(
                              selectedDate == null
                                  ? "Select End Date & Time"
                                  : DateFormat(
                                    'dd-MM-yyyy HH:mm:ss',
                                  ).format(selectedDate),
                              style: FontHelper.regular(
                                fontSize: 16,
                                color:
                                    selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                              ),
                            );
                          }),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomInputField(
                              labelText: "Route Coordinates",
                              hintText: "Enter coordinates",
                              readOnly: true,
                              controller: controller.coordinatesController,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? "Route Coordinates are required"
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () async {
                              if (widget.routes == null) {
                                if (controller
                                    .selectedSurveyorUsers
                                    .isNotEmpty) {
                                  await controller.fetchCityBorder(
                                    selectedUser == null
                                        ? CommonUtils.getCurrentUser()!
                                            .assignCityId!
                                        : selectedUser.assignCityId!,
                                  );
                                  if (controller.cityBorderList.isNotEmpty) {
                                    final result = await Get.to(
                                      () => RouterTrackingScreen(
                                        cityId:
                                            selectedUser == null
                                                ? CommonUtils.getCurrentUser()!
                                                    .assignCityId!
                                                : selectedUser.assignCityId!,
                                      ),
                                    );

                                    if (result != null && result is Map) {
                                      final points = result['points'];
                                      final reallocation =
                                          result['reallocation'];

                                      if (points is List<LatLng>) {
                                        final formatted = points
                                            .map(
                                              (latLng) =>
                                                  '(${latLng.latitude}, ${latLng.longitude})',
                                            )
                                            .join(', ');
                                        controller.coordinatesController.text =
                                            formatted;

                                        controller.routeCoordinates.value =
                                            points;

                                        controller.routeConfirm.value =
                                            reallocation == 1;
                                      } else {
                                        print(
                                          "Returned points are not a valid List<LatLng>",
                                        );
                                      }
                                    } else {
                                      print(
                                        "No route selected or returned data is not valid.",
                                      );
                                    }
                                  } else {
                                    LocationModel? location =
                                        await DatabaseHelper().getLocationById(
                                          selectedUser == null
                                              ? CommonUtils.getCurrentUser()!
                                                  .assignCityId!
                                              : selectedUser.assignCityId!,
                                        );
                                    final cityName = location!.locationName;
                                    Get.to(
                                      CityBorderScreen(
                                        cityname: cityName,
                                        cityId:
                                            selectedUser == null
                                                ? CommonUtils.getCurrentUser()!
                                                    .assignCityId!
                                                : selectedUser.assignCityId!,
                                        isUpdate: false,
                                      ),
                                    );
                                  }
                                } else {
                                  CommonUtils.buildSnackBar(
                                    'Please Select City Admin',
                                    "Error",
                                    Colors.red,
                                    2,
                                  );
                                }
                              } else {
                                CommonUtils.buildSnackBar(
                                  'You Can Update Route',
                                  "Waring",
                                  AppColors.orange,
                                  2,
                                );
                              }
                            },
                            icon: const Icon(Icons.map),
                            tooltip: "Pick from map",
                          ),
                        ],
                      ),
                      Obx(
                        () => CheckboxListTile(
                          title: const Text("Allow Reallocation"),
                          value: controller.allowReallocation.value,
                          onChanged:
                              widget.routes != null
                                  ? null
                                  : (val) {
                                    controller.allowReallocation.value =
                                        val ?? false;
                                  },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Obx(
                () =>
                    controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : CustomFormButton(
                          innerText:
                              widget.routes != null
                                  ? "Update Route"
                                  : "Submit Route",
                          onPressed: handleSubmit,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleSubmit() async {
    final selectedZone = controller.zoneList.firstWhereOrNull(
      (zone) => zone.locationName == controller.selectedZone.value,
    );

    final selectedArea = controller.areaList.firstWhereOrNull(
      (area) => area.locationName == controller.selectedArea.value,
    );

    final selectedWard = controller.wardList.firstWhereOrNull(
      (ward) => ward.locationName == controller.selectedWard.value,
    );

    if (!controller.isLoading.value && controller.validateDateFields()) {
      String cityId = '';
      var subAdminId;

      if (controller.roleType == UrlConstants.SUB_ADMIN) {
        cityId = CommonUtils.getCurrentUser()?.assignCityId?.toString() ?? '';
        subAdminId = CommonUtils.getUserId();
      } else if (widget.routes == null) {
        cityId = selectedUser.assignCityId?.toString() ?? '';
        subAdminId = controller.selectedSubAdmin.value;
      }

      if (widget.routes != null) {
        await controller.submitRoute(
          cityId,
          selectedZone?.locationId.toString() ?? '',
          selectedArea?.locationId.toString() ?? '',
          selectedWard?.locationId.toString() ?? '',
          subAdminId,
          "Update",
          routeId: widget.routes!.routeId,
        );
        controller.zoneList.clear();
        controller.clearForm();
      } else {
        await controller.submitRoute(
          cityId,
          selectedZone?.locationId.toString() ?? '',
          selectedArea?.locationId.toString() ?? '',
          selectedWard?.locationId.toString() ?? '',
          subAdminId,
          "Create",
        );
      }
    }
  }

  Future<void> pickStartDateTime(BuildContext context) async {
    final now = DateTime.now();
    controller.selectedStartDate.value = now;
    controller.startDateController.text = DateFormat(
      'dd-MM-yyyy HH:mm:ss',
    ).format(now);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedStartDate.value,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          controller.selectedStartDate.value ?? now,
        ),
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selected.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Start Date & Time must be in the future"),
            ),
          );
          return;
        }

        controller.selectedStartDate.value = selected;
        controller.startDateController.text = DateFormat(
          'dd-MM-yyyy HH:mm:ss',
        ).format(selected);

        if (controller.selectedEndDate.value != null &&
            controller.selectedEndDate.value!.isBefore(selected)) {
          controller.selectedEndDate.value = null;
          controller.endDateController.clear();
        }
      }
    }
  }

  Future<void> pickEndDateTime(BuildContext context) async {
    final startDate = controller.selectedStartDate.value;
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Start Date & Time first")),
      );
      return;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate.add(const Duration(minutes: 1)),
      firstDate: startDate.add(const Duration(minutes: 1)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          startDate.add(const Duration(minutes: 1)),
        ),
      );

      if (pickedTime != null) {
        final selected = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selected.isBefore(startDate.add(const Duration(minutes: 1)))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("End Date & Time must be after Start Date & Time"),
            ),
          );
          return;
        }

        controller.selectedEndDate.value = selected;
        controller.endDateController.text = DateFormat(
          'dd-MM-yyyy HH:mm:ss',
        ).format(selected);
      }
    }
  }
}
