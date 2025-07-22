import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:survey_dogapp/components/MapsScreen/city_border_screen.dart';
import 'package:survey_dogapp/components/MapsScreen/viewcity_border_screen.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/userController.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class CreateUser extends StatefulWidget {
  final User? user;

  const CreateUser({super.key, this.user});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final UserController controller =
      Get.isRegistered<UserController>()
          ? Get.find<UserController>()
          : Get.put(UserController());
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.clearInputs();
    controller.filterRoles();
    if (widget.user != null) {
      controller.fillUserDetails(widget.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 100;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget(
              widget.user != null ? "Edit Profile" : "Create User",
              20,
              context,
              () {
                Get.back();
              },
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Obx(() {
                              return GestureDetector(
                                onTap: () {
                                  controller.pickImageDialog();
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: imageSize,
                                      height: imageSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey.shade300,
                                        child:
                                            controller.profileLogo.value == null
                                                ? controller
                                                        .profileLogoUri
                                                        .isEmpty
                                                    ? Image.asset(
                                                      Assets
                                                          .imagesIcProfilePlaceholder,
                                                      fit: BoxFit.fill,
                                                    )
                                                    : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            50,
                                                          ),
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            controller
                                                                .profileLogoUri
                                                                .value,
                                                        width: double.infinity,
                                                        height: imageSize,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => CommonShimmer(
                                                              width:
                                                                  double.infinity,
                                                              height: imageSize,
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Container(
                                                              width:
                                                                  double.infinity,
                                                              height: imageSize,
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: const Icon(
                                                                Icons.error,
                                                                color: AppColors.red,
                                                              ),
                                                            ),
                                                      ),
                                                    )
                                                : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Image.file(
                                                    controller.profileLogo.value!,
                                                    width: double.infinity,
                                                    height: imageSize,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    if (controller
                                        .profileLogoUri
                                        .value
                                        .isNotEmpty)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors
                                                    .blue, // background for edit icon
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 15,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          Obx(() {
                            final roles = controller.filteredRoles;
                            return roles.isEmpty
                                ? const CircularProgressIndicator()
                                : CustomInputField(
                                  labelText: "Select Role",
                                  hintText: "Select Role",
                                  isDropdown: true,
                                  readOnly: widget.user == null,
                                  items: roles,
                                  selectedValue:
                                      roles.contains(controller.selectedRole.value,)
                                          ? controller.selectedRole.value
                                          : null,
                                  onChanged: (value) {
                                    controller.selectedRole.value = value!;
                                    controller.ownership.value = 0;
                                    if (controller.selectedRole.value ==  UrlConstants.STATE_ADMIN) {
                                      controller.fetchStates();
                                    } else if (controller.selectedRole.value ==  UrlConstants.CITY_ADMIN) {
                                      controller.fetchCities(
                                        CommonUtils.getUserStateId()!.toInt(),
                                      );
                                      controller.loadAdminList(widget.user);
                                    } else if (controller.selectedRole.value ==  UrlConstants.SURVEYOR) {
                                      if (controller.roleType ==  UrlConstants.SUPER_ADMIN) {
                                        controller.loadAdminList(widget.user);
                                      } else if (controller.roleType ==  UrlConstants.ADMIN) {
                                        controller.loadSubAdminList(
                                          CommonUtils.getUserId().toString(),
                                          widget.user
                                        );
                                      }
                                    }
                                  },
                                  validator:
                                      (val) =>
                                          val == null || val.isEmpty
                                              ? 'Select Role'
                                              : null,
                                );
                          }),
                          CustomInputField(
                            labelText: "Full Name",
                            hintText: "Enter Full Name",
                            controller: controller.nameController,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Enter Full Name'
                                        : null,
                          ),
                          CustomInputField(
                            labelText: "Email",
                            hintText: "Enter Email Id",
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z0-9@._-]"),
                              ),
                            ],
                            validator: (textValue) {
                              if (textValue == null || textValue.isEmpty) {
                                return 'Email is required!';
                              }
                              if (!EmailValidator.validate(textValue)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          CustomInputField(
                            labelText: "Password",
                            hintText: "Enter Password",
                            controller: controller.passwordController,
                            obscureText: true,
                            suffixIcon: true,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Enter Password'
                                        : null,
                          ),
                          CustomInputField(
                            labelText: "Mobile Number",
                            hintText: "Enter Mobile Number",
                            controller: controller.contactController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (val) {
                              if (val == null || val.isEmpty)
                                return 'Enter Mobile Number';
                              if (!RegExp(r'^\d{10}$').hasMatch(val))
                                return 'Enter valid 10-digit mobile number';
                              return null;
                            },
                          ),
                          CustomInputField(
                            labelText: "Address",
                            hintText: "Enter Address",
                            controller: controller.addressController,
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Enter Address'
                                        : null,
                          ),

                          if (controller.selectedRole.value == UrlConstants.STATE_ADMIN)
                            Obx(
                              () => CustomInputField(
                                labelText: "Select State",
                                hintText: "Select State",
                                isDropdown: true,
                                items:
                                    controller.stateList
                                        .map((e) => e.locationName)
                                        .toList(),
                                selectedValue:
                                    controller.stateList.isNotEmpty
                                        ? controller.stateList
                                            .firstWhereOrNull(
                                              (e) =>
                                                  e.locationId ==
                                                  controller.selectedState.value,
                                            )
                                            ?.locationName
                                        : null,
                                onChanged: (val) {
                                  controller.selectedState.value =
                                      controller.stateList
                                          .firstWhereOrNull(
                                            (e) => e.locationName == val,
                                          )
                                          ?.locationId ??
                                      0;
                                },
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Select State'
                                            : null,
                              ),
                            ),

                          if (controller.shouldShowAdminDropdown)
                            Obx(
                              () => CustomInputField(
                                labelText: "Select State Admin",
                                hintText: "Select State Admin",
                                isDropdown: true,
                                readOnly: widget.user == null,
                                items:
                                    controller.adminList
                                        .map((user) => user.name)
                                        .whereType<String>()
                                        .toList(),
                                selectedValue:
                                    controller.adminList.isNotEmpty
                                        ? controller.adminList
                                            .firstWhereOrNull(
                                              (user) =>
                                                  user.userId ==
                                                  controller.selectedAdmin.value,
                                            )
                                            ?.name
                                        : null,
                                onChanged: (val) {
                                  final selectedUser = controller.adminList
                                      .firstWhereOrNull(
                                        (user) => user.name == val,
                                      );
                                  if (selectedUser != null) {
                                    controller.selectedAdmin.value =
                                        selectedUser.userId ?? 0;
                                    controller.fetchCities(selectedUser.stateId!);
                                    if (controller.roleType ==
                                        UrlConstants.SUPER_ADMIN) {
                                      controller.loadSubAdminList(
                                        controller.selectedAdmin.value.toString(),
                                        widget.user
                                      );
                                    }
                                  } else {
                                    controller.selectedAdmin.value = 0;
                                  }
                                },
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Select Admin'
                                            : null,
                              ),
                            ),

                          if (controller.shouldShowSubAdminDropdown)
                            Obx(
                              () => CustomInputField(
                                labelText: "Select City Admin",
                                hintText: "Select City Admin",
                                isDropdown: true,
                                readOnly: widget.user == null,
                                items:
                                    controller.subAdminList
                                        .map((user) => user.name)
                                        .whereType<String>()
                                        .toList(),
                                selectedValue:
                                    controller.subAdminList.isNotEmpty
                                        ? controller.subAdminList
                                            .firstWhereOrNull(
                                              (user) =>
                                                  user.userId ==
                                                  controller
                                                      .selectedSubAdmin
                                                      .value,
                                            )
                                            ?.name
                                        : null,
                                onChanged: (val) {
                                  controller.selectedSubAdmin.value =
                                      controller.subAdminList
                                          .firstWhereOrNull(
                                            (user) => user.name == val,
                                          )
                                          ?.userId ??
                                      0;
                                },
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Select Sub Admin'
                                            : null,
                              ),
                            ),

                          if (controller.shouldShowSubAdmin)
                            CustomInputField(
                              labelText: "Ownership",
                              hintText: "Select Ownership",
                              isDropdown: true,
                              items:
                                  UrlConstants.ownershipOptions
                                      .map((e) => e['type'] as String)
                                      .toList(),
                              selectedValue:
                                  UrlConstants.ownershipOptions.firstWhere(
                                    (o) => o['id'] == controller.ownership.value,
                                    orElse: () => {'type': null},
                                  )['type'],
                              onChanged: (value) {
                                final selected = UrlConstants.ownershipOptions
                                    .firstWhere(
                                      (o) => o['type'] == value,
                                      orElse: () => {'id': 0},
                                    );
                                controller.ownership.value = selected['id'] ?? 0;
                              },
                              validator:
                                  (val) =>
                                      val == null || val.isEmpty
                                          ? 'Select Ownership'
                                          : null,
                            ),

                          if (controller.shouldShowSubAdmin)
                            Obx(
                              () => CustomInputField(
                                labelText: "Assigned City",
                                hintText: "Select City",
                                isDropdown: true,
                                items:
                                    controller.cityList
                                        .map((city) => city.locationName)
                                        .toList(),
                                selectedValue:
                                    controller.cityList.isNotEmpty
                                        ? controller.cityList
                                            .firstWhereOrNull(
                                              (city) =>
                                                  city.locationId ==
                                                  controller.selectedCity.value,
                                            )
                                            ?.locationName
                                        : null,
                                onChanged: (value) {
                                  controller.selectedCity.value =
                                      controller.cityList
                                          .firstWhereOrNull(
                                            (city) => city.locationName == value,
                                          )
                                          ?.locationId ??
                                      0;
                                },
                                validator:
                                    (val) =>
                                        val == null || val.isEmpty
                                            ? 'Select City'
                                            : null,
                              ),
                            ),

                          if (controller.shouldShowSubAdmin)
                            Obx(
                              () => CheckboxListTile(
                                title: const Text("Can change zone border?"),
                                value: controller.canChangeBorder.value == 1,
                                onChanged: (val) {
                                  controller.canChangeBorder.value =
                                      (val ?? false) ? 1 : 0;
                                },
                              ),
                            ),

                          if (controller.shouldShowSubAdmin)
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary, // Set your custom primary color
                                ),
                                onPressed: () async {
                                  if (controller.selectedCity.value == 0) {
                                    CommonUtils.buildSnackBar(
                                      "Please select a city before proceeding to the map.",
                                      "City Required",
                                      Colors.red,
                                      2,
                                    );
                                  } else {
                                    final selectedCity = controller.cityList
                                        .firstWhereOrNull(
                                          (city) =>
                                              city.locationId ==
                                              controller.selectedCity.value,
                                        );
                                    bool hasBorder = await controller
                                        .fetchCityBOrder(
                                          controller.selectedCity.value,
                                        );
                                    if (hasBorder) {
                                      Get.to(
                                        ViewcityBorderScreen(
                                          cityName:
                                              selectedCity?.locationName ?? '',
                                          savedBorder:
                                              controller.cityBorderList
                                                  .where(
                                                    (e) =>
                                                        e.lat != null &&
                                                        e.lng != null,
                                                  )
                                                  .map(
                                                    (e) => LatLng(e.lat!, e.lng!),
                                                  )
                                                  .toList(),
                                          cityId: controller.selectedCity.value,
                                          isCreated: true,
                                        ),
                                      );
                                    } else {
                                      Get.to(
                                        CityBorderScreen(
                                          isUpdate: false,
                                          cityname:
                                              selectedCity?.locationName ?? '',
                                          cityId: selectedCity!.locationId,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Text("Go to Map",style: FontHelper.medium(color: AppColors.white,fontSize: 13),),
                              ),
                            ),
                        ],
                      ).marginOnly(top: 10),
                    ),
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
                          innerText: widget.user != null ? "Update" : "Create",
                          onPressed: () async {
                            if (_formKey.currentState?.validate() == true) {
                              int userId = widget.user?.userId ?? 0;
                              await controller.addUpdateUser(userId);
                            }
                          },
                        ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
