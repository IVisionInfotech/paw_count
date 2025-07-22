import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/Manage/survey_route_page.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/components/MapsScreen/route_compeleted_screen.dart';
import 'package:survey_dogapp/components/MapsScreen/route_details_screen.dart';
import 'package:survey_dogapp/components/Navigation/NavigationScreen.dart';
import 'package:survey_dogapp/components/common/RouteItemWidget.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/dialog_helper.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/homepagesurveyor_cotroller.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepagesurveyor extends StatefulWidget {
  final String flag;

  const Homepagesurveyor({super.key, required this.flag});

  @override
  State<Homepagesurveyor> createState() => _HomepagesurveyorState();
}

class _HomepagesurveyorState extends State<Homepagesurveyor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HomepagesurveyorCotroller routeController = Get.put(
    HomepagesurveyorCotroller(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    routeController.getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final String userRole = CommonUtils.getUserRole() ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton:
      widget.flag == "Manage"
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Get.to(SurveyRoutePage())!.then((value) {
            routeController.loadRouteData(
              routeController.selectedSurveyorId.value,
              routeController.selectedSubAdminId.value,
              routeController.currentUserId,
              routeController.selectedAdminId.value,
            );
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.flag == "Manage") ...[
              CustomAppbar.cusAppBarWidget("Route List", 10, context, () {
                Get.back();
              }),
              const SizedBox(height: 10),
            ],
            if (CommonUtils.getUserRole() != UrlConstants.SURVEYOR) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (userRole == UrlConstants.SUPER_ADMIN)
                      Obx(() {
                        return _buildUserDropdown(
                          label: UrlConstants.STATE_ADMIN,
                          value: routeController.selectedAdminId.value,
                          items: routeController.adminList.value,
                          onChanged: (val) async {
                            routeController.selectedAdminId.value = val;
                            if (val != null) {
                              routeController.loadRouteData(
                                0,
                                0,
                                routeController.currentUserId,
                                val,
                              );
                              routeController.loadSubAdminList(val.toString());
                            }
                            routeController.selectedSubAdminId.value = null;
                            routeController.selectedSurveyorId.value = null;
                          },
                        );
                      }),
                    const SizedBox(width: 10),
                    if (userRole == UrlConstants.SUPER_ADMIN ||
                        userRole == UrlConstants.ADMIN)
                      Obx(() {
                        return _buildUserDropdown(
                          label: UrlConstants.CITY_ADMIN,
                          value: routeController.selectedSubAdminId.value,
                          items: routeController.subAdminList.value,
                          onChanged: (val) {
                            routeController.selectedSubAdminId.value = val;
                            if (val != null) {
                              routeController.loadRouteData(
                                0,
                                val,
                                routeController.currentUserId,
                                routeController.selectedAdminId.value,
                              );
                              routeController.loadSurveyorList(val.toString());
                            }
                            routeController.selectedSurveyorId.value = null;
                          },
                        );
                      }),
                    const SizedBox(width: 10),
                    if (userRole == UrlConstants.SUPER_ADMIN ||
                        userRole == UrlConstants.ADMIN ||
                        userRole == UrlConstants.SUB_ADMIN)
                      Obx(() {
                        return _buildUserDropdown(
                          label: UrlConstants.SURVEYOR,
                          value: routeController.selectedSurveyorId.value,
                          items: routeController.surveyorList.value,
                          onChanged: (val) {
                            routeController.selectedSurveyorId.value = val;
                            routeController.loadRouteData(
                              val,
                              routeController.selectedSubAdminId.value,
                              routeController.currentUserId,
                              routeController.selectedAdminId.value,
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.primary,
              labelStyle: FontHelper.bold(
                color: AppColors.primary,
                fontSize: 13,
              ),
              unselectedLabelStyle: FontHelper.regular(
                color: AppColors.grey,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: UrlConstants.routePending),
                Tab(text: UrlConstants.routeProcessing),
                Tab(text: UrlConstants.routeComplete),
                Tab(text: UrlConstants.routeUnComplete),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Obx(
                        () =>
                        _buildTabContent(
                          routeController.pendingRoutes,
                          UrlConstants.routePending,
                        ),
                  ),
                  Obx(
                        () =>
                        _buildTabContent(
                          routeController.inProgressRoutes,
                          UrlConstants.routeProcessing,
                        ),
                  ),
                  Obx(
                        () =>
                        _buildTabContent(
                          routeController.completedRoutes,
                          UrlConstants.routeComplete,
                        ),
                  ),
                  Obx(
                        () =>
                        _buildTabContent(
                          routeController.unCompletedRoutes,
                          UrlConstants.routeUnComplete,
                        ),
                  ),
                ],
              ),
            ),
            if (widget.flag != "Manage") const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<RouteDataModel> routes, String labelText) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      displacement: 50,
      onRefresh: () async {
        await routeController.loadRouteData(
          routeController.selectedSurveyorId.value,
          routeController.selectedSubAdminId.value,
          routeController.currentUserId,
          routeController.selectedAdminId.value,
        );
      },
      child:
      routeController.isLoading.value
          ? ListView.builder(
        itemCount: 9,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemBuilder: (context, index) => listShimmerItem(),
      )
          : routes.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "No Routes Available",
                style: FontHelper.medium(
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      )
          : ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];
          return RouteItemWidget(
            route: route,
            labelText: labelText,
            userRole: userRole,
            onTap: () {
              if (userRole != UrlConstants.SURVEYOR && labelText == UrlConstants.routeComplete) {
                Get.to(
                      () =>
                      RouteCompeletedScreen(
                        routeData: route,
                        routeType: labelText,
                      ),
                )!.then((value) async {
                  await routeController.loadRouteData(
                    routeController.selectedSurveyorId.value,
                    routeController.selectedSubAdminId.value,
                    routeController.currentUserId,
                    routeController.selectedAdminId.value,
                  );
                });
              } else if (userRole == UrlConstants.SURVEYOR && labelText == UrlConstants.routeComplete) {
                Get.to(
                      () =>
                      RouteCompeletedScreen(
                        routeData: route,
                        routeType: labelText,
                      ),
                )!.then((value) async {
                  await routeController.loadRouteData(
                    routeController.selectedSurveyorId.value,
                    routeController.selectedSubAdminId.value,
                    routeController.currentUserId,
                    routeController.selectedAdminId.value,
                  );
                });
              } else {
                final destination = route.map[0];
                final lat = destination.lat;
                final lng = destination.lng;

                final current = routeController.currentLocation;

                if (current != null) {
                  final locationCheck = routeController
                      .isNearDestination(
                    currentLat: current.latitude!,
                    currentLng: current.longitude!,
                    destLat: lat,
                    destLng: lng,
                  );

                  final bool isNear = locationCheck['isNear'];
                  final double distance = locationCheck['distance'];

                  if (isNear) {
                    if (labelText == UrlConstants.routeProcessing) {
                      if(userRole == UrlConstants.SURVEYOR){
                        Get.to(
                              () =>
                              NavigationScreen(
                                routeData: route,
                                routeType: labelText,
                              ),
                        )!.then((value) async {
                          await routeController.loadRouteData(
                            routeController.selectedSurveyorId.value,
                            routeController.selectedSubAdminId.value,
                            routeController.currentUserId,
                            routeController.selectedAdminId.value,
                          );
                        });
                      }else {
                        Get.to(
                              () =>
                              RouteDetailsScreen(
                                routeData: route,
                                routeType: labelText,
                              ),
                        )!.then((value) async {
                          await routeController.loadRouteData(
                            routeController.selectedSurveyorId.value,
                            routeController.selectedSubAdminId.value,
                            routeController.currentUserId,
                            routeController.selectedAdminId.value,
                          );
                        });
                      }
                    } else if (labelText ==
                        UrlConstants.routePending) {
                      Get.to(
                            () =>
                            RouteDetailsScreen(
                              routeData: route,
                              routeType: labelText,
                            ),
                      )!.then((value) async {
                        await routeController.loadRouteData(
                          routeController.selectedSurveyorId.value,
                          routeController.selectedSubAdminId.value,
                          routeController.currentUserId,
                          routeController.selectedAdminId.value,
                        );
                      });
                    }
                  } else if (labelText != UrlConstants.routeComplete &&
                      labelText != UrlConstants.routeUnComplete) {
                    CommonUtils.buildSnackBar(
                      "Too Far",
                      "You are ${distance.toStringAsFixed(
                          2)} meters away from the destination.\n"
                          "Destination: ($lat, $lng)\n"
                          "Total Destinations: ${route.map.length}",
                      Colors.orange,
                      3,
                    );
                  }
                } else {
                  CommonUtils.buildSnackBar(
                    "Waiting...",
                    "Please Wait Current Location Geting...",
                    Colors.orange,
                    3,
                  );
                }
              }
            },
            onButtonTap: () async {
              if ((labelText == UrlConstants.routePending ||
                  labelText == UrlConstants.routeProcessing) &&
                  route.acceptBy == 0) {
                DialogHelper.showCommonDialog(
                  context: context,
                  icon: Icons.save_rounded,
                  iconColor: AppColors.primary,
                  title: "Accept",
                  subTitle: "Are You Sure?",
                  negativeText: "No",
                  positiveText: "Yes",
                  onPositivePressed: () async {
                    Get.back();
                    await routeController.acceptBtnCall(route.routeId);
                    await routeController.loadRouteData(
                      routeController.selectedSurveyorId.value,
                      routeController.selectedSubAdminId.value,
                      routeController.currentUserId,
                      routeController.selectedAdminId.value,
                    );
                  },
                );
              } else if ((labelText == UrlConstants.routePending ||
                  labelText == UrlConstants.routeProcessing) &&
                  route.acceptBy != 0) {
                final destination = route.map[0];
                final lat = destination.lat;
                final lng = destination.lng;
                final url = Uri.parse(
                  "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
                );

                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  CommonUtils.buildSnackBar(
                    "Error",
                    "Could not launch Google Maps",
                    Colors.red,
                    3,
                  );
                }
              } else if (labelText == UrlConstants.routeUnComplete &&
                  route.reallocation == 1) {
                Get.to(SurveyRoutePage(routes: route))!.then((value,) async {
                  await routeController.loadRouteData(
                    routeController.selectedSurveyorId.value,
                    routeController.selectedSubAdminId.value,
                    routeController.currentUserId,
                    routeController.selectedAdminId.value,
                  );
                });
              }
            },
          );
        },
      ),
    );
  }

  Widget listShimmerItem() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: AppColors.greyBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerLine(width: 180), // Route Name
                    const SizedBox(height: 8),
                    _shimmerLine(width: 140), // City Name
                    const SizedBox(height: 8),
                    _shimmerLine(width: 130), // Zone Name
                    const SizedBox(height: 8),
                    _shimmerLine(width: 120), // Area Name
                    const SizedBox(height: 8),
                    _shimmerLine(width: 110), // Ward Name
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerLine(width: 100), // Start Date
                            const SizedBox(height: 6),
                            _shimmerLine(width: 100), // End Date
                          ],
                        ),
                        Row(children: [_shimmerButton(width: 60)]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 20,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            period: const Duration(milliseconds: 1000),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // base shimmer color
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Container(width: 60, height: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerLine({double width = 100, double height = 12}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1000),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _shimmerButton({double width = 80, double height = 30}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1000),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildUserDropdown({
    required String label,
    required int? value,
    required List<User> items,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontHelper.semiBold(fontSize: 14, color: AppColors.black),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<int>(
            value: value,
            style: FontHelper.regular(color: AppColors.black, fontSize: 14),
            hint: Text(
              'Select $label',
              style: FontHelper.regular(fontSize: 15, color: AppColors.grey),
            ),
            underline: const SizedBox(),
            isDense: true,
            onChanged: onChanged,
            items:
            items.map((user) {
              return DropdownMenuItem<int>(
                value: user.userId,
                child: Text(user.name ?? "N/A"),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
