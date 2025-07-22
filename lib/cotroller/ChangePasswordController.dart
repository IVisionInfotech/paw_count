import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:objectid/src/objectid/objectid.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/model/ApiResponse.dart';
import 'package:survey_dogapp/model/user_model.dart';
import '../utils/Common.dart';
import '../utils/Constant.dart';

class ChangePasswordController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;

  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureOld = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading(true);
    errorMessage("");

    final user = CommonUtils.getCurrentUser();
    if (user == null) {
      errorMessage("User not found.");
      isLoading(false);
      return;
    }

    if (oldPasswordController.text != user.originalPassword) {
      errorMessage("Old password is incorrect.");
      Get.snackbar("Error", "Old password is incorrect");
      isLoading(false);
      return;
    }

    final response = await CommonUtils.callApi(
      url: UrlConstants.changePasswordUrl,
      body: {
        'user_id': user.userId.toString(),
        'confirm_password': confirmPasswordController.text,
      },
    );

    if (response == null) {
      errorMessage("Connection failed. Check your internet.");
      isLoading(false);
      return;
    }

    if (response.status == 1) {
      CommonUtils.updateFieldInRealm<UserModel>(
        user.userId!.toInt(),
        (user) => user.originalPassword = confirmPasswordController.text,
        UserModel.schema,
      );
      Get.back();
      CommonUtils.buildSnackBar(
        response.message ?? "Change password successful.",
        "Success",
        AppColors.green,
        2,
      );
    } else {
      CommonUtils.buildSnackBar(
        response.message ?? "Change password failed.",
        "Error",
        AppColors.red,
        2,
      );
    }

    isLoading(false);
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
