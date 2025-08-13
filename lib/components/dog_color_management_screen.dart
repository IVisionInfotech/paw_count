import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/common_dog_management_card.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/dog_color_controller.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class DogColorManagementScreen extends StatefulWidget {
  const DogColorManagementScreen({super.key});

  @override
  State<DogColorManagementScreen> createState() => _DogColorManagementScreenState();
}

class _DogColorManagementScreenState extends State<DogColorManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  final DogColorController controller = Get.put(DogColorController());
  final isSuperAdmin = CommonUtils.getUserRole() == UrlConstants.SUPER_ADMIN;
  bool _isFabVisible = false;

  @override
  void initState() {
    super.initState();
    if (isSuperAdmin) {
      _isFabVisible = true;
    }

    _scrollController.addListener(() {
      if (isSuperAdmin) return;
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.showAddDogTypeDialog(context);
        },
        child: const Icon(Icons.add, size: 30, color: AppColors.white),
      )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppbar.cusAppBarWidget(
                  'Dog Color Management',
                  20,
                  context,
                      () {
                    Get.back();
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    displacement: 50,
                    onRefresh: () async {
                      await controller.loadDogColor();
                    },
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return ListShimmerItem(count: 9);
                      }

                      if (controller.dogColorList.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                'No Dog Color added yet.',
                                style: TextStyle(color: AppColors.lightGrey),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: controller.dogColorList.length,
                        itemBuilder: (context, index) {
                          final dog = controller.dogColorList[index];
                          return ListCardView(
                            dog: dog,
                            isVisible:CommonUtils.getUserRole() ==
                                UrlConstants.SUPER_ADMIN,
                            onEdit: () => controller.showAddDogTypeDialog(context, dogModel: dog),
                            onDelete: () {
                              DialogHelper.showCommonDialog(
                                context: context,
                                title: "Confirm Delete",
                                subTitle: "Are you sure you want to delete this dog color?",
                                onPositivePressed: () async {
                                  Get.back();
                                  await controller.deleteDogColor(dog.id.toString());
                                },
                                negativeText: "No",
                                positiveText: "Yes",
                                iconColor: AppColors.red,
                                icon: CupertinoIcons.delete,
                              );
                            },
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
            Obx(() {
              return controller.isLoadingEdit.value
                  ? Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Loading...",
                        style: FontHelper.regular(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget listShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 150, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 100, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
