import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:survey_dogapp/model/User.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/staff_dog_model.dart';
import 'package:survey_dogapp/utils/Common.dart';
import 'package:survey_dogapp/utils/Constant.dart';

class StaffDogController extends GetxController {
  final User user;

  StaffDogController(this.user);

  var staffDogList = <StaffDogModel>[].obs;
  var filteredStaffDogList = <StaffDogModel>[].obs;
  var dogTypeList = <DogTypeModel>[].obs;
  var isShimmerLoading = false.obs;
  var isLoading = false.obs;
  var errorMessage = "".obs;

  var selectedStartDate = Rxn<DateTime>();
  var selectedEndDate = Rxn<DateTime>();

  var selectedDogTypes = <DogTypeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    staffDogFetch();
    dogTypeFetch();
  }

  Future<void> dogTypeFetch() async {
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.dogTypeFetchAll,
      method: "GET",
    );

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      dogTypeList.assignAll(response.dogTypeList ?? []);
    } else {
      errorMessage(response.message ?? 'Failed to fetch dog types.');
    }
  }

  Future<void> staffDogFetch() async {
    isShimmerLoading(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: "${UrlConstants.staff}?user_id=${user.userId}",
      body: {'action': "list"},
    );

    isShimmerLoading(false);

    if (response == null) {
      errorMessage('Connection failed. Check your internet.');
      return;
    }

    if (response.status == 1) {
      staffDogList.assignAll(response.staffDoglist ?? []);
      filteredStaffDogList.assignAll(response.staffDoglist ?? []);
    } else {
      errorMessage(response.message ?? 'Failed to fetch staff dogs.');
    }
  }

  void applyFilters() {
    List<StaffDogModel> list = List.from(staffDogList);

    if (selectedStartDate.value != null || selectedEndDate.value != null) {
      list = list.where((dog) {
        if (dog.createdAt == null) return false;

        DateTime dogDate = DateTime.tryParse(dog.createdAt!) ?? DateTime(2000);

        if (selectedStartDate.value != null &&
            dogDate.isBefore(selectedStartDate.value!)) {
          return false;
        }
        if (selectedEndDate.value != null &&
            dogDate.isAfter(selectedEndDate.value!)) {
          return false;
        }
        return true;
      }).toList();
    }

    if (selectedDogTypes.isNotEmpty) {
      final selectedIds = selectedDogTypes.map((e) => e.id).toList();
      list = list.where((dog) => selectedIds.contains(dog.dogTypeId)).toList();
    }

    filteredStaffDogList.assignAll(list);
  }

  var downloadProgress = 0.0.obs;

  Future<void> fetchReport(BuildContext context) async {
    try {
      isLoading(true);
      downloadProgress.value = 0.0;

      Map<String, dynamic> body = {};

      if (user.userId != null && user.userId.toString().isNotEmpty) {
        body['user_id'] = user.userId;
      }

      if (selectedDogTypes.isNotEmpty) {
        body['dog_type_id'] = selectedDogTypes.map((f) => f.id).join(',');
      }

      if (selectedStartDate.value != null) {
        body['start_date'] = selectedStartDate.value!
            .toIso8601String()
            .split('T')
            .first;
      }

      if (selectedEndDate.value != null) {
        body['end_date'] = selectedEndDate.value!
            .toIso8601String()
            .split('T')
            .first;
      }


      final response = await CommonUtils.callApi(
        url: '${UrlConstants.staff}/report',
        method: 'POST',
        body: body,
      );

      if (response != null && response.status == 1 && response.pdfurl != null) {
        final fileName = "PawCount_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
        final downloads = Directory('/storage/emulated/0/Download/PawCount');

        if (!(await downloads.exists())) {
          await downloads.create(recursive: true);
        }

        final savePath = "${downloads.path}/$fileName";

        final dio = Dio();

        Get.dialog(
          Obx(() => AlertDialog(
            title: const Text("Downloading..."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: downloadProgress.value,
                ),
                const SizedBox(height: 10),
                Text("${(downloadProgress.value * 100).toStringAsFixed(0)}%"),
              ],
            ),
          )),
          barrierDismissible: false,
        );

        final res = await dio.download(
          response.pdfurl!,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              downloadProgress.value = received / total;
            }
          },
        );

        if (Get.isDialogOpen!) Get.back();

        if (res.statusCode == 200) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Download Complete'),
              content: Text('Saved to:\n$savePath'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    OpenFilex.open(savePath);
                  },
                  child: const Text('Open'),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar("Download Failed", "Could not download the PDF.");
        }
      } else {
        Get.snackbar("Failed", response?.message ?? 'Something went wrong');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}

