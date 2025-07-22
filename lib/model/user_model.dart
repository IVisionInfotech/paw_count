import 'package:realm/realm.dart';

part 'user_model.realm.dart';

@RealmModel()
class _UserModel {
  @PrimaryKey()
  int? id;

  int? userId;
  String? name;
  String? email;
  String? password;
  String? originalPassword;
  String? role;
  String? contact;
  String? profileLogo;
  String? address;
  int? stateId;
  int? superAdminId;
  int? adminId;
  int? subAdminId;
  int? assignCityId;
  String? registeredDeviceId;
  int? ownership;
  int? changeBorder;
  int? status;
  int? deletestatus;
  int? otp;
  int? time;
  String? createdAt;
  String? updatedAt;
}
