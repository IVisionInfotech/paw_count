import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/City/cotroller/LocationController.dart';
import 'package:survey_dogapp/components/Dashboard/dashboard.dart';
import 'package:survey_dogapp/components/staff_management_screen.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/utils/Common.dart';
import '../../cotroller/login_cotroller.dart';
import '../common/custom_form_button.dart';
import '../common/custom_input_field.dart';
import '../common/page_header.dart';
import '../common/page_heading.dart';
import 'forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final LoginController loginController =
  Get.isRegistered<LoginController>()
      ? Get.find<LoginController>()
      : Get.put(LoginController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        const PageHeading(title: 'Log-in'),
                        CustomInputField(
                          controller: _emailController,
                          labelText: 'Email or Mobile',
                          hintText: 'Enter email or mobile number',
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Email or mobile number is required!';
                            }
                            if (RegExp(r'^[0-9]+$').hasMatch(textValue)) {
                              if (textValue.length != 10) { // change length as per your requirement
                                return 'Please enter a valid mobile number';
                              }
                            }
                            else if (!EmailValidator.validate(textValue)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        CustomInputField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Your password',
                          obscureText: true,
                          suffixIcon: true,
                          validator: (textValue) {
                            if (textValue == null || textValue.isEmpty) {
                              return 'Password is required!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: size.width * 0.80,
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => ForgetPasswordPage(title: "forget"));
                            },
                            child: const Text(
                              'Forget password?',
                              style: TextStyle(
                                color: AppColors.lightGrey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() => loginController.isLoading.value
                            ? const CircularProgressIndicator()
                            : CustomFormButton(
                          innerText: 'Login',
                          onPressed: _handleLoginUser,
                        )),
                        const SizedBox(height: 10),
                        Obx(() {
                          if (loginController.errorMessage.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                loginController.errorMessage.value,
                                style: TextStyle(color: AppColors.red),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: size.width * 0.8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Unregistered device? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.lightGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(() => ForgetPasswordPage(title: "register_device")),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
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

  void _handleLoginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      if (await loginController.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      )) {
        Get.put(LocationController());
        if (CommonUtils.getUserRole()?.toLowerCase() == 'staff') {
          Get.offAll(() => StaffManagementScreen());
        }else{
          Get.offAll(() => Dashboard());
        }

      }
    }
  }
}
