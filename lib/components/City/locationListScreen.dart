import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/City/LocationManagementScreen.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/cotroller/LocationController.dart';
import 'package:survey_dogapp/components/City/databasehelper.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class Locationlistscreen extends StatefulWidget {
  const Locationlistscreen({super.key});

  @override
  State<Locationlistscreen> createState() => _LocationlistscreenState();
}

class _LocationlistscreenState extends State<Locationlistscreen> {
  final LocationController controller =
      Get.isRegistered<LocationController>()
          ? Get.find<LocationController>()
          : Get.put(LocationController());
  bool isListOpen = true;
  bool _isFabVisible = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    controller.clearFields();
    controller.fetchAllLocation();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _isFabVisible) {
        setState(() {
          _isFabVisible = false;
        });
      } else if (_scrollController.offset <= 50 && !_isFabVisible) {
        setState(() {
          _isFabVisible = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(LocationManagementScreen());
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar.cusAppBarWidget("Location List", 20, context, () {
              Get.back();
            }),
            const SizedBox(height: 10),
            Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildDropdown<int>(
                      label: "State",
                      value: controller.selectedStateId.value,
                      items: controller.states,
                      onChanged: (val) => controller.onStateChanged(val!),
                    ),
                    const SizedBox(width: 8),
                    _buildDropdown<int>(
                      label: "City",
                      value: controller.selectedCityId.value,
                      items: controller.cities,
                      onChanged: (val) => controller.onCityChanged(val!),
                    ),
                    const SizedBox(width: 8),
                    _buildDropdown<int>(
                      label: "Zone",
                      value: controller.selectedZoneId.value,
                      items: controller.zones,
                      onChanged: (val) => controller.onZoneChanged(val!),
                    ),
                    const SizedBox(width: 8),
                    _buildDropdown<int>(
                      label: "Ward",
                      value: controller.selectedWardId.value,
                      items: controller.wards,
                      onChanged: (val) => controller.onWardChanged(val!),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    if (controller.selectedStateId.value != null)
                      _buildSelectedFilterBox(
                        label: controller.states.firstWhere((state) => state.locationId == controller.selectedStateId.value).locationName,
                        onClear: () {
                          controller.selectedStateId.value = null;
                          controller.selectedCityId.value = null;
                          controller.selectedZoneId.value = null;
                          controller.selectedWardId.value = null;
                          controller.zones.clear();
                          controller.areas.clear();
                          controller.wards.clear();
                          controller.cities.clear();
                        },
                      ),
                    if (controller.selectedCityId.value != null)
                      _buildSelectedFilterBox(
                        label: controller.cities.firstWhere((city) => city.locationId == controller.selectedCityId.value).locationName,
                        onClear: () {
                          controller.selectedCityId.value = null;
                          controller.selectedZoneId.value = null;
                          controller.selectedWardId.value = null;
                          controller.zones.clear();
                          controller.areas.clear();
                          controller.wards.clear();
                        },
                      ),
                    if (controller.selectedZoneId.value != null)
                      _buildSelectedFilterBox(
                        label: controller.zones.firstWhere((zone) => zone.locationId == controller.selectedZoneId.value).locationName,
                        onClear: () {
                          controller.selectedZoneId.value = null;
                          controller.selectedWardId.value = null;
                          controller.wards.clear();
                          controller.areas.clear();
                        },
                      ),
                    if (controller.selectedWardId.value != null)
                      _buildSelectedFilterBox(
                        label: controller.wards.firstWhere((wards) => wards.locationId == controller.selectedWardId.value).locationName,
                        onClear: () {
                          controller.selectedWardId.value = null;
                          controller.areas.clear();
                        },
                      ),
                  ],
                ),
              );
            }),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.white,
                displacement: 50,
                onRefresh: () async {
                  controller.clearFields();
                  controller.fetchAllLocation();
                },
                child: Obx(() {
                  List<LocationModel> filteredList = [];
                  if (controller.selectedWardId.value != null) {
                    filteredList = controller.areas;
                  } else if (controller.selectedZoneId.value != null) {
                    filteredList = controller.wards;
                  } else if (controller.selectedCityId.value != null) {
                    filteredList = controller.zones;
                  } else if (controller.selectedStateId.value != null) {
                    filteredList = controller.cities;
                  } else {
                    filteredList = controller.states;
                  }

                  if (filteredList.isEmpty && controller.isLoading.value){
                    return ListShimmerItem(count: 9);
                  }
                  if (filteredList.isEmpty && !controller.isLoading.value) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: Text("No data to display."),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        elevation: 3,
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                child: controller.getLocationIcon(item.locationType),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.locationName,
                                      style: FontHelper.semiBold(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.category, size: 16, color: AppColors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.locationType,
                                          style: FontHelper.regular(
                                            fontSize: 14,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () async {
                                      showEditLocationDialog(item);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      DialogHelper.showCommonDialog(
                                        context: context,
                                        title: "Confirm Delete",
                                        subTitle: "Are you sure you want to delete this location?",
                                        onPositivePressed: () async {
                                          Get.back();
                                          await controller.deleteLocation(
                                            locationId: item.locationId,
                                            locationType: item.locationType,
                                            parentId: item.parentId,
                                          );
                                        },
                                        negativeText: "No",
                                        positiveText: "Yes",
                                        iconColor: AppColors.red,
                                        icon: CupertinoIcons.delete,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<LocationModel> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontHelper.semiBold(fontSize: 17, color: AppColors.black),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<T>(
            value: value,
            style: FontHelper.regular(color: AppColors.black, fontSize: 15),
            hint: Text(
              'Select $label',
              style: FontHelper.regular(fontSize: 15, color: AppColors.grey),
            ),
            underline: const SizedBox(),
            isDense: true,
            onChanged: onChanged,
            items:
                items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item.locationId as T,
                    child: Text(item.locationName),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFilterBox({
    required String label,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: FontHelper.regular(fontSize: 15, color: AppColors.black),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.red),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  void showEditLocationDialog(LocationModel location) {
    final TextEditingController nameController = TextEditingController(
      text: location.locationName,
    );

    // Pre-fill selected dog types for City
    if (location.locationType == "City") {
      controller.selectedDogTypeIds.clear();
      final ids = controller.getDogTypeIdList(location.dogtypeId);
      controller.selectedDogTypeIds.addAll(ids);
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // Limit height to ~80% of screen height to handle keyboard
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  final selectedTypes = controller.dogTypeList
                      .where((dog) => controller.selectedDogTypeIds.contains(dog.id))
                      .toList();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_location_alt, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            "Edit ${location.locationType}",
                            style: FontHelper.semiBold(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Location Name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (location.locationType == 'City')
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
                      if (location.locationType == 'City')
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedTypes.map((dog) {
                            return Chip(
                              avatar: dog.imagePath != null && dog.imagePath!.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(dog.imagePath!))
                                  : const CircleAvatar(child: Icon(Icons.pets, size: 16)),
                              label: Text(dog.name ?? "Null"),
                              onDeleted: () {
                                controller.selectedDogTypeIds.remove(dog.id);
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              child: Text("Cancel"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                String updatedName = nameController.text.trim();
                                if (updatedName.isEmpty) {
                                  CommonUtils.buildSnackBar("Error", "Location name cannot be empty", AppColors.red, 2);
                                  return;
                                }
                                Get.back();
                                await controller.editLocation(
                                  locationId: location.locationId,
                                  locationName: updatedName,
                                  locationType: location.locationType,
                                  parentId: location.parentId,
                                  dogTypeIds: controller.selectedDogTypeIds.join(','),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                              child: Text("Save", style: FontHelper.bold(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      controller.selectedDogTypeIds.clear();
    });

  }
  void showDogTypeSelectionPopup(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Select Dog Types"),
        content: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                // Limit height to 60% of available height
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Obx(() => Column(
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
            );
          },
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
