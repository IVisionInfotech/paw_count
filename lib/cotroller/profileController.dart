import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/Auth/change_password_page.dart';
import 'package:survey_dogapp/components/Auth/edit_profile.dart';
import 'package:survey_dogapp/components/dogOwnerListPage.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/dashboardController.dart';
import 'package:survey_dogapp/model/user_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/ImagePickerUtil.dart';

import '../utils/Constant.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = "".obs;
  DashboardController dashboardController = Get.find();
  var userName = CommonUtils.getUserName()?.obs ?? 'User Name'.obs;
  var userEmail = CommonUtils.getUserEmail()?.obs ?? 'User Email'.obs;
  var userContact = CommonUtils.getUserContact()?.obs ?? '+91 XXXXX XXXXX'.obs;
  var userRole = CommonUtils.getUserRole()?.obs ?? 'User Role'.obs;
  var userProfile = CommonUtils.getUserProfile()?.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  final userImageUpdate = 0.obs;
  var profileLogo = Rxn<File>();
  var profileLogoUri = ''.obs;

  void logout(BuildContext context) {
    CommonUtils.showLogoutDialog(context);
  }

  void editProfile() {
    Get.to(() => EditProfile())!.then((value) {
      dashboardController.userName.value = userName.value ?? '';
      dashboardController.userRole.value = userRole.value ?? '';
    },);
  }

  void changePassword() {
    Get.to(() => ChangePasswordPage());
  }

  void gotoOwner() {
    Get.to(() => DogOwnerListPage());
  }

  void loadUserData() {
    nameController.text = userName.value;
    emailController.text = userEmail.value;
    contactController.text = userContact.value;
    addressController.text = CommonUtils.getUserAddress() ?? '';
    profileLogoUri.value = userProfile!.value ?? '';
  }

  void pickImageDialog() {
    ImagePickerUtil().pickImageDialog(
      onImageSelected: (file) {
        profileLogo.value = file;
        userImageUpdate.value = 1;
      },
      onError: (message) {
        CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
      },
    );
  }

  Future<void> addUpdateUser() async {
    String base64Image = "";
    int updateImageFlag = 0;
    int userId = CommonUtils.getUserId() ?? 0;
    if (userImageUpdate.value == 1 && profileLogo.value != null) {
      final bytes = await profileLogo.value!.readAsBytes();
      base64Image = "data:image/png;base64,${base64Encode(bytes)}";
      updateImageFlag = 1;
    }

    isLoading(true);

    final response = await CommonUtils.callApi(
      url: UrlConstants.updateUsers,
      body: {
        "user_id": userId,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "contact": contactController.text.trim(),
        "address": addressController.text.trim(),
        "profile_logo": base64Image,
        "update_image": updateImageFlag,
      },
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    final message = response.message ?? "User update processed";

    if (response.status == 1 && response.user != null) {
      final u = response.user!;

      CommonUtils.saveToRealm<UserModel>(
        UserModel(
          0,
          userId: u.userId ?? 0,
          name: u.name ?? '',
          email: u.email ?? '',
          password: u.password ?? '',
          originalPassword: u.originalPassword ?? '',
          role: u.role ?? '',
          contact: u.contact ?? '',
          profileLogo: u.profileLogo ?? '',
          address: u.address ?? '',
          stateId: u.stateId ?? 0,
          superAdminId: u.superAdminId ?? 0,
          adminId: u.adminId ?? 0,
          subAdminId: u.subAdminId ?? 0,
          assignCityId: u.assignCityId ?? 0,
          registeredDeviceId: u.registeredDeviceId ?? '',
          ownership: u.ownership ?? 0,
          changeBorder: u.changeBorder ?? 0,
          status: u.status ?? 0,
          deletestatus: u.deletestatus ?? 0,
          otp: u.otp ?? 0,
          time: u.time ?? 0,
          createdAt: u.createdAt ?? '',
          updatedAt: u.updatedAt ?? '',
        ),
        UserModel.schema,
      );
      userName.value = u.name ?? 'User Name';
      userEmail.value = u.email ?? 'User Email';
      userContact.value = u.contact ?? '+91 XXXXX XXXXX';
      userRole.value = u.role ?? 'User Role';
      userProfile?.value = u.profileLogo ?? '';
      Get.back(result: true);
      CommonUtils.buildSnackBar(message, "Success", AppColors.green, 2);
    } else {
      CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
    }
  }
}
