class User {
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
  String? superAdminName;
  String? adminName;
  String? subAdminName;
  int? adminValue;
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

  User( {this.userId,
    this.name,
    this.email,
    this.password,
    this.originalPassword,
    this.role,
    this.contact,
    this.profileLogo,
    this.address,
    this.stateId,
    this.superAdminId,
    this.adminId,
    this.subAdminId,
    this.superAdminName,
    this.adminName,
    this.subAdminName,
    this.adminValue,
    this.assignCityId,
    this.registeredDeviceId,
    this.ownership,
    this.changeBorder,
    this.status,
    this.deletestatus,
    this.otp,
    this.time,
    this.createdAt,
    this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    originalPassword = json['original_password'];
    role = json['role'];
    contact = json['contact'];
    profileLogo = json['profile_logo'];
    address = json['address'];
    stateId = json['state_id'];
    superAdminId = json['super_admin_id'];
    adminId = json['admin_id'];
    subAdminId = json['sub_admin_id'];
    superAdminName = json['super_admin_name'];
    adminName = json['admin_name'];
    subAdminName = json['sub_admin_name'];
    adminValue = json['admin_value'];
    assignCityId = json['assign_city_id'];
    registeredDeviceId = json['registered_device_id'];
    ownership = json['ownership'];
    changeBorder = json['change_border'];
    status = json['status'];
    deletestatus = json['deletestatus'];
    otp = json['otp'];
    time = json['time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = userId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['original_password'] = originalPassword;
    data['role'] = role;
    data['contact'] = contact;
    data['profile_logo'] = profileLogo;
    data['address'] = address;
    data['state_id'] = stateId;
    data['super_admin_id'] = superAdminId;
    data['admin_id'] = adminId;
    data['sub_admin_id'] = subAdminId;
    data['super_admin_name'] = superAdminName;
    data['admin_name'] = adminName;
    data['sub_admin_name'] = subAdminName;
    data['admin_value'] = adminValue;
    data['assign_city_id'] = assignCityId;
    data['registered_device_id'] = registeredDeviceId;
    data['ownership'] = ownership;
    data['change_border'] = changeBorder;
    data['status'] = status;
    data['deletestatus'] = deletestatus;
    data['otp'] = otp;
    data['time'] = time;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
