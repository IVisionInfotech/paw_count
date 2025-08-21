import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/cotroller/staff_controller.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/staff_dog_model.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({Key? key}) : super(key: key);

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final StaffManagementController controller = Get.put(
    StaffManagementController(),
  );
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    controller.dogTypeFetch();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 360;

    double fontSizeTitle = isSmall ? 14 : 18;
    double fontSizeSubtitle = isSmall ? 10 : 12;
    double imageSize = isSmall ? 35 : 45;
    double horizontalPadding = screenWidth * 0.04;
    double topPadding = screenHeight * 0.010;

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Are you sure you want to exit?",
                style: TextStyle(color: AppColors.white),
              ),
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
          child: Column(
            children: [
              Container(
                color: AppColors.primary,
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
                          Obx(
                            () => Text(
                              'Hi ${controller.userName.value}!',
                              style: FontHelper.bold(
                                fontSize: fontSizeTitle,
                                color: const Color(0xFFF5F5F5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome back to Associate panel.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFDBE0E4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            controller.logout(context);
                          },
                        ),
                        Obx(
                          () => Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  controller.userProfile.value.isNotEmpty
                                      ? CachedNetworkImage(
                                        imageUrl: controller.userProfile.value,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        Assets.imagesIcProfilePlaceholder,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Material(
                color: AppColors.primary,
                child: TabBar(
                  controller: controller.tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on), text: "Dog Type"),
                    Tab(icon: Icon(Icons.list), text: "Dog List"),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (controller.dogTypeList.isEmpty) {
                    return const Center(child: Text("No dog types found."));
                  }

                  return TabBarView(
                    controller: controller.tabController,
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 3 / 3.5,
                            ),
                        itemCount: controller.dogTypeList.length,
                        itemBuilder: (context, index) {
                          final typeList = controller.dogTypeList[index];
                          return GestureDetector(
                            onTap: () {
                              controller.resetDialog();
                              _showDogDialog(context, typeList);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ), // border
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: typeList.imagePath ?? "",
                                      fit: BoxFit.fill,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      color: Colors.black54,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        typeList.name ?? "No Name",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: controller.staffDogList.length,
                        itemBuilder: (context, index) {
                          final type = controller.staffDogList[index];
                          return Card(
                            color: AppColors.white,
                            child: ListTile(
                              onTap: () {
                                _showDogDetailsDialog(context, type);
                              },
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: type.imgUrl ?? "",
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) =>
                                          CommonShimmer(width: 50, height: 50),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        width: 46,
                                        height: 46,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                ),
                              ),
                              title: Text(type.dogTypeName ?? ""),
                              subtitle: Text(type.remark ?? ""),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDogDetailsDialog(BuildContext context, StaffDogModel type) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: FutureBuilder<String>(
            future: getAddressFromLatLng(type.lat, type.lng),
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

  Future<String> getAddressFromLatLng(String? lat, String? lng) async {
    try {
      if (lat == null || lng == null) return "Invalid location";

      final double latitude = double.tryParse(lat) ?? 0.0;
      final double longitude = double.tryParse(lng) ?? 0.0;

      if (latitude == 0.0 && longitude == 0.0) return "Invalid coordinates";

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        String address = [
          place.subLocality,
          place.locality,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        return address.isNotEmpty ? address : "Unknown location";
      }
      return "Unknown location";
    } catch (e) {
      return "Unable to fetch address";
    }
  }

  void _showDogDialog(BuildContext context, DogTypeModel dogModel) {
    final controller = Get.find<StaffManagementController>();
    controller.showImageError.value = false;

    Get.dialog(
      AlertDialog(
        title: const Text("Add Details"),
        content: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipOval(
                  child:
                      controller.pickedImage.value == null
                          ? Image.asset(
                            Assets.imagesDogImg,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                          : Image.file(
                            controller.pickedImage.value!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                ),
                if (controller.pickedImage.value == null &&
                    controller.showImageError.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "Image is required",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    controller.pickImageDialog();
                    controller.showImageError.value = false;
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Remark",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => controller.remark.value = val,
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.pickedImage.value == null) {
                controller.showImageError.value = true;
                return;
              }
              controller.saveDogCatch(dogModel: dogModel);
              Get.back();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
