import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/common/common_list_shimmer.dart';
import 'package:survey_dogapp/components/create_user.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/userController.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/staff_dog_model.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'common/UserCardWidget.dart';

class UsersList extends StatefulWidget {
  final String? title;

  const UsersList({super.key, this.title});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.put(UserController());

  late TabController _tabController;

  final roleMap = {
    'Admin List': UrlConstants.ADMIN,
    'SubAdmin List': UrlConstants.SUB_ADMIN,
    'Surveyor List': UrlConstants.SURVEYOR,
    'Associates List': UrlConstants.STAFF,
  };

  String getRoleFromTitle() {
    return roleMap[widget.title] ?? UrlConstants.SUB_ADMIN;
  }

  bool get isAssociatesList => widget.title == 'Associates List';

  @override
  void initState() {
    super.initState();

    if (isAssociatesList) {
      _tabController = TabController(length: 2, vsync: this);
    }
    userController.dogTypeFetch();
    userController.staffDogFetch();
    userController.fetchUsersByRole(getRoleFromTitle());
  }

  Future<void> _onRefresh() async {
    await userController.fetchUsersByRole(getRoleFromTitle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      floatingActionButton: isAssociatesList
          ? AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return _tabController.index == 1
              ? const SizedBox.shrink() // hide button
              : FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Get.to(() => const CreateUser())?.then((value) {
                userController.fetchUsersByRole(getRoleFromTitle());
              });
            },
            child: const Icon(Icons.add,
                size: 30, color: AppColors.white),
          );
        },
      )
          : FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(() => const CreateUser())?.then((value) {
            userController.fetchUsersByRole(getRoleFromTitle());
          });
        },
        child:
        const Icon(Icons.add, size: 30, color: AppColors.white),
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

            if (isAssociatesList) ...[
              const SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.lightGrey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: "Associates"),
                  Tab(text: "Dog List"),
                ],
              ),
            ],

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                final userList = userController.userList;

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  displacement: 50,
                  child: userController.isShimmerLoading.value
                      ? ListShimmerItem(count: 9)
                      : userList.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                        MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text(
                            'No ${widget.title?.capitalize ?? 'Data'} added yet.',
                            style: const TextStyle(
                                color: AppColors.lightGrey),
                          ),
                        ),
                      ),
                    ],
                  )
                      : isAssociatesList
                      ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUserList(
                        userList
                            .where((u) => u.status == 1)
                            .toList(),
                      ),

                      buildFilterAndList(
                        context: context,
                        controller: userController,
                        selectDate: _selectDate,
                        buildMultiSelect: _buildMultiSelect,
                      ),
                    ],
                  )
                      : _buildUserList(userList),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<dynamic> users) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCardWidget(
          onUnRegested: (status) {
            final isUnregister = status == 0;
            DialogHelper.showCommonDialog(
              context: context,
              title: isUnregister
                  ? "Confirm Unregister"
                  : "Confirm Register",
              subTitle: isUnregister
                  ? "Are you sure you want to unregister this user?"
                  : "Are you sure you want to register this user?",
              onPositivePressed: () async {
                Get.back();
                bool result =
                await userController.unRegisterUser(user, status);

                if (result) {
                  user.status = status;
                  userController.userList.refresh();
                }
              },
              negativeText: "No",
              positiveText: "Yes",
              iconColor: isUnregister ? AppColors.red : AppColors.green,
              icon: isUnregister
                  ? CupertinoIcons.delete
                  : CupertinoIcons.check_mark_circled,
            );
          },
          user: user,
          onEdit: () {
            Get.to(() => CreateUser(user: user))?.then((value) {
              userController.fetchUsersByRole(getRoleFromTitle());
            });
          },
          onDelete: () {
            DialogHelper.showCommonDialog(
              context: context,
              title: "Confirm Delete",
              subTitle:
              "Are you sure you want to delete this user?",
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
    );
  }

  Widget buildFilterAndList<T>({
    required BuildContext context,
    required dynamic controller,
    required Future<void> Function(BuildContext, {required bool isStart}) selectDate,
    required Widget Function<E>({
    required String label,
    required RxList<E> items,
    required RxList<E> selectedItems,
    }) buildMultiSelect,
  }) {
    return Obx(
          () => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Card(
                color: AppColors.background,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filters",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.selectedStartDate.value = null;
                              controller.selectedEndDate.value = null;
                              controller.selectedAssociateList.clear();
                              controller.selectedDogTypes.clear();
                              controller.applyFilters();
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => selectDate(context, isStart: true),
                              child: Text(
                                controller.selectedStartDate.value != null
                                    ? DateFormat('dd-MM-yyyy')
                                    .format(controller.selectedStartDate.value!)
                                    : 'Start Date',
                                style: TextStyle(
                                  color: controller.selectedStartDate.value != null
                                      ? AppColors.black
                                      : AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => selectDate(context, isStart: false),
                              child: Text(
                                controller.selectedEndDate.value != null
                                    ? DateFormat('dd-MM-yyyy')
                                    .format(controller.selectedEndDate.value!)
                                    : 'End Date',
                                style: TextStyle(
                                  color: controller.selectedEndDate.value != null
                                      ? AppColors.black
                                      : AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                buildMultiSelect<DogTypeModel>(
                                  label: "Dog Type",
                                  items: userController.dogTypeList,
                                  selectedItems: userController.selectedDogTypes,
                                ),
                                const SizedBox(height: 10),
                                buildMultiSelect<User>(
                                  label: "Associate",
                                  items: userController.userList,
                                  selectedItems: userController.selectedAssociateList,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf,
                                color: AppColors.primary),
                            tooltip: "Download PDF",
                            onPressed: () async {
                              await controller.fetchReport(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                itemCount: controller.filteredStaffDogList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final dog = controller.filteredStaffDogList[index];
                  return Card(
                    color: AppColors.white,
                    child: ListTile(
                      onTap: () {
                        _showDogDetailsDialog(context, dog);
                      },
                      leading: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: dog.imgUrl ?? "",
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      ),
                      title: Text(dog.dogTypeName ?? ""),
                      subtitle: Text(dog.remark ?? ""),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMultiSelect<T>({
    required String label,
    required RxList<T> items,
    required RxList<T> selectedItems,
  }) {
    return Obx(
          () => MultiSelectDialogField<T>(
        items: items
            .map((e) {
          final labelText = e is DogTypeModel
              ? e.name ?? ''
              : e is User
              ? e.name ?? ''
              : e.toString();

          return MultiSelectItem<T>(e, labelText);
        })
            .toList(),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        buttonText: Text(
          "Select $label",
          style: const TextStyle(color: AppColors.titleText),
        ),
        searchable: true,
        listType: MultiSelectListType.CHIP,
        backgroundColor: AppColors.white,
        unselectedColor: AppColors.greyBg,
        selectedColor: AppColors.primary,
        checkColor: AppColors.white,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        chipDisplay: MultiSelectChipDisplay<T>(
          textStyle: const TextStyle(color: AppColors.white),
          chipColor: AppColors.primary,
        ),
        onConfirm: (val) {
          selectedItems.value = val;
          Get.find<UserController>().applyFilters();
        },
        cancelText: const Text(
          "Cancel",
          style: TextStyle(color: AppColors.logoutRed),
        ),
        confirmText: const Text(
          "Ok",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        initialValue: selectedItems,
        selectedItemsTextStyle: const TextStyle(color: AppColors.white),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (isStart) {
        userController.selectedStartDate.value = picked;
      } else {
        userController.selectedEndDate.value = picked;
      }
      userController.applyFilters();
    }
  }

  void _showDogDetailsDialog(BuildContext context, StaffDogModel type) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: FutureBuilder<String>(
            future: userController.getAddressFromLatLng(type.lat, type.lng),
            builder: (context, snapshot) {
              String address = "Loading...";
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  address = snapshot.data!;
                } else {
                  address = "Address not available";
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Dog Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: type.imgUrl ?? "",
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CommonShimmer(width: 150, height: 150),
                        errorWidget: (context, url, error) => Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.pets, color: Colors.white, size: 50),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Details Section
                    Column(
                      children: [
                        _buildInfoRow(Icons.location_on, address),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.notes, type.remark ?? "-"),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.calendar_today,
                            formatDate(type.createdAt)),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat("dd-MM-yyyy").format(dateTime);
    } catch (e) {
      return "-";
    }
  }
}

