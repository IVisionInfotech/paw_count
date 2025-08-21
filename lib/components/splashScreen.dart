import 'dart:async';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:realm/realm.dart';
import 'package:survey_dogapp/components/Auth/login_page.dart';
import 'package:survey_dogapp/components/City/cotroller/LocationController.dart';
import 'package:survey_dogapp/components/Dashboard/dashboard.dart';
import 'package:survey_dogapp/components/staff_management_screen.dart';
import 'package:survey_dogapp/cotroller/login_cotroller.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/user_model.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/utils/Common.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? profilePhoto;
  Color backgroundColor = Colors.white;
  bool isLoggedIn = false;
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = CommonUtils.getCurrentUser();
    isLoggedIn = user != null && user.userId != 0;
    profilePhoto = user?.profileLogo;

    if (isLoggedIn) {
      bool loggedIn = await loginController.login(
        user?.email ?? "",
        user?.originalPassword ?? "",
      );
      if (loggedIn) {
        Get.put(LocationController());
        await Future.delayed(const Duration(seconds: 2));
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (CommonUtils.getUserRole()?.toLowerCase() == 'staff') {
            Get.off(() => StaffManagementScreen());
          }else{
            Get.off(() => Dashboard());
          }

        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.off(() => LoginPage());
        });
      }
    } else {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.off(() => LoginPage());
      });
    }

    if (profilePhoto?.isNotEmpty == true) {
      _setBackgroundColorFromImage(profilePhoto!);
    }
  }



  Future<void> _setBackgroundColorFromImage(String imageUrl) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imageUrl),
      );

      if (mounted) {
        setState(() {
          backgroundColor = palette.dominantColor?.color ?? Colors.white;
        });
      }
    } catch (e) {
      debugPrint('Palette generation error: $e');
      if (mounted) {
        setState(() => backgroundColor = Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double imageSize = 150.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: profilePhoto?.isNotEmpty == true
            ? CachedNetworkImage(
          imageUrl: profilePhoto!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(color: Colors.blue),
          ),
          errorWidget: (context, url, error) => Image.asset(
            Assets.imagesAppIcon,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
          ),
        )
            : Image.asset(
          Assets.imagesAppIcon,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

}
