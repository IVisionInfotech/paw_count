import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:survey_dogapp/utils/ImagePickerUtil.dart';
import 'package:uuid/uuid.dart';

class DogTypeController extends GetxController {
  final dogTypeName = ''.obs;
  final description = ''.obs;
  final dogImage = Rx<String?>(null);
  final dogImageFile = Rx<File?>(null);
  final dogImageUpdate = 0.obs;
  final dogTypeList = <DogTypeModel>[].obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final picker = ImagePicker();
  final uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    loadDogTypes();
  }

  var isLoading = false.obs;
  var isLoadingEdit = false.obs;
  var errorMessage = "".obs;

  RxInt shimmerIndex = (-1).obs;
  RxBool isShimmerActive = false.obs;

  void showAddDogTypeDialog(BuildContext context, {DogTypeModel? dogModel}) {
    if (dogModel != null) {
      nameController.text = dogModel.name ?? '';
      descController.text = dogModel.description ?? '';
      dogImageFile.value = null;
      dogTypeName.value = nameController.text;
      description.value = descController.text;
    } else {
      dogImageFile.value = null;
      nameController.clear();
      descController.clear();
      dogImage.value = null;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              dogModel == null ? "Add Dog Type" : "Edit Dog Type",
              style: FontHelper.bold(fontSize: 18, color: AppColors.black),
            ),
            backgroundColor: AppColors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    return GestureDetector(
                      onTap: pickImageDialog,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.grey400,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  dogImageFile.value == null
                                      ? dogModel == null
                                          ? Image.asset(
                                            Assets.imagesDogImg,
                                            fit: BoxFit.cover,
                                          )
                                          : CachedNetworkImage(
                                            imageUrl: dogModel.imagePath!,
                                            width: double.infinity,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => CommonShimmer(
                                                  width: double.infinity,
                                                  height: 100,
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  width: double.infinity,
                                                  height: 100,
                                                  color: AppColors.grey300,
                                                  alignment: Alignment.center,
                                                  child: const Icon(
                                                    Icons.error,
                                                    color: AppColors.red,
                                                  ),
                                                ),
                                          )
                                      : Image.file(
                                        dogImageFile.value!,
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.blue,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit,
                                size: 15,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: nameController,
                    labelText: "",
                    hintText: "Dog Type Name",
                    obscureText: false,
                    validator: (textValue) => null,
                  ),
                  const SizedBox(height: 12),
                  CustomInputField(
                    controller: descController,
                    labelText: "",
                    hintText: "Description",
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    validator: (textValue) => null,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.grey700,
                      side: const BorderSide(color: AppColors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel", style: FontHelper.regular()),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      dogTypeName.value = nameController.text;
                      description.value = descController.text;
                      Get.back();
                      await saveOrUpdateDogType(dogModel: dogModel);
                    },
                    child: Text(
                      dogModel == null ? "Save" : "Update",
                      style: FontHelper.bold(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> saveOrUpdateDogType({DogTypeModel? dogModel}) async {
    if (dogTypeName.isEmpty ||
        (dogModel == null && dogImageFile.value == null)) {
      CommonUtils.buildSnackBar(
        "Please fill all required fields.",
        "Error",
        AppColors.red,
        2,
      );
      return;
    }
    isLoadingEdit(true);

    errorMessage("");
    String base64Image = "";
    int updateImageFlag = 0;

    if (dogModel == null || dogImageUpdate.value == 1) {
      if (dogImageFile.value != null) {
        final bytes = await dogImageFile.value!.readAsBytes();
        base64Image = "data:image/png;base64,${base64Encode(bytes)}";
        updateImageFlag = 1;
      }
    }

    final userId = await CommonUtils.getUserId();

    final Map<String, dynamic> body = {
      'id': dogModel?.id,
      'name': dogTypeName.value,
      'description': description.value,
      'image': base64Image,
      'user_id': userId,
      'update_image': updateImageFlag,
    };

    String url;
    if (dogModel != null) {
      url = UrlConstants.dogTypeUpdate;
    } else {
      url = UrlConstants.dogTypeCreate;
    }

    final response = await CommonUtils.callApi(url: url, body: body);
    isLoadingEdit(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", AppColors.red, 2);
      return;
    }

    if (response.status == 1) {
      CommonUtils.buildSnackBar(
        dogModel == null ? "Dog Type saved!" : "Dog Type updated!",
        "Success",
        AppColors.green,
        2,
      );

      final data = response.dogTypeModel;
      _clearFields();
      Get.back();
      if (dogModel == null) {
        dogTypeList.insert(0, data!);
      } else {
        final index = dogTypeList.indexWhere((dog) => dog.id == data!.id);
        if (index != -1) {
          dogTypeList[index] = data!;
          dogTypeList.refresh();
        }
      }
    } else {
      errorMessage(response.message ?? 'Operation failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }
  }

  void pickImageDialog() {
    ImagePickerUtil().pickImageDialog(
      onImageSelected: (file) {
        dogImageFile.value = file;
        dogImageUpdate.value = 1;
      },
      onError: (message) {
        CommonUtils.buildSnackBar(message, "Error", AppColors.red, 2);
      },
    );
  }

  Future<void> deleteDogType(String id) async {
    isLoadingEdit(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: "${UrlConstants.dogTypeDelete}/$id",
      method: "GET",
    );

    isLoadingEdit(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", AppColors.red, 2);
      return;
    }

    if (response.status == 1) {
      CommonUtils.buildSnackBar("Dog Type deleted!", "Deleted", AppColors.red, 2);
      dogTypeList.removeWhere((d) => d.id.toString() == id);
      dogTypeList.refresh();
    } else {
      errorMessage(response.message ?? 'Deletion failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", AppColors.red, 2);
    }
  }

  Future<void> loadDogTypes() async {
    isLoading(true);
    errorMessage("");
    dogTypeList.clear();
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", AppColors.red, 2);
      return;
    }

    if (response.status == 1) {
      dogTypeList.addAll(response.dogTypeList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }

  void _clearFields() {
    dogTypeName.value = '';
    description.value = '';
    dogImage.value = null;
  }
}
