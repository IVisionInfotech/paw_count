import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/addDogOwnerPage.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/dog_owner_list_shimmer_item.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/components/common/dog_owner_list_item.dart';
import 'package:survey_dogapp/cotroller/dogOwnerController.dart';
import 'package:survey_dogapp/components/theme.dart';

class DogOwnerListPage extends StatefulWidget {
  const DogOwnerListPage({Key? key}) : super(key: key);

  @override
  State<DogOwnerListPage> createState() => _DogOwnerListPageState();
}

class _DogOwnerListPageState extends State<DogOwnerListPage> {
  final DogOwnerController controller = Get.put(DogOwnerController());

  Future<void> _onRefresh() async {
    await controller.fetchDogOwners();
  }

  @override
  void initState() {
    super.initState();
    controller.fetchDogOwners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(() => AddDogOwnerPage())?.then((value) {
            controller.fetchDogOwners();
          });
        },
        child: const Icon(Icons.add, size: 30, color: AppColors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar.cusAppBarWidget(
              'Dog Owners List',
              20,
              context,
                  () => Get.back(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.background,
                  child: controller.isShimmerLoading.value
                      ? DogOwnerListShimmerItem(count: 6)
                      : controller.dogOwnersList.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(
                          child: Text('No Dog Owners available.', style: TextStyle(color: AppColors.lightGrey)),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.dogOwnersList.length,
                    itemBuilder: (context, index) {
                      final dogOwner = controller.dogOwnersList[index];
                      return DogOwnerListItem(
                        dogOwner: dogOwner,
                        onEdit: () {
                          Get.to(() => AddDogOwnerPage(dogOwnerModel: dogOwner));
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
