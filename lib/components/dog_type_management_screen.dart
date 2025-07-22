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
import 'package:survey_dogapp/cotroller/dog_type_controller.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class DogTypeManagementScreen extends StatefulWidget {
  const DogTypeManagementScreen({super.key});

  @override
  State<DogTypeManagementScreen> createState() => _DogTypeManagementScreenState();
}

class _DogTypeManagementScreenState extends State<DogTypeManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  final DogTypeController controller = Get.put(DogTypeController());

  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
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
                  'Dog Type Management',
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
                    backgroundColor: AppColors.white,
                    displacement: 50,
                    onRefresh: () async {
                      await controller.loadDogTypes();
                    },
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return ListShimmerItem(count: 9);
                      }

                      if (controller.dogTypeList.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                'No dog type added yet.',
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
                        itemCount: controller.dogTypeList.length,
                        itemBuilder: (context, index) {
                          final dog = controller.dogTypeList[index];
                          return ListCardView(
                            dog: dog,
                            onEdit: () => controller.showAddDogTypeDialog(context, dogModel: dog),
                            onDelete: () {
                              DialogHelper.showCommonDialog(
                                context: context,
                                title: "Confirm Delete",
                                subTitle: "Are you sure you want to delete this dog type?",
                                onPositivePressed: () async {
                                  Get.back();
                                  await controller.deleteDogType(dog.id.toString());
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
                  color: AppColors.black.withOpacity(0.4),
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
}
