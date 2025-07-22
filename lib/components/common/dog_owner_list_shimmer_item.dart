import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme.dart';

class DogOwnerListShimmerItem extends StatelessWidget {
  final int count;

  const DogOwnerListShimmerItem({Key? key, this.count = 6}) : super(key: key);

  Widget shimmerBox({double height = 14, double width = double.infinity, double radius = 8}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget shimmerCircle({double radius = 24}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return Card(
          color: AppColors.background,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              period: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      shimmerBox(height: 18, width: 100),
                      shimmerBox(height: 14, width: 60),
                    ],
                  ),
                  const SizedBox(height: 8),

                  shimmerBox(height: 14, width: 140),
                  const SizedBox(height: 6),

                  shimmerBox(height: 14, width: 160),
                  const SizedBox(height: 6),

                  // Gender, Age, Address
                  shimmerBox(height: 14, width: 200),
                  const SizedBox(height: 6),

                  shimmerBox(height: 12, width: 180),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      shimmerCircle(radius: 24),
                      const SizedBox(width: 10),
                      shimmerCircle(radius: 24),
                      const Spacer(),
                      Icon(Icons.edit, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
