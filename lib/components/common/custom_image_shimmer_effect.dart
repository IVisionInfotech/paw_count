import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:survey_dogapp/components/theme.dart';

class CommonShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const CommonShimmer({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary.withOpacity(0.3),
      highlightColor: AppColors.primary.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
