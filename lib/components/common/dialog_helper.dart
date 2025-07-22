import 'package:flutter/material.dart';
import 'package:survey_dogapp/components/theme.dart';

import '../../generated/FontHelper.dart';

class DialogHelper {
  static void showCommonDialog({
    required BuildContext context,
    IconData? icon,
    required Color iconColor,
    required String title,
    required String subTitle,
    required String negativeText,
    required String positiveText,
    required VoidCallback onPositivePressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Icon
                Center(child: Icon(icon, size: 48, color: iconColor)),
                const SizedBox(height: 16),

                // Title
                Center(
                  child: Text(
                    title,
                    style: FontHelper.bold(fontSize: 20, color: iconColor),
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Center(
                  child: Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: FontHelper.regular(
                      fontSize: 16,
                      color: const Color(0xFF444444),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(negativeText, style: FontHelper.regular()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // Navigator.of(context).pop();
                          onPositivePressed();
                        },
                        child: Text(
                          positiveText,
                          style: FontHelper.bold(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
