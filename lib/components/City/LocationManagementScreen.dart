import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/City/cotroller/LocationController.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/theme.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({Key? key}) : super(key: key);

  @override
  State<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  final LocationController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller.dbHelper.getStates();
    super.initState();
  }

  void clearForm() {
    controller.selectedLocationType.value = '';
    controller.selectedStateId.value = null;
    controller.selectedCityId.value = null;
    controller.selectedZoneId.value = null;
    controller.selectedAreaId.value = null;
    controller.selectedWardId.value = null;

    controller.nameController.clear();

    controller.cities.clear();
    controller.zones.clear();
    controller.areas.clear();
    controller.wards.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clearForm();
        Get.back();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppbar.cusAppBarWidget(
                "Location Management",
                20,
                context,
                    () {
                  clearForm();
                  Get.back();
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        );
                      }

                      final type = controller.selectedLocationType.value;

                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location Type
                            CustomInputField(
                              labelText: "Location Type",
                              hintText: "Select Location Type",
                              isDropdown: true,
                              items: controller.locationTypes,
                              selectedValue: controller.locationTypes.contains(controller.selectedLocationType.value)
                                  ? controller.selectedLocationType.value
                                  : null,
                              onChanged: (val) {
                                controller.selectedLocationType.value = val!;
                                controller.onLocationTypeChange(val);
                              },
                              validator: (val) => val == null || val.isEmpty ? 'Please Select Location Type' : null,
                            ),
                            const SizedBox(height: 16),

                            // State
                            if (["City", "Zone", "Ward", "Area"].contains(type)) ...[
                              CustomInputField(
                                labelText: "State",
                                hintText: "Select State",
                                isDropdown: true,
                                items: controller.states.map((s) => s.locationName).toList(),
                                selectedValue: controller.selectedStateId.value != null
                                    ? controller.states.firstWhere((s) => s.locationId == controller.selectedStateId.value).locationName
                                    : null,
                                onChanged: (val) async {
                                  final selected = controller.states.firstWhereOrNull((s) => s.locationName == val);
                                  if (selected != null) {
                                    await controller.onStateChanged(selected.locationId);
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Please select a State' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // City
                            if (["Zone", "Ward", "Area"].contains(type)) ...[
                              CustomInputField(
                                labelText: "City",
                                hintText: "Select City",
                                isDropdown: true,
                                items: controller.cities.map((s) => s.locationName).toList(),
                                selectedValue: controller.selectedCityId.value != null
                                    ? controller.cities.firstWhere((s) => s.locationId == controller.selectedCityId.value).locationName
                                    : null,
                                onChanged: (val) async {
                                  final selected = controller.cities.firstWhereOrNull((s) => s.locationName == val);
                                  if (selected != null) {
                                    await controller.onCityChanged(selected.locationId);
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Please select a City' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Zone
                            if (["Ward", "Area"].contains(type)) ...[
                              CustomInputField(
                                labelText: "Zone",
                                hintText: "Select Zone",
                                isDropdown: true,
                                items: controller.zones.map((s) => s.locationName).toList(),
                                selectedValue: controller.selectedZoneId.value != null
                                    ? controller.zones.firstWhere((s) => s.locationId == controller.selectedZoneId.value).locationName
                                    : null,
                                onChanged: (val) async {
                                  final selected = controller.zones.firstWhereOrNull((s) => s.locationName == val);
                                  if (selected != null) {
                                    await controller.onZoneChanged(selected.locationId);
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Please select a Zone' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Ward
                            if (["Area"].contains(type)) ...[
                              CustomInputField(
                                labelText: "Ward",
                                hintText: "Select Ward",
                                isDropdown: true,
                                items: controller.wards.map((s) => s.locationName).toList(),
                                selectedValue: controller.selectedWardId.value != null
                                    ? controller.wards.firstWhere((s) => s.locationId == controller.selectedWardId.value).locationName
                                    : null,
                                onChanged: (val) {
                                  final selected = controller.wards.firstWhereOrNull((s) => s.locationName == val);
                                  if (selected != null) {
                                    controller.selectedWardId.value = selected.locationId;
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty ? 'Please select a Ward' : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Name Input
                            if (type.isNotEmpty) ...[
                              CustomInputField(
                                labelText: "Enter $type",
                                hintText: "Enter $type",
                                textCapitalization: TextCapitalization.words,
                                controller: controller.nameController,
                                validator: (value) => value == null || value.isEmpty ? "$type name is required" : null,
                              ),
                              if (type == "City")
                                Obx(
                                      () => CheckboxListTile(
                                    title: const Text("Can you add photo for Dog?"),
                                    value: controller.canAddPhoto.value == 1,
                                    onChanged: (val) {
                                      controller.canAddPhoto.value = (val ?? false) ? 1 : 0;
                                      // Clear selected dog types when checkbox is unchecked
                                      if (!val!) {
                                        controller.selectedDogTypeIds.clear();
                                      }
                                    },
                                  ),
                                ),
                              if (type == "City" && controller.canAddPhoto.value == 1)
                                Obx(() {
                                  final selectedTypes = controller.dogTypeList
                                      .where((dog) => controller.selectedDogTypeIds.contains(dog.id))
                                      .toList();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          showDogTypeSelectionPopup(context);
                                        },
                                        icon: const Icon(Icons.pets),
                                        label: const Text("Select Dog Types"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (selectedTypes.isNotEmpty)
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: selectedTypes.map((dog) {
                                            return Chip(
                                              avatar: dog.imagePath != null && dog.imagePath!.isNotEmpty
                                                  ? CircleAvatar(
                                                backgroundImage: NetworkImage(dog.imagePath!),
                                              )
                                                  : const CircleAvatar(
                                                child: Icon(Icons.pets, size: 16),
                                              ),
                                              label: Text(dog.name ?? "Null"),
                                              onDeleted: () {
                                                controller.selectedDogTypeIds.remove(dog.id);
                                              },
                                              deleteIcon: const Icon(Icons.close),
                                            );
                                          }).toList(),
                                        )
                                      else
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text("No dog types selected"),
                                        ),
                                    ],
                                  );
                                }),
                            ],
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                      () => controller.isLoadingChange.value
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                      : CustomFormButton(
                    innerText: 'Save',
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      if (controller.canAddPhoto.value == 1 &&
                          controller.selectedDogTypeIds.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please select at least one dog type.",
                          backgroundColor: Colors.red.shade400,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      controller.submitLocation();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showDogTypeSelectionPopup(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Select Dog Types"),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView(
            shrinkWrap: true,
            children: controller.dogTypeList.map((dogType) {
              return CheckboxListTile(
                title: Row(
                  children: [
                    if (dogType.imagePath != null && dogType.imagePath!.isNotEmpty)
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: dogType.imagePath!,
                            fit: BoxFit.cover,
                            width: 30,
                            height: 30,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 30,
                                height: 30,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error, size: 20),
                          ),
                        ),
                      ),
                    if (dogType.imagePath != null && dogType.imagePath!.isNotEmpty)
                      const SizedBox(width: 8),
                    Expanded(child: Text(dogType.name ?? "Null")),
                  ],
                ),
                value: controller.selectedDogTypeIds.contains(dogType.id),
                onChanged: (bool? value) {
                  if (value == true) {
                    controller.selectedDogTypeIds.add(dogType.id!);
                  } else {
                    controller.selectedDogTypeIds.remove(dogType.id);
                  }
                },
              );
            }).toList(),
          )),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
