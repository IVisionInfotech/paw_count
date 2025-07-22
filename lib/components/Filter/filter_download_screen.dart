import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/Filter/filter_cotroller.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';

class FilterDownloadScreen extends StatelessWidget {
  final FilterController controller = Get.put(FilterController());

  FilterDownloadScreen({super.key});

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart) {
        controller.selectedStartDate.value = picked;
      } else {
        controller.selectedEndDate.value = picked;
      }
    }
  }

  Widget _buildFilterCard({required String title, required Widget child}) {
    return Card(
      color: AppColors.background,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelect<T>({
    required String label,
    required RxList<T> items,
    required RxList<T> selectedItems,
  }) {
    return Obx(
      () => MultiSelectDialogField<T>(
        items:
            items.map((e) {
              final labelText =
                  e is LocationModel
                      ? e.locationName ?? ''
                      : e is User
                      ? e.name ?? ''
                      : e is DogTypeModel
                      ? e.name ?? ''
                      : e.toString();
              return MultiSelectItem<T>(e, labelText);
            }).toList(),
        title: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        buttonText: Text(
          "Select $label",
          style: TextStyle(color: AppColors.titleText),
        ),
        searchable: true,
        listType: MultiSelectListType.CHIP,
        backgroundColor: AppColors.white,
        unselectedColor: AppColors.greyBg,
        // Light grey background for unselected chips
        selectedColor: AppColors.primary,
        // Your primary color for selected
        checkColor: AppColors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        chipDisplay: MultiSelectChipDisplay<T>(
          textStyle: TextStyle(color: AppColors.white),
          chipColor: AppColors.primary,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.primary,
          ),
        ),
        onConfirm: (val) => selectedItems.value = val,
        cancelText: Text(
          "Cancel",
          style: TextStyle(color: AppColors.logoutRed), // red for cancel
        ),
        confirmText: Text(
          "Ok",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        initialValue: selectedItems,
        selectedItemsTextStyle: TextStyle(color: AppColors.white),
      ),
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
              'Filter & Download PDF',
              20,
              context,
              () => Get.back(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _buildFilterCard(
                    title: "Location Filters",
                    child: Column(
                      children: [
                        _buildMultiSelect(
                          label: "State",
                          items: controller.states,
                          selectedItems: controller.selectedStates,
                        ),
                        const SizedBox(height: 12),
                        _buildMultiSelect(
                          label: "City",
                          items: controller.cities,
                          selectedItems: controller.selectedCities,
                        ),
                        const SizedBox(height: 12),
                        _buildMultiSelect(
                          label: "Zone",
                          items: controller.zones,
                          selectedItems: controller.selectedZones,
                        ),
                        const SizedBox(height: 12),
                        _buildMultiSelect(
                          label: "Ward",
                          items: controller.wards,
                          selectedItems: controller.selectedWards,
                        ),
                        const SizedBox(height: 12),
                        _buildMultiSelect(
                          label: "Area",
                          items: controller.areas,
                          selectedItems: controller.selectedAreas,
                        ),
                      ],
                    ),
                  ),
                  _buildFilterCard(
                    title: "User Filters",
                    child: Column(
                      children: [
                        if (controller.shouldShowAdminDropdown)
                          _buildMultiSelect(
                            label: "Admin",
                            items: controller.adminList,
                            selectedItems: controller.selectedAdmins,
                          ),
                        const SizedBox(height: 12),
                        if (controller.shouldShowSubAdminDropdown)
                          _buildMultiSelect(
                            label: "Subadmin",
                            items: controller.subAdminList,
                            selectedItems: controller.selectedSubadmins,
                          ),
                        const SizedBox(height: 12),
                        if (controller.shouldShowSurveyorDropdown)
                          _buildMultiSelect(
                            label: "Surveyor",
                            items: controller.userList,
                            selectedItems: controller.selectedSurveyors,
                          ),
                      ],
                    ),
                  ),
                  _buildFilterCard(
                    title: "Dog Type Filter",
                    child: _buildMultiSelect(
                      label: "Dog Type",
                      items: controller.dogTypeList,
                      selectedItems: controller.selectedDogTypes,
                    ),
                  ),
                  _buildFilterCard(
                    title: "Date Range",
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _selectDate(context, isStart: true),
                            child: Obx(() {
                              final start = controller.selectedStartDate.value;
                              return start != null ? Text(
                                DateFormat('yyyy-MM-dd').format(start),
                                style: TextStyle(color: AppColors.black),
                              ):Text('Start Date',
                                style: TextStyle(color: AppColors.grey),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                () => _selectDate(context, isStart: false),
                            child: Obx(() {
                              final end = controller.selectedEndDate.value;
                              return end != null
                                  ? Text(
                                    DateFormat('yyyy-MM-dd').format(end),
                                    style: TextStyle(color: AppColors.black),
                                  )
                                  : Text(
                                    'End Date',
                                    style: TextStyle(color: AppColors.grey),
                                  );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    return CustomFormButton(
                      innerText:
                          controller.isLoading.value
                              ? "Downloading..."
                              : "Download PDF",
                      onPressed:
                          controller.isLoading.value
                              ? null
                              : () async {
                                await controller.fetchReport(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Downloaded PDF"),
                                  ),
                                );
                              },
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
