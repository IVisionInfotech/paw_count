import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/login_cotroller.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class SelectProjectScreen extends StatefulWidget {
  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Close
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Select Project",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Select State",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value:
                      controller.selectedStateId.value != 0
                          ? controller.selectedStateId.value
                          : null,
                  items:
                      controller.stateList.map((state) {
                        return DropdownMenuItem<int>(
                          value: state.locationId,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              state.locationName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedStateId.value = val;
                      controller.selectedCityId.value = 0;
                    }
                  },
                ),
                SizedBox(height: 16),

                if (controller.userModel!.role != UrlConstants.STATE_ADMIN)
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: "Select City",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value:
                        controller.selectedCityId.value != 0
                            ? controller.selectedCityId.value
                            : null,
                    items:
                        controller.cityList.map((city) {
                          return DropdownMenuItem<int>(
                            value: city.locationId,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                city.locationName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedCityId.value = val;
                      }
                    },
                  ),

                SizedBox(height: 24),

                Center(
                  child: Obx(() {
                    return controller.isLoadingProject.value
                        ? const CircularProgressIndicator()
                        : CustomFormButton(
                          innerText: "Continue",
                          onPressed: () async {
                            controller.isLoadingProject.value = true;
                            bool result = await controller.onSubmitProject();
                            controller.isLoadingProject.value = false;

                            if (!result) {
                              Get.snackbar(
                                "Error",
                                controller.errorMessage.value,
                              );
                            } else {
                              Get.back();
                            }
                          },
                        );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
