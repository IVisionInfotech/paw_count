import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:survey_dogapp/components/theme.dart';

class ImagePickerUtil {
  final ImagePicker picker = ImagePicker();

  void pickImageDialog({
    required Function(File) onImageSelected,
    required Function(String) onError,
    bool onlyCamera = false,
  }) {
    if (onlyCamera) {
      pickImage(ImageSource.camera, onImageSelected, onError);
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: Colors.deepPurple),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery, onImageSelected, onError);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.red),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera, onImageSelected, onError);
              },
            ),
          ],
        ),
      ),
    );
  }


  Future<void> pickImage(
      ImageSource source,
      Function(File) onImageSelected,
      Function(String) onError) async {
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          AndroidUiSettings(
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: AppColors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (cropped != null) {
        final file = File(cropped.path);

        final compressedFile = await compressImage(file);

        if (compressedFile != null) {
          onImageSelected(compressedFile);
        } else {
          onError("Image compression failed.");
        }
      } else {
        onError("Image cropping failed.");
      }
    } else {
      onError("No image selected.");
    }
  }

  Future<File?> compressImage(File file, {int maxSizeInKB = 500}) async {
    final targetPath =
        '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
    int quality = 90;
    File? result;

    for (; quality >= 10; quality -= 10) {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressed != null &&
          await compressed.length() <= maxSizeInKB * 1024) {
        result = File(compressed.path);
        break;
      }
    }

    return result;
  }
}
