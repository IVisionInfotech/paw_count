import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/dog_owner_list_shimmer_item.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/Staffdog_controller.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';

class StaffDogScreen extends StatefulWidget {
  final User user;

  const StaffDogScreen({super.key, required this.user});

  @override
  State<StaffDogScreen> createState() => _StaffDogScreenState();
}

class _StaffDogScreenState extends State<StaffDogScreen> {
  late StaffDogController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StaffDogController(widget.user));
    controller.dogTypeFetch();
    controller.staffDogFetch();
  }

  Future<void> _onRefresh() async {
    await controller.staffDogFetch();
    await controller.dogTypeFetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar.cusAppBarWidget(
              'Associates Dog List',
              20,
              context,
                  () => Get.back(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.background,
                  child: controller.isShimmerLoading.value
                      ? ListShimmerItem()
                      : controller.staffDogList.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: Text(
                            'No Dog available.',
                            style: TextStyle(color: AppColors.lightGrey),
                          ),
                        ),
                      ),
                    ],
                  ) : Column(
                    children: [
                      _buildFilters(),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount:
                          controller.filteredStaffDogList.length,
                          itemBuilder: (context, index) {
                            final dog =
                            controller.filteredStaffDogList[index];
                            return Card(
                              color: AppColors.white,
                              child: ListTile(
                                leading: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: dog.imgUrl ?? "",
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  ),
                                ),
                                title: Text(dog.dogTypeName ?? ""),
                                subtitle: Text(dog.remark ?? ""),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Obx(
          () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: AppColors.background,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Filters + Clear button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.selectedStartDate.value = null;
                        controller.selectedEndDate.value = null;
                        controller.selectedDogTypes.value = [];
                        controller.filteredStaffDogList
                            .assignAll(controller.staffDogList);
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date filters
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectDate(context, isStart: true),
                        child: Text(
                          controller.selectedStartDate.value != null
                              ? DateFormat('yyyy-MM-dd')
                              .format(controller.selectedStartDate.value!)
                              : 'Start Date',
                          style: TextStyle(
                            color: controller.selectedStartDate.value != null
                                ? AppColors.black
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectDate(context, isStart: false),
                        child: Text(
                          controller.selectedEndDate.value != null
                              ? DateFormat('yyyy-MM-dd')
                              .format(controller.selectedEndDate.value!)
                              : 'End Date',
                          style: TextStyle(
                            color: controller.selectedEndDate.value != null
                                ? AppColors.black
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMultiSelect<DogTypeModel>(
                        label: "Dog Type",
                        items: controller.dogTypeList,
                        selectedItems: controller.selectedDogTypes,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                      tooltip: "Download PDF",
                      onPressed: () async {
                        await controller.fetchReport(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        items: items
            .map((e) {
          final labelText = e is DogTypeModel ? e.name ?? '' : e.toString();
          return MultiSelectItem<T>(e, labelText);
        })
            .toList(),
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
        selectedColor: AppColors.primary,
        checkColor: AppColors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        chipDisplay: MultiSelectChipDisplay<T>(
          textStyle: TextStyle(color: AppColors.white),
          chipColor: AppColors.primary,

        ),
        onConfirm: (val) {
          selectedItems.value = val;
          controller.applyFilters();
        },
        cancelText: Text(
          "Cancel",
          style: TextStyle(color: AppColors.logoutRed),
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

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (isStart) {
        controller.selectedStartDate.value = picked;
      } else {
        controller.selectedEndDate.value = picked;
      }
      controller.applyFilters();
    }
  }
}
