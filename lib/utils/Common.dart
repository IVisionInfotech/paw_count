import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart';
import 'package:survey_dogapp/components/Auth/login_page.dart';
import 'package:survey_dogapp/model/ApiResponse.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../components/common/dialog_helper.dart';
import '../model/user_model.dart';
import 'Constant.dart';
import 'package:intl/intl.dart';

class CommonUtils {
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'Unknown Android ID';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'Unknown iOS ID';
    } else {
      return 'Unsupported platform';
    }
  }

  static Future<ApiResponse?> callApi({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String method = 'POST',
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        CommonUtils.buildSnackBar(
          "No Internet Connection",
          "Error",
          Colors.red,
          2,
        );
        return null;
      }

      final uri = Uri.parse(url);
      late http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            uri,
            headers:
                headers ??
                {
                  'Content-Type': 'application/json',
                  'x-api-key': UrlConstants.apiKey,
                  'username': getUserEmail()!,
                  'password': getUserPassword()!,
                  'x-device-id': await getDeviceId(),
                },
            body: jsonEncode(body),
          );
          break;
        case 'GET':
          response = await http.get(
            uri,
            headers:
                headers ??
                {
                  'Content-Type': 'application/json',
                  'x-api-key': UrlConstants.apiKey,
                  'username': getUserEmail()!,
                  'password': getUserPassword()!,
                  'x-device-id': await getDeviceId(),
                },
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers:
                headers ??
                {
                  'Content-Type': 'application/json',
                  'x-api-key': UrlConstants.apiKey,
                  'username': getUserEmail()!,
                  'password': getUserPassword()!,
                  'x-device-id': await getDeviceId(),
                },
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers:
                headers ??
                {
                  'Content-Type': 'application/json',
                  'x-api-key': UrlConstants.apiKey,
                  'username': getUserEmail()!,
                  'password': getUserPassword()!,
                  'x-device-id': await getDeviceId(),
                },
          );
          break;
        default:
          throw UnsupportedError('Method $method not supported');
      }
      CommonUtils.printLongString(
        'okhttp url $uri \n requst $body \n response ${response.body}',
      );
      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonMap);
        if (apiResponse.status == 99) {
          CommonUtils.logOut();
          CommonUtils.buildSnackBar(
            "User not verified.",
            "Error",
            Colors.red,
            2,
          );
          return null;
        }
        return apiResponse;
      } else {
        final jsonMap = jsonDecode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonMap);
        CommonUtils.buildSnackBar(
          'Something went wrong',
          "Error",
          Colors.red,
          2,
        );
        print("Something went wrong: $apiResponse");
        return null;
      }
    } catch (e) {
      CommonUtils.buildSnackBar('Something went wrong', "Error", Colors.red, 2);
      return null;
    }
  }

  static void saveToRealm<T extends RealmObject>(T data, SchemaObject schema) {
    final config = Configuration.local([schema]);
    final realm = Realm(config);

    realm.write(() {
      realm.deleteAll<T>();
      realm.add(data);
    });

    realm.close();
  }

  static void updateFieldInRealm<T extends RealmObject>(
    int id,
    void Function(T object) updateFn,
    SchemaObject schema,
  ) {
    final config = Configuration.local([schema]);
    final realm = Realm(config);

    final existing = realm.find<T>(id);

    if (existing != null) {
      realm.write(() {
        updateFn(existing);
      });
    }

    realm.close();
  }

  static UserModel? getCurrentUser() {
    final config = Configuration.local([UserModel.schema]);
    final realm = Realm(config);
    final users = realm.all<UserModel>();
    return users.isNotEmpty ? users.first : null;
  }

  static int? getUserId() => getCurrentUser()?.userId;

  static String? getUserRole() => getCurrentUser()?.role;

  static String? getUserName() => getCurrentUser()?.name;

  static String? getUserEmail() => getCurrentUser()?.email;

  static String? getUserAddress() => getCurrentUser()?.address;

  static String? getUserPassword() => getCurrentUser()?.originalPassword;

  static String? getUserContact() => getCurrentUser()?.contact;

  static String? getUserProfile() => getCurrentUser()?.profileLogo;

  static int? getUserStateId() => getCurrentUser()?.stateId;

  static int? getUserAssignCityId() => getCurrentUser()?.assignCityId;

  static void showLogoutDialog(BuildContext context) {
    final userName = getUserName() ?? "User";

    DialogHelper.showCommonDialog(
      context: context,
      icon: Icons.logout,
      iconColor: Colors.redAccent,
      title: "Logout",
      subTitle: "Hey $userName,\nAre you sure you want to logout?",
      negativeText: "Cancel",
      positiveText: "Yes, Logout",
      onPositivePressed: () {
        logOut();
      },
    );
  }

  static void buildSnackBar(
    String message,
    String title,
    Color bgColor,
    int durationSec,
  ) {
    if (message.isNotEmpty) {
      Get.snackbar(
        title,
        message,
        backgroundColor: bgColor,
        duration: Duration(seconds: durationSec),
      );
    }
  }

  static Future<bool> logOut() async {
    final response = await CommonUtils.callApi(
      url: UrlConstants.logoutUrl,
      body: {
        'user_id': CommonUtils.getUserId()
      },
    );

    if (response == null) {
      return false;
    }
    if (response.status == 1) {
      final config = Configuration.local([UserModel.schema]);
      final realm = Realm(config);

      realm.write(() {
        realm.deleteAll<UserModel>();
      });
      Get.deleteAll();
      Get.offAll(() => LoginPage());
      return true;
    }
    return false;
  }

  static void printLongString(String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      debugPrint(
        text.substring(
          i,
          i + chunkSize > text.length ? text.length : i + chunkSize,
        ),
      );
    }
  }

  static String formatDateTime(
      String dateTimeStr, {
        String inputFormat = 'yyyy-MM-dd HH:mm:ss',
        String outputFormat = 'dd-MM-yyyy HH:mm:ss',
      }) {
    try {
      final DateFormat inputFormatter = DateFormat(inputFormat);
      final DateFormat outputFormatter = DateFormat(outputFormat);
      final DateTime dateTime = inputFormatter.parse(dateTimeStr);
      return outputFormatter.format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

}
