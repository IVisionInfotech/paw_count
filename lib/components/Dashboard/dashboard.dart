import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:survey_dogapp/components/Dashboard/HomePageSurveyor.dart';
import 'package:survey_dogapp/components/Dashboard/Homepage.dart';
import 'package:survey_dogapp/components/Dashboard/ManagePage.dart';
import 'package:survey_dogapp/components/Dashboard/ProfilePage.dart';
import '../../cotroller/dashboardController.dart';
import '../../generated/FontHelper.dart';
import '../../generated/assets.dart';
import '../../utils/Common.dart';
import '../theme.dart';

class Dashboard extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  late final List<Widget> pages;
  DateTime? lastBackPressed;

  Dashboard({super.key}) {
    if (controller.userRole.value.toLowerCase() == 'surveyor') {
      pages = [Homepagesurveyor(flag: "Dashboard",), ProfilePage()];
    } else {
      pages = [Homepage(), ManagePage(), ProfilePage()];
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 360;

    double fontSizeTitle = isSmall ? 12 : 16;
    double fontSizeSubtitle = isSmall ? 8 : 10;
    double imageSize = isSmall ? 35 : 45;
    double horizontalPadding = screenWidth * 0.04;
    double topPadding = screenHeight * 0.010;

    return WillPopScope(
      onWillPop: () async {
        if (controller.activePage.value != 0) {
          controller.updatePage(0);
          return false;
        }

        DateTime now = DateTime.now();
        if (lastBackPressed == null || now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Are you sure you want to exit?",style: TextStyle(color: AppColors.white),),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
              margin: const EdgeInsets.all(16),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Obx(() => Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: AppColors.primary,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: topPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi ${controller.userName.value} - ${controller.displayRole == "STAFF" ? "Associates" : controller.displayRole}.',
                                style: FontHelper.bold(
                                  fontSize: fontSizeTitle,
                                  color: Color(0xFFF5F5F5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Welcome back to GOAL Foundation Survey panel',
                                style: FontHelper.regular(
                                  fontSize: fontSizeSubtitle,
                                  color: Color(0xFFDBE0E4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: imageSize,
                          height: imageSize ,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: controller.userProfile?.value != null &&
                                controller.userProfile!.value.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: controller.userProfile!.value,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                Assets.imagesIcProfilePlaceholder,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Image.asset(
                              Assets.imagesIcProfilePlaceholder,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                top: screenHeight * 0.09,
                child: pages[controller.activePage.value],
              ),
              Positioned(
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: screenHeight * 0.025,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GNav(
                      rippleColor: Colors.grey[800]!,
                      hoverColor: Colors.grey[700]!,
                      haptic: true,
                      tabBorderRadius: 30,
                      tabBackgroundColor: AppColors.primary,
                      gap: 8,
                      color: Colors.white70,
                      activeColor: AppColors.white,
                      iconSize: isSmall ? 24 : 26,
                      padding: EdgeInsets.symmetric(
                          horizontal: controller.userRole.value.toLowerCase() == 'surveyor' ? 50 : 10, vertical: isSmall ? 8 : 10),
                      backgroundColor: AppColors.transparent,
                      selectedIndex: controller.activePage.value,
                      duration: const Duration(milliseconds: 500),
                      onTabChange: controller.updatePage,
                      tabs: controller.userRole.value.toLowerCase() == 'surveyor'
                          ? const [
                        GButton(icon: Icons.home_outlined, text: 'Home'),
                        GButton(icon: Icons.person_outline, text: 'Profile'),
                      ]
                          : const [
                        GButton(icon: Icons.home_outlined, text: 'Home'),
                        GButton(icon: Icons.work_outline, text: 'Manage'),
                        GButton(icon: Icons.person_outline, text: 'Profile'),
                      ],
                
                    ),
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

