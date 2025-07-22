import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/theme.dart';
import '../utils/Common.dart';
import '../utils/Constant.dart';

class ForgetPasswordController extends GetxController {
  final String title;
  final newPasswordController = TextEditingController();

  final obscureNew = true.obs;
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final serverOtp = ''.obs;
  final userId = ''.obs;
  final isResendEnabled = false.obs;
  final resendCountdown = 0.obs;
  final otpList = List.generate(4, (_) => ''.obs);

  Timer? _resendTimer;

  ForgetPasswordController(this.title);

  String get fullOtp => otpList.map((e) => e.value).join();

  void clearOtp() => otpList.forEach((otp) => otp.value = '');

  Future<void> sendOtp(String email) async {
    isLoading(true);
    errorMessage('');
    try {
      final response = await CommonUtils.callApi(
        url: UrlConstants.forgotPasswordUrl,
        headers: {'Content-Type': 'application/json'},
        body: {'email': email},
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
      } else if (response.status == 1) {
        serverOtp.value = response.user!.otp.toString();
        userId.value = response.user!.userId.toString();
        startResendTimer(response.user!.time as int);
        isOtpSent(true);
        clearOtp();
        CommonUtils.buildSnackBar(
          response.message ?? 'OTP has been sent.',
          "Success",
          AppColors.green,
          2,
        );
      } else {
        errorMessage(response.message ?? 'Failed to send OTP.');
      }
    } catch (e) {
      errorMessage('Something went wrong: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> verifyOtpOrChangePassword() async {
    isLoading(true);
    errorMessage('');
    try {
      if (!isOtpVerified.value) {
        if (fullOtp.length < 4) {
          errorMessage('Please enter all 4 digits of the OTP.');
        } else if (fullOtp != serverOtp.value) {
          errorMessage('OTP does not match.');
        } else {
          await _handleOtpVerified();
        }
        return;
      }

      if (newPasswordController.text.isEmpty) {
        errorMessage("New password is required.");
      } else if (newPasswordController.text.length < 4) {
        errorMessage("Password must be at least 4 characters.");
      } else {
        await _changePassword();
      }
    } catch (e) {
      errorMessage('Something went wrong: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _handleOtpVerified() async {
    if (title == 'forget') {
      isOtpSent(false);
      isOtpVerified(true);
    } else if (title == 'register_device') {
      final deviceId = await CommonUtils.getDeviceId();
      final response = await CommonUtils.callApi(
        url: UrlConstants.verifyOtpUrl,
        headers: {'Content-Type': 'application/json'},
        body: {'user_id': userId.toString(), 'device_id': deviceId},
      );

      if (response == null) {
        errorMessage('Connection failed. Check your internet.');
      } else if (response.status == 1) {
        Get.back();
        CommonUtils.buildSnackBar(
          response.message ?? 'OTP Verified!',
          "Success",
          AppColors.green,
          2,
        );
      } else {
        errorMessage(response.message ?? 'Invalid OTP.');
      }
    } else {
      CommonUtils.buildSnackBar('OTP Verified!', "Success", AppColors.green, 2);
    }
  }

  Future<void> _changePassword() async {
    final response = await CommonUtils.callApi(
      url: UrlConstants.verifyOtpUrl,
      headers: {'Content-Type': 'application/json'},
      body: {'user_id': userId.toString(), 'password': newPasswordController.text},
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
    } else if (response.status == 1) {
      Get.back();
      CommonUtils.buildSnackBar(
        response.message ?? 'Password updated successfully.',
        "Success",
        AppColors.green,
        2,
      );
    } else {
      errorMessage(response.message ?? 'Something went wrong.');
    }
  }

  Future<void> resendOtp(String email) async {
    if (!isResendEnabled.value) return;
    clearOtp();
    isOtpSent(false);
    await sendOtp(email);
  }

  void startResendTimer(int seconds) {
    isResendEnabled(false);
    resendCountdown.value = seconds;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        isResendEnabled(true);
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    newPasswordController.dispose();
    super.onClose();
  }
}
