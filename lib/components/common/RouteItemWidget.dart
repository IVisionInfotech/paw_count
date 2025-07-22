import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class RouteItemWidget extends StatelessWidget {
  final dynamic route;
  final String labelText;
  final String userRole;
  final Function()? onTap;
  final Function()? onButtonTap;

  const RouteItemWidget({
    super.key,
    required this.route,
    required this.labelText,
    required this.userRole,
    required this.onTap,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
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
                      _buildInfoText(
                        "Route Name: ",
                        route.routeName ?? "Null",
                        icon: Icons.route,
                      ),
                      _buildInfoText(
                        "City Name: ",
                        route.cityName ?? "Null",
                        icon: Icons.location_city,
                      ),
                      _buildInfoText(
                        "Zone Name: ",
                        route.zoneName ?? "Null",
                        icon: Icons.map,
                      ),
                      _buildInfoText(
                        "Area Name: ",
                        route.areaName ?? "Null",
                        icon: Icons.place,
                      ),
                      _buildInfoText(
                        "Ward Name: ",
                        route.wardName ?? "Null",
                        icon: Icons.apartment,
                      ),
                      if(route.dogMarkers.isNotEmpty)
                        _buildInfoText("Surveyor Name: ",
                          route.dogMarkers.first.surveyorName ?? "",
                          icon: Icons.apartment,),
                      if (labelText == UrlConstants.routeUnComplete)
                        _buildInfoText(
                          "Remark: ",
                          route.remark ?? 'Null',
                          icon: Icons.comment,
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (route.startDate != "0000-00-00 00:00:00" &&
                                    route.startDate.isNotEmpty)
                                  _buildInfoText(
                                    "Start: ",
                                    CommonUtils.formatDateTime(
                                        route.startDate) ?? "Null",
                                    icon: Icons.play_arrow_rounded,
                                  ),
                                if (route.endDate != "0000-00-00 00:00:00" &&
                                    route.endDate.isNotEmpty)
                                  _buildInfoText(
                                    "End: ",
                                    CommonUtils.formatDateTime(route.endDate) ??
                                        "Null",
                                    icon: Icons.stop_circle_rounded,
                                  ),
                              ],
                            ),
                          ),
                          if (_shouldShowButton(labelText, route) &&
                              _getButtonColor(labelText, route) != null)

                            ElevatedButton(
                              onPressed: onButtonTap,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                backgroundColor: _getButtonColor(
                                    labelText, route),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_getButtonIcon(labelText, route) !=
                                        null)
                                      Icon(_getButtonIcon(labelText, route),
                                          size: 15, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      _getButtonText(labelText, route),
                                      style: FontHelper.medium(
                                          color: Colors.white, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                        ],
                      ),

                      if (labelText == UrlConstants.routeComplete &&
                          route.dogCount.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.pets,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Dog Catch Summary:",
                                  style: FontHelper.semiBold(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                              route.dogCount.map<Widget>((dog) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(
                                      0.1,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.pets,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${dog.dogType}: ",
                                        style: FontHelper.medium(
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${dog.count}",
                                        style: FontHelper.bold(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getLabelBackgroundColor(labelText),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                labelText,
                style: FontHelper.bold(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String title, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
          if (icon != null) const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: title,
                style: FontHelper.medium(fontSize: 13, color: AppColors.black),
                children: [
                  TextSpan(
                    text: value,
                    style: FontHelper.semiBold(
                      fontSize: 13,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLabelBackgroundColor(String labelText) {
    switch (labelText) {
      case UrlConstants.routePending: // "In Pending"
        return Colors.orange;
      case UrlConstants.routeProcessing: // "In Processing"
        return Colors.blue;
      case UrlConstants.routeComplete: // "Completed"
        return Colors.green;
      case UrlConstants.routeUnComplete: // "UnCompleted"
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _shouldShowButton(String label, dynamic route) {
    if (label == UrlConstants.routeUnComplete) {
      return route.reallocation == 1 && userRole != UrlConstants.SURVEYOR;
    }
    return true;
  }

  String _getButtonText(String label, dynamic route) {
    if (userRole == UrlConstants.SURVEYOR &&
        (label == UrlConstants.routePending ||
            label == UrlConstants.routeProcessing)) {
      return route.acceptBy == 0 ? "Accept" : "Go to map";
    } else if (userRole != UrlConstants.SURVEYOR) {
      // if (label == UrlConstants.routePending) return "Delete";
      if (label == UrlConstants.routeUnComplete && route.reallocation == 1)
        return "Re-Allocate";
    }
    return "";
  }

  IconData? _getButtonIcon(String label, dynamic route) {
    if (userRole == UrlConstants.SURVEYOR &&
        (label == UrlConstants.routePending ||
            label == UrlConstants.routeProcessing)) {
      return route.acceptBy == 0 ? Icons.check_circle_outline : Icons
          .location_on_rounded;
    } else if (userRole != UrlConstants.SURVEYOR) {
      // if (label == UrlConstants.routePending) return Icons.delete;
      if (label == UrlConstants.routeUnComplete && route.reallocation == 1)
        return Icons.sync_alt;
    } else if (label == UrlConstants.routeComplete) {
      return Icons.picture_as_pdf;
    }

    return null;
  }

  Color? _getButtonColor(String label, dynamic route) {
    if (userRole == UrlConstants.SURVEYOR &&
        (label == UrlConstants.routePending ||
            label == UrlConstants.routeProcessing)) {
      return route.acceptBy == 0 ? AppColors.green : AppColors.primary;
    } else if (userRole != UrlConstants.SURVEYOR) {
      // if (label == UrlConstants.routePending) return Colors.red;
      if (label == UrlConstants.routeUnComplete && route.reallocation == 1)
        return Colors.orange;
    }
    return null;
  }


}
