import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';

class CustomAppbar {
  static Widget cusAppBarWidget(String title, int spaceBtw, BuildContext context, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth * 0.17,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.primary, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: onTap,
            iconSize: screenWidth * 0.06,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: FontHelper.semiBold(color: Colors.white, fontSize: screenWidth * 0.045),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );

  }
}

