import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:survey_dogapp/model/dogOwner.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';
import 'package:survey_dogapp/utils/ImagePickerUtil.dart';

class DogOwnerController extends GetxController {
  var isLoading = false.obs;
  var isLoadingEdit = false.obs;
  var isShimmerLoading = false.obs;
  var errorMessage = "".obs;

  var latLong = "".obs;
  var pincode = ''.obs;

  RxString selectedGender = 'Male'.obs;

  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final petNameController = TextEditingController();
  final rfidController = TextEditingController();
  final manuallyAddressController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();

  final selectedBreed = 0.obs;
  final selectedColor = 0.obs;
  final selectedSex = 'Male'.obs;

  var profileImage = Rxn<File>();
  final RxInt userImageUpdate = 0.obs;
  var profileImageUri = ''.obs;

  var dogImage = Rxn<File>();
  final RxInt dogImageUpdate = 0.obs;
  var dogImageUri = ''.obs;

  var breedOptions = <DogTypeModel>[].obs;
  var colorOptions = <DogTypeModel>[].obs;

  Future<void> loadBreedsList() async {
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogBreedsFetchAll,
      method: 'GET',
    );
    isLoading(false);

    if (response != null &&
        response.status == 1 &&
        response.dogDetailsList != null) {
      breedOptions.assignAll(response.dogDetailsList!);
    } else {
      breedOptions.clear();
    }
  }

  Future<void> loadColorList() async {
    final response = await CommonUtils.callApi(
      url: UrlConstants.dogColorFetchAll,
      method: 'GET',
    );
    isLoading(false);

    if (response != null &&
        response.status == 1 &&
        response.dogDetailsList != null) {
      colorOptions.assignAll(response.dogDetailsList!);
    } else {
      colorOptions.clear();
    }
  }

  var dogOwnersList = <DogOwner>[].obs;

  Future<void> fetchDogOwners() async {
    isShimmerLoading(true);
    final url = UrlConstants.allPetOwner;
    final userId = CommonUtils.getUserId().toString();
    final response = await CommonUtils.callApi(
      url: url,
      body: {'user_id': userId},
    );

    isShimmerLoading(false);

    if (response == null) {
      errorMessage('Failed to fetch users. Please check your connection.');
      return;
    }

    if (response.status == 1 && response.dogOwnerList != null) {
      dogOwnersList.clear();
      dogOwnersList.addAll(response.dogOwnerList!);
    } else {
      CommonUtils.buildSnackBar(
        response.message ?? "No users found.",
        "Error",
        Colors.red,
        2,
      );
    }
  }

  void pickImageDialog({required bool isDog}) {
    ImagePickerUtil().pickImageDialog(
      onImageSelected: (file) {
        if (isDog) {
          dogImage.value = file;
          dogImageUpdate.value = 1;
        } else {
          profileImage.value = file;
          userImageUpdate.value = 1;
        }
      },
      onError: (message) {
        CommonUtils.buildSnackBar(message, "Error", Colors.red, 2);
      },
    );
  }

  void fillOwnerDetails(DogOwner model) {
    nameController.text = model.ownerName ?? '';
    contactController.text = model.ownerContact ?? '';
    addressController.text = model.currentAddress ?? '';
    manuallyAddressController.text = model.address ?? '';
    petNameController.text = model.petName ?? '';
    rfidController.text = model.microchipNo ?? '';

    selectedBreed.value = model.dogBreed ?? 0;
    selectedColor.value = model.dogColor ?? 0;
    selectedGender.value = model.gender ?? 'Male';

    profileImageUri.value = model.ownerImage ?? '';
    dogImageUri.value = model.dogImage ?? '';

    dobController.text = model.dob ?? '';
    ageController.text = model.age?.toString() ?? '';
  }


  Future<void> saveDogOwner(int dogId) async {
    String base64ProfileImage = "";
    int updateProfileImageFlag = 0;

    String base64DogImage = "";
    int updateDogImageFlag = 0;

    if (userImageUpdate.value == 1 && profileImage.value != null) {
      final bytes = await profileImage.value!.readAsBytes();
      base64ProfileImage = "data:image/png;base64,${base64Encode(bytes)}";
      updateProfileImageFlag = 1;
    }

    if (dogImageUpdate.value == 1 && dogImage.value != null) {
      final bytes = await dogImage.value!.readAsBytes();
      base64DogImage = "data:image/png;base64,${base64Encode(bytes)}";
      updateDogImageFlag = 1;
    }

    final dateFormat = CommonUtils.formatDateTime(
      dobController.text.toString(),
      inputFormat: 'dd-MM-yyyy',
      outputFormat: 'yyyy-MM-dd',
    );

    isLoadingEdit(true);
    errorMessage("");

    final body = {
      'id': dogId,
      "owner_image": base64ProfileImage,
      "dog_image": base64DogImage,
      "owner_name": nameController.text.trim(),
      "owner_contact": contactController.text.trim(),
      "pet_name": petNameController.text.trim(),
      "dog_breed": selectedBreed.value,
      "dog_color": selectedColor.value,
      "microchip_no": rfidController.text.trim(),
      "gender": selectedGender.value,
      "dob": dateFormat,
      "age": ageController.text.trim(),
      "current_address": addressController.text.trim(),
      "address": manuallyAddressController.text.trim(),
      "lat_long": latLong.value,
      "user_id": CommonUtils.getUserId(),
      "owner_update_image": updateProfileImageFlag,
      "dog_update_image": updateDogImageFlag,
      "route_id": "",
    };

    String url;
    if (dogId != 0) {
      url = UrlConstants.editPetOwner;
    } else {
      url = UrlConstants.createPetOwner;
    }

    final response = await CommonUtils.callApi(url: url, body: body);
    isLoadingEdit(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      CommonUtils.buildSnackBar("Connection failed.", "Error", Colors.red, 2);
      return;
    }

    final message = response.message ?? "User update processed";

    if (response.status == 1 && response.dogOwnerModel != null) {
      int index = dogOwnersList.indexWhere(
        (user) => user.id == response.dogOwnerModel!.id,
      );

      if (index != -1) {
        dogOwnersList[index] = response.dogOwnerModel!;
      } else {
        dogOwnersList.insert(0, response.dogOwnerModel!);
      }
      dogOwnersList.refresh();
      Get.back();
      CommonUtils.buildSnackBar(message, "Success", Colors.green, 2);
    } else {
      CommonUtils.buildSnackBar(message, "Error", Colors.red, 2);
    }
  }

  @override
  void onClose() {
    resetForm();
    super.onClose();
  }

  void resetForm() {
    nameController.clear();
    petNameController.clear();
    rfidController.clear();
    contactController.clear();
    addressController.clear();
    manuallyAddressController.clear();
    dobController.clear();
    ageController.clear();

    selectedBreed.value = 0;
    selectedColor.value = 0;
    selectedSex.value = 'Male';
    selectedGender.value = 'Male';

    profileImage.value = null;
    profileImageUri.value = '';
    userImageUpdate.value = 0;

    dogImage.value = null;
    dogImageUri.value = '';
    dogImageUpdate.value = 0;

    latLong.value ='';
    pincode.value = '';
  }

  String formatDateToApi(String inputDate) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(inputDate.trim());
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return ''; // or handle error
    }
  }

  void calculateAgeFromDOB(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dobController.text = CommonUtils.formatDateTime(
        pickedDate.toString(),
        inputFormat: 'yyyy-MM-dd HH:mm:ss',
        outputFormat: 'dd-MM-yyyy',
      );

      final age = calculateAge(pickedDate);
      ageController.text = age.toString();
    }
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void calculateDOBFromAge() {
    final age = int.tryParse(ageController.text);
    final today = DateTime.now();

    DateTime dob;
    if (age != null && age > 0) {
      dob = DateTime(today.year - age, today.month, today.day);
    } else {
      dob = today;
    }

    dobController.text = CommonUtils.formatDateTime(
      dob.toString(),
      inputFormat: 'yyyy-MM-dd HH:mm:ss',
      outputFormat: 'dd-MM-yyyy',
    );
  }
}
