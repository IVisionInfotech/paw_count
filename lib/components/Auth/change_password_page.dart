import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../cotroller/ChangePasswordController.dart';
import '../common/custom_appbar.dart';
import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController controller = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar.cusAppBarWidget('Change Password', 20, context, () {
              Get.back();
            }),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Form(
                        key: controller.formKey,
                        child: ListView(
                          children: [
                            Obx(
                                  () => CustomInputField(
                                controller: controller.oldPasswordController,
                                labelText: 'Old Password',
                                hintText: 'Enter old password',
                                obscureText: controller.obscureOld.value,
                                suffixIcon: true,
                                validator: (value) =>
                                value == null || value.isEmpty ? 'Old password is required' : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                                  () => CustomInputField(
                                controller: controller.newPasswordController,
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                                obscureText: controller.obscureNew.value,
                                suffixIcon: true,
                                validator: (value) =>
                                value == null || value.isEmpty ? 'New password is required' : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                                  () => CustomInputField(
                                controller: controller.confirmPasswordController,
                                labelText: 'Confirm Password',
                                hintText: 'Re-enter new password',
                                obscureText: controller.obscureConfirm.value,
                                suffixIcon: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm password is required';
                                  } else if (value != controller.newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                          () => controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : CustomFormButton(
                        innerText: 'Update Password',
                        onPressed: controller.changePassword,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
