import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:email_validator/email_validator.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/dashboardController.dart';
import 'package:survey_dogapp/cotroller/profileController.dart';
import 'package:survey_dogapp/generated/assets.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController controller =
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());


  @override
  void initState() {
    super.initState();
    controller.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              CustomAppbar.cusAppBarWidget("Edit Profile", 20, context, () {
                Get.back();
              }),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Obx(
                          () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                controller.pickImageDialog();
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: controller.profileLogo.value != null
                                          ? Image.file(
                                        controller.profileLogo.value!,
                                        fit: BoxFit.cover,
                                      )
                                          : controller.profileLogoUri.isNotEmpty
                                          ? CachedNetworkImage(
                                        imageUrl: controller.profileLogoUri.value,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CommonShimmer(
                                          width: 100,
                                          height: 100,
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey.shade300,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                          : Image.asset(
                                        Assets.imagesIcProfilePlaceholder,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            labelText: "Full Name",
                            hintText: "Enter Full Name",
                            controller: controller.nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Full Name';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required!';
                              }
                              if (!EmailValidator.validate(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Mobile Number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                                return 'Enter valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                          CustomInputField(
                            labelText: "Address",
                            hintText: "Enter Address",
                            controller: controller.addressController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ).marginOnly(top: 10),
                    ),
                  ),
                ),
              ),
              Center(
                child: Obx(
                      () => controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : CustomFormButton(
                    innerText: 'Edit Profile',
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        await controller.addUpdateUser();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
