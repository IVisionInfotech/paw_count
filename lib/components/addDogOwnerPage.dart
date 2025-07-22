import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:survey_dogapp/components/MapsScreen/address_picker_page.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/common/custom_input_field.dart';
import 'package:survey_dogapp/components/common/custom_image_shimmer_effect.dart';
import 'package:survey_dogapp/components/theme.dart';
import 'package:survey_dogapp/cotroller/dogOwnerController.dart';
import 'package:survey_dogapp/generated/assets.dart';
import 'package:survey_dogapp/model/dogOwner.dart';

class AddDogOwnerPage extends StatefulWidget {
  final DogOwner? dogOwnerModel;

  const AddDogOwnerPage({super.key, this.dogOwnerModel});

  @override
  State<AddDogOwnerPage> createState() => _AddDogOwnerPageState();
}

class _AddDogOwnerPageState extends State<AddDogOwnerPage> {
  final _formKey = GlobalKey<FormState>();
  final DogOwnerController controller =
      Get.isRegistered<DogOwnerController>()
          ? Get.find<DogOwnerController>()
          : Get.put(DogOwnerController());

  @override
  void initState() {
    super.initState();
    controller.resetForm();
    controller.loadBreedsList();
    controller.loadColorList();
    if (widget.dogOwnerModel != null) {
      controller.fillOwnerDetails(widget.dogOwnerModel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          color: AppColors.background,
          child: Column(
            children: [
              CustomAppbar.cusAppBarWidget(
                widget.dogOwnerModel != null
                    ? "Edit pet owner"
                    : "Create pet owner",
                20,
                context,
                    () => Get.back(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Obx(
                          () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildImagePicker(
                                    image: controller.profileImage.value,
                                    imageUrl: controller.profileImageUri.value,
                                    onTap: () => controller.pickImageDialog(isDog: false),
                                    icon: Icons.person,
                                    iconColor: Colors.white,
                                    bgColor: Colors.blue,
                                    placeholderAsset:
                                    Assets.imagesIcProfilePlaceholder,
                                  ),
                                  const SizedBox(width: 20),
                                  _buildImagePicker(
                                    image: controller.dogImage.value,
                                    imageUrl: controller.dogImageUri.value,
                                    onTap: () => controller.pickImageDialog(isDog: true),
                                    icon: Icons.pets,
                                    iconColor: Colors.white,
                                    bgColor: Colors.green,
                                    placeholderAsset: Assets.imagesDogImg,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            labelText: "Owner name",
                            hintText: "Enter owner name",
                            controller: controller.nameController,
                            validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter owner name'
                                : null,
                          ),
                          CustomInputField(
                            labelText: "Mobile number",
                            hintText: "Enter mobile number",
                            controller: controller.contactController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter mobile number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                                return 'Enter valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                          CustomInputField(
                            labelText: "Pet name",
                            hintText: "Enter pet name",
                            controller: controller.petNameController,
                            validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter pet name'
                                : null,
                          ),
                          CustomInputField(
                            labelText: "Rfid number",
                            hintText: "Enter rfid number",
                            controller: controller.rfidController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(15),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter rfid number';
                              }
                              if (!RegExp(r'^\d{15}$').hasMatch(value.trim())) {
                                return 'Enter valid 15-digit rfid number';
                              }
                              return null;
                            },
                          ),
                          Obx(
                                () => CustomInputField(
                              labelText: "Select dog breeds",
                              hintText: "Select dog breeds",
                              isDropdown: true,
                              items: controller.breedOptions
                                  .map((breed) => breed.name)
                                  .whereType<String>()
                                  .toList(),
                              selectedValue: controller.breedOptions
                                  .firstWhereOrNull((breed) =>
                              breed.id == controller.selectedBreed.value)
                                  ?.name,
                              onChanged: (val) {
                                controller.selectedBreed.value =
                                    controller.breedOptions
                                        .firstWhereOrNull((breed) =>
                                    breed.name == val)
                                        ?.id ??
                                        0;
                              },
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Select dog breeds'
                                  : null,
                            ),
                          ),
                          Obx(
                                () => CustomInputField(
                              labelText: "Select dog color",
                              hintText: "Select dog color",
                              isDropdown: true,
                              items: controller.colorOptions
                                  .map((color) => color.name)
                                  .whereType<String>()
                                  .toList(),
                              selectedValue: controller.colorOptions
                                  .firstWhereOrNull((color) =>
                              color.id == controller.selectedColor.value)
                                  ?.name,
                              onChanged: (val) {
                                controller.selectedColor.value =
                                    controller.colorOptions
                                        .firstWhereOrNull((color) =>
                                    color.name == val)
                                        ?.id ??
                                        0;
                              },
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Select dog color'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Gender",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Obx(
                                () => Row(
                              children: [
                                Radio<String>(
                                  value: 'Male',
                                  groupValue: controller.selectedGender.value,
                                  onChanged: (value) {
                                    controller.selectedGender.value = value!;
                                  },
                                ),
                                const Text('Male'),
                                Radio<String>(
                                  value: 'Female',
                                  groupValue: controller.selectedGender.value,
                                  onChanged: (value) {
                                    controller.selectedGender.value = value!;
                                  },
                                ),
                                const Text('Female'),
                              ],
                            ),
                          ),
                          Obx(
                                () => controller.selectedGender.value.isEmpty ||
                                (controller.selectedGender.value != 'Male' &&
                                    controller.selectedGender.value !=
                                        'Female')
                                ? const Padding(
                              padding: EdgeInsets.only(left: 12.0, top: 4.0),
                              child: Text(
                                "Please select gender",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => controller.calculateAgeFromDOB(context),
                            child: AbsorbPointer(
                              child: CustomInputField(
                                controller: controller.dobController,
                                labelText: "Select DOB",
                                hintText: "Tap to select DOB",
                                validator: (val) =>
                                val == null || val.isEmpty
                                    ? 'Select DOB'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomInputField(
                            controller: controller.ageController,
                            labelText: "Enter Age",
                            hintText: "Enter age in years",
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              controller.calculateDOBFromAge();
                            },
                            validator: (val) {
                              if (val != null && int.tryParse(val) == null) {
                                return 'Enter valid age';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomInputField(
                            controller: controller.addressController,
                            labelText: "Address",
                            readOnly: true,
                            maxLines: 2,
                            hintText: "Enter address",
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final selectedAddress = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddressPickerPage()),
                              );
                              if (selectedAddress != null) {
                                final address = selectedAddress['address'] ?? '';
                                final latLong = selectedAddress['lat_long'] ?? '';

                                controller.addressController.text = address;
                                controller.latLong.value = latLong;
                              }
                            },
                            validator: (val) {
                              if (val != null && val.trim().isEmpty) {
                                return 'Enter valid address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomInputField(
                            controller: controller.manuallyAddressController,
                            labelText: "Manually Address",
                            hintText: "Enter manually Address",
                            maxLines: 2,
                            onChanged: (val) {
                              controller.calculateDOBFromAge();
                            },
                            validator: (val) {
                              if (val != null && val.trim().isEmpty) {
                                return 'Enter manually Address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Obx(
                      () =>
                  controller.isLoadingEdit.value
                      ? const CircularProgressIndicator()
                      : CustomFormButton(
                    innerText: widget.dogOwnerModel != null ? "Update" : "Submit",
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        int dogId = widget.dogOwnerModel?.id ?? 0;
                        controller.saveDogOwner(dogId);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildImagePicker({
    required dynamic image,
    required String imageUrl,
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String placeholderAsset,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: ClipOval(
                child:
                    image != null
                        ? Image.file(image, fit: BoxFit.cover)
                        : imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  CommonShimmer(width: 100, height: 100),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                        )
                        : Image.asset(placeholderAsset, fit: BoxFit.scaleDown),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(icon, size: 15, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
