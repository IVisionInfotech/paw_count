import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/forget_password_controller.dart';
import 'package:survey_dogapp/utils/Common.dart';
import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';

class ForgetPasswordPage extends StatefulWidget {
  final String? title;

  ForgetPasswordPage({Key? key, this.title}) : super(key: key);

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  late final ForgetPasswordController controller;
  String appTitle = 'Forgot Password';

  final TextEditingController emailController = TextEditingController();
  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool isFirstFocusDone = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ForgetPasswordController(widget.title!));

    if (widget.title == 'register_device') {
      appTitle = 'UnRegister Device';
    }

    emailController.addListener(() {
      if (controller.isOtpSent.value) {
        controller.isOtpSent(false);
        controller.clearOtp();
        isFirstFocusDone = false;
      }
    });
  }

  @override
  void dispose() {
    Get.delete<ForgetPasswordController>();
    emailController.dispose();
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _forgetPasswordFormKey,
                    child: Column(
                      children: [
                        PageHeading(title: appTitle),

                        CustomInputField(
                          labelText: 'Email',
                          hintText: 'Your email id',
                          isDense: true,
                          controller: emailController,
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

                        const SizedBox(height: 20),

                        Obx(() {
                          if (controller.isOtpSent.value) {
                            if (!isFirstFocusDone) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                otpFocusNodes.first.requestFocus();
                              });
                              isFirstFocusDone = true;
                            }

                            return Column(
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  children: List.generate(4, (index) {
                                    return SizedBox(
                                      width: 50,
                                      child: TextField(
                                        focusNode: otpFocusNodes[index],
                                        maxLength: 1,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          controller.otpList[index].value = value;

                                          if (value.isNotEmpty) {
                                            bool allFilled = controller.otpList.every((otp) => otp.value.isNotEmpty);
                                            if (allFilled) {
                                              FocusScope.of(context).unfocus();
                                            } else if (index < otpFocusNodes.length - 1) {
                                              FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
                                            }
                                          } else if (index > 0) {
                                            FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),

                                Obx(() {
                                  return TextButton(
                                    onPressed: controller.isResendEnabled.value
                                        ? () => controller.resendOtp(emailController.text)
                                        : null,
                                    child: Text(
                                      controller.isResendEnabled.value ? 'Resend OTP' : 'Wait...',
                                      style: TextStyle(
                                        color: controller.isResendEnabled.value ? Colors.blue : Colors.grey,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }
                          return const SizedBox();
                        }),

                        Obx(() {
                          if (controller.isOtpVerified.value) {
                            if (widget.title == 'forget') {
                              return CustomInputField(
                                controller: controller.newPasswordController,
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                                obscureText: controller.obscureNew.value,
                                suffixIcon: true,
                                validator: (value) =>
                                value == null || value.isEmpty ? 'New password is required' : null,
                              );
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.verifyOtpOrChangePassword();
                              });
                            }
                          }
                          return const SizedBox();
                        }),

                        const SizedBox(height: 20),

                        Obx(() {
                          if (controller.errorMessage.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          return const SizedBox();
                        }),

                        Obx(() => controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : CustomFormButton(
                          innerText: controller.isOtpVerified.value
                              ? (widget.title == 'forget' ? 'Change Password' : 'Verified')
                              : controller.isOtpSent.value
                              ? 'Verify OTP'
                              : 'Send OTP',
                          onPressed: () {
                            if (!controller.isOtpSent.value) {
                              if (controller.isOtpVerified.value) {
                                controller.verifyOtpOrChangePassword();
                              } else if (_forgetPasswordFormKey.currentState!.validate()) {
                                controller.sendOtp(emailController.text);
                              }
                            } else if (!controller.isOtpVerified.value) {
                              controller.verifyOtpOrChangePassword();
                            } else {
                              if (widget.title == 'forget') {
                                if (controller.newPasswordController.text.isEmpty) {
                                  CommonUtils.buildSnackBar(
                                    'New Password is required!',
                                    'Error',
                                    Colors.red,
                                    2,
                                  );
                                } else {
                                  controller.verifyOtpOrChangePassword();
                                }
                              }
                            }
                          },
                        )),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Back to login',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.lightGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
