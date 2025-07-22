import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/generated/FontHelper.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:uuid/uuid.dart';

class DogColorController extends GetxController {
  final dogColorName = ''.obs;
  final description = ''.obs;

  final dogColorList = <DogTypeModel>[].obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadDogColor();
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
      dogColorName.value = nameController.text;
      description.value = descController.text;
    } else {
      nameController.clear();
      descController.clear();
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              dogModel == null ? "Add Dog Color" : "Edit Dog Color",
              style: FontHelper.bold(fontSize: 18, color: Colors.black),
            ),
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomInputField(
                    controller: nameController,
                    labelText: "",
                    hintText: "Dog Color Name",
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
                      foregroundColor: Colors.grey[700],
                      side: const BorderSide(color: Colors.grey),
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      dogColorName.value = nameController.text;
                      description.value = descController.text;
                      Get.back();
                      await saveOrUpdateDogType(dogModel: dogModel);
                    },
                    child: Text(
                      dogModel == null ? "Save" : "Update",
                      style: FontHelper.bold(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> saveOrUpdateDogType({DogTypeModel? dogModel}) async {
    if (dogColorName.isEmpty) {
      CommonUtils.buildSnackBar(
        "Please fill all required fields.",
        "Error",
        Colors.red,
        2,
      );
      return;
    }
    isLoadingEdit(true);
    errorMessage("");

    final Map<String, dynamic> body = {
      'id': dogModel?.id,
      'name': dogColorName.value,
      'description': description.value,
    };

    String url;
    if (dogModel != null) {
      url = UrlConstants.dogColorUpdate;
    } else {
      url = UrlConstants.dogColorCreate;
    }

    final response = await CommonUtils.callApi(url: url, body: body);
    isLoadingEdit(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
      return;
    }

    if (response.status == 1) {
      CommonUtils.buildSnackBar(
        dogModel == null ? "Dog Color saved!" : "Dog Color updated!",
        "Success",
        AppColors.green,
        2,
      );

      final data = response.dogDetails;
      _clearFields();

      if (dogModel == null) {
        dogColorList.insert(0, data!);
      } else {
        final index = dogColorList.indexWhere((dog) => dog.id == data!.id);
        if (index != -1) {
          dogColorList[index] = data!;
          dogColorList.refresh();
        }
      }
    } else {
      errorMessage(response.message ?? 'Operation failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }


  Future<void> deleteDogColor(String id) async {
    isLoadingEdit(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: "${UrlConstants.dogColorDelete}/$id",
      method: "GET",
    );

    isLoadingEdit(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
      return;
    }

    if (response.status == 1) {
      CommonUtils.buildSnackBar("Dog Color deleted!", "Deleted", Colors.red, 2);
      dogColorList.removeWhere((d) => d.id.toString() == id);
      dogColorList.refresh();
    } else {
      errorMessage(response.message ?? 'Deletion failed.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }

  Future<void> loadDogColor() async {
    isLoading(true);
    errorMessage("");
    dogColorList.clear();
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogColorFetchAll,
      method: "GET",
    );

    isLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
      return;
    }

    if (response.status == 1) {
      dogColorList.addAll(response.dogDetailsList!);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
      CommonUtils.buildSnackBar(errorMessage.value, "Error", Colors.red, 2);
    }
  }

  void _clearFields() {
    dogColorName.value = '';
    description.value = '';
  }
}
