import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/City/cotroller/LocationController.dart';
import 'package:survey_dogapp/components/Dashboard/dashboard.dart';
import 'package:survey_dogapp/components/staff_management_screen.dart';
import 'package:survey_dogapp/model/User.dart';
import '../model/user_model.dart';
import '../utils/Common.dart';
import '../utils/Constant.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isLoadingProject = false.obs;
  var errorMessage = "".obs;

  var stateList = <LocationModel>[].obs;
  var cityList = <LocationModel>[].obs;

  User? userModel;
  RxInt selectedStateId = 0.obs;
  RxInt selectedCityId = 0.obs;
  RxInt selectedAdminId = 0.obs;
  RxInt selectedSubAdminId = 0.obs;


  Future<String?> getOneSignalPlayerIdWithRetry({int maxTries = 10}) async {
    for (int i = 0; i < maxTries; i++) {
      String? playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null) return playerId;
      await Future.delayed(Duration(milliseconds: 500));
    }
    return null;
  }

  Future<bool> login(String username, String password) async {
    isLoading(true);
    errorMessage("");

    final deviceId = await CommonUtils.getDeviceId();
    String? playerId = await getOneSignalPlayerIdWithRetry();

    final response = await CommonUtils.callApi(
      url: UrlConstants.loginUrl,
      headers: {'Content-Type': 'application/json'},
      body: {
        'username': username,
        'password': password,
        'device_id': deviceId,
        'player_id': playerId
      },
    );

    if (response == null) {
      errorMessage('Connection failed. Please check your internet.');
      isLoading(false);
      return false;
    }

    isLoading(false);
    if (response.status == 1) {
      final user = response.user;
      if (user != null) {
        if(user.role == UrlConstants.SUPER_ADMIN){
          final u = user;
          CommonUtils.saveToRealm<UserModel>(
            UserModel(
              0,
              userId: u.userId ?? 0,
              name: u.name ?? '',
              email: u.email ?? '',
              password: u.password ?? '',
              originalPassword: u.originalPassword ?? '',
              role: u.role ?? '',
              contact: u.contact ?? '',
              profileLogo: u.profileLogo ?? '',
              address: u.address ?? '',
              stateId: u.stateId ?? 0,
              superAdminId: u.superAdminId ?? 0,
              adminId: u.adminId ?? 0,
              subAdminId: u.subAdminId ?? 0,
              assignCityId: u.assignCityId ?? 0,
              registeredDeviceId: u.registeredDeviceId ?? '',
              ownership: u.ownership ?? 0,
              changeBorder: u.changeBorder ?? 0,
              status: u.status ?? 0,
              deletestatus: u.deletestatus ?? 0,
              otp: u.otp ?? 0,
              time: u.time ?? 0,
              createdAt: u.createdAt ?? '',
              updatedAt: u.updatedAt ?? '',
            ),
            UserModel.schema,
          );
        }else{
          userModel = user;
        }


        selectedStateId.value = 0;
        selectedCityId.value = 0;
        selectedAdminId.value = 0;
        selectedSubAdminId.value = 0;
        stateList.assignAll(response.state!);
        cityList.assignAll(response.cities!);
        return true;
      } else {
        errorMessage(response.message ?? "Invalid user data received.");
        return false;
      }
    } else {
      errorMessage(response.message ?? 'Login failed.');
      return false;
    }
  }

  Future<bool> onSubmitProject() async {
    isLoadingProject(true);
    errorMessage("");

    final response = await CommonUtils.callApi(
      url: UrlConstants.setDataUrl,
      body: {
        'user_id': userModel!.userId,
        'city_id': selectedCityId.value != 0 ? selectedCityId.value : '',
        'state_id': selectedStateId.value != 0 ? selectedStateId.value : '',
        'subadmin_id':
        selectedSubAdminId.value != 0 ? selectedSubAdminId.value : '',
        'admin_id': selectedAdminId.value != 0 ? selectedAdminId.value : '',
      },
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': UrlConstants.apiKey,
        'username': userModel!.email!,
        'password': userModel!.originalPassword!,
        'x-device-id': await CommonUtils.getDeviceId(),
      },
    );

    if (response == null) {
      errorMessage('Connection failed. Please check your internet.');
      isLoadingProject(false);
      return false;
    }

    isLoadingProject(false);
    if (response.status == 1) {
      if (response.user != null) {
        final u = response.user!;
        CommonUtils.saveToRealm<UserModel>(
          UserModel(
            0,
            userId: u.userId ?? 0,
            name: u.name ?? '',
            email: u.email ?? '',
            password: u.password ?? '',
            originalPassword: u.originalPassword ?? '',
            role: u.role ?? '',
            contact: u.contact ?? '',
            profileLogo: u.profileLogo ?? '',
            address: u.address ?? '',
            stateId: u.stateId ?? 0,
            superAdminId: u.superAdminId ?? 0,
            adminId: u.adminId ?? 0,
            subAdminId: u.subAdminId ?? 0,
            assignCityId: u.assignCityId ?? 0,
            registeredDeviceId: u.registeredDeviceId ?? '',
            ownership: u.ownership ?? 0,
            changeBorder: u.changeBorder ?? 0,
            status: u.status ?? 0,
            deletestatus: u.deletestatus ?? 0,
            otp: u.otp ?? 0,
            time: u.time ?? 0,
            createdAt: u.createdAt ?? '',
            updatedAt: u.updatedAt ?? '',
          ),
          UserModel.schema,
        );
        Get.put(LocationController());
        if (CommonUtils.getUserRole()?.toLowerCase() == 'staff') {
          Get.offAll(() => StaffManagementScreen());
        }else{
          Get.offAll(() => Dashboard());
        }
        return true;
      } else {
        errorMessage(response.message ?? "Invalid user data received.");
        return false;
      }
    } else {
      errorMessage(response.message ?? 'Login failed.');
      return false;
    }
  }
}
