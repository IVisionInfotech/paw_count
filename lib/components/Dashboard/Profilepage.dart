import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/dog_breeds_management_screen.dart';
import 'package:survey_dogapp/components/dog_color_management_screen.dart';
import 'package:survey_dogapp/cotroller/dashboardController.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import '../../cotroller/profileController.dart';
import '../../generated/FontHelper.dart';
import '../../generated/assets.dart';
import '../theme.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController controller = Get.put(ProfileController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        Center(
                          child: Obx(
                            () => Column(
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        controller.userProfile?.value != null &&
                                                controller
                                                    .userProfile!
                                                    .value
                                                    .isNotEmpty
                                            ? CachedNetworkImage(
                                              imageUrl:
                                                  controller.userProfile!.value,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) => Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (
                                                    context,
                                                    url,
                                                    error,
                                                  ) => Image.asset(
                                                    Assets
                                                        .imagesIcProfilePlaceholder,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                            )
                                            : Image.asset(
                                              Assets.imagesIcProfilePlaceholder,
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  controller.userName.value,
                                  style: FontHelper.bold(
                                    fontSize: 18,
                                    color: AppColors.titleText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.userRole.value,
                                  style: FontHelper.medium(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ).copyWith(fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.userEmail.value,
                                  style: FontHelper.regular(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.userContact.value,
                                  style: FontHelper.regular(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Actions",
                          style: FontHelper.semiBold(
                            fontSize: 16,
                            color: AppColors.titleText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: List.generate(
                            UrlConstants.getActionItems().length,
                            (index) {
                              final item = UrlConstants.getActionItems()[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    switch (item['action']) {
                                      case 'edit':
                                        controller.editProfile();
                                        break;
                                      case 'password':
                                        controller.changePassword();
                                        break;
                                      case 'addOwner':
                                        controller.gotoOwner();
                                        break;
                                      case 'color':
                                        Get.to(() => DogColorManagementScreen());
                                        break;
                                      case 'breed':
                                        Get.to(() => DogBreedsManagementScreen());
                                        break;
                                      case 'logout':
                                        controller.logout(context);
                                        break;
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            item['action'] == 'logout'
                                                ? AppColors.logoutRed
                                                    .withOpacity(0.6)
                                                : AppColors.iconDefault
                                                    .withOpacity(0.3),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(
                                          item['icon'],
                                          size: 20,
                                          color:
                                              item['action'] == 'logout'
                                                  ? AppColors.logoutRed
                                                  : AppColors.iconDefault,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item['title'],
                                            style: FontHelper.semiBold(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 80,)
            ],
          ),
        ),
      ),
    );
  }
}
