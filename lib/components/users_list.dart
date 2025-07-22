import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/components/create_user.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/userController.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'common/UserCardWidget.dart';

class UsersList extends StatefulWidget {
  final String? title;

  const UsersList({super.key, this.title});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final UserController userController = Get.put(UserController());

  final roleMap = {
    'Admin List': UrlConstants.ADMIN,
    'SubAdmin List': UrlConstants.SUB_ADMIN,
    'Surveyor List': UrlConstants.SURVEYOR,
  };

  String getRoleFromTitle() {
    return roleMap[widget.title] ?? UrlConstants.SUB_ADMIN;
  }

  @override
  void initState() {
    super.initState();
    userController.fetchUsersByRole(getRoleFromTitle());
  }

  Future<void> _onRefresh() async {
    await userController.fetchUsersByRole(getRoleFromTitle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(() => const CreateUser())?.then((value) {
            userController.fetchUsersByRole(getRoleFromTitle());
          });
        },
        child: const Icon(Icons.add, size: 30, color: AppColors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppbar.cusAppBarWidget(
              widget.title.toString(),
              20,
              context,
                  () {
                Get.back();
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  displacement: 50,
                    child: userController.isShimmerLoading.value
                        ? ListShimmerItem(count: 9)
                    : userController.userList.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text(
                            'No ${widget.title?.capitalize ?? 'Data'} added yet.',
                            style: const TextStyle(color: AppColors.lightGrey),
                          ),
                        ),
                      ),
                    ],
                  ) : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: userController.userList.length,
                    itemBuilder: (context, index) {
                      final user = userController.userList[index];
                      return UserCardWidget(
                        onUnRegested: (status) {
                          final isUnregister = status == 0;
                          DialogHelper.showCommonDialog(
                            context: context,
                            title: isUnregister ? "Confirm Unregister" : "Confirm Register",
                            subTitle: isUnregister
                                ? "Are you sure you want to unregister this user?"
                                : "Are you sure you want to register this user?",
                            onPositivePressed: () async {
                              Get.back();
                              bool result = await userController.unRegisterUser(user, status);

                              if (result) {
                                userController.userList[index].status = status;
                                userController.userList.refresh();
                              }
                            },
                            negativeText: "No",
                            positiveText: "Yes",
                            iconColor: isUnregister ? AppColors.red : AppColors.green,
                            icon: isUnregister ? CupertinoIcons.delete : CupertinoIcons.check_mark_circled,
                          );
                        },
                        user: user,
                        onEdit: () {
                          Get.to(() => CreateUser(user: user))?.then((value) {
                            userController.fetchUsersByRole(getRoleFromTitle());
                          });
                        },
                        onDelete:() {
                          DialogHelper.showCommonDialog(
                            context: context,
                            title: "Confirm Delete",
                            subTitle: "Are you sure you want to delete this user?",
                            onPositivePressed: () async {
                              Get.back();
                              await userController.deleteUser(user.userId!);
                            },
                            negativeText: "No",
                            positiveText: "Yes",
                            iconColor: AppColors.red,
                            icon: CupertinoIcons.delete,
                          );

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
