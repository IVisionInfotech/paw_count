// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class UserModel extends _UserModel
    with RealmEntity, RealmObjectBase, RealmObject {
  UserModel(
    int? id, {
    int? userId,
    String? name,
    String? email,
    String? password,
    String? originalPassword,
    String? role,
    String? contact,
    String? profileLogo,
    String? address,
    int? stateId,
    int? superAdminId,
    int? adminId,
    int? subAdminId,
    int? assignCityId,
    String? registeredDeviceId,
    int? ownership,
    int? changeBorder,
    int? status,
    int? deletestatus,
    int? otp,
    int? time,
    String? createdAt,
    String? updatedAt,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'password', password);
    RealmObjectBase.set(this, 'originalPassword', originalPassword);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'contact', contact);
    RealmObjectBase.set(this, 'profileLogo', profileLogo);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'stateId', stateId);
    RealmObjectBase.set(this, 'superAdminId', superAdminId);
    RealmObjectBase.set(this, 'adminId', adminId);
    RealmObjectBase.set(this, 'subAdminId', subAdminId);
    RealmObjectBase.set(this, 'assignCityId', assignCityId);
    RealmObjectBase.set(this, 'registeredDeviceId', registeredDeviceId);
    RealmObjectBase.set(this, 'ownership', ownership);
    RealmObjectBase.set(this, 'changeBorder', changeBorder);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'deletestatus', deletestatus);
    RealmObjectBase.set(this, 'otp', otp);
    RealmObjectBase.set(this, 'time', time);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  UserModel._();

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;
  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get userId => RealmObjectBase.get<int>(this, 'userId') as int?;
  @override
  set userId(int? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get password =>
      RealmObjectBase.get<String>(this, 'password') as String?;
  @override
  set password(String? value) => RealmObjectBase.set(this, 'password', value);

  @override
  String? get originalPassword =>
      RealmObjectBase.get<String>(this, 'originalPassword') as String?;
  @override
  set originalPassword(String? value) =>
      RealmObjectBase.set(this, 'originalPassword', value);

  @override
  String? get role => RealmObjectBase.get<String>(this, 'role') as String?;
  @override
  set role(String? value) => RealmObjectBase.set(this, 'role', value);

  @override
  String? get contact =>
      RealmObjectBase.get<String>(this, 'contact') as String?;
  @override
  set contact(String? value) => RealmObjectBase.set(this, 'contact', value);

  @override
  String? get profileLogo =>
      RealmObjectBase.get<String>(this, 'profileLogo') as String?;
  @override
  set profileLogo(String? value) =>
      RealmObjectBase.set(this, 'profileLogo', value);

  @override
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  int? get stateId => RealmObjectBase.get<int>(this, 'stateId') as int?;
  @override
  set stateId(int? value) => RealmObjectBase.set(this, 'stateId', value);

  @override
  int? get superAdminId =>
      RealmObjectBase.get<int>(this, 'superAdminId') as int?;
  @override
  set superAdminId(int? value) =>
      RealmObjectBase.set(this, 'superAdminId', value);

  @override
  int? get adminId => RealmObjectBase.get<int>(this, 'adminId') as int?;
  @override
  set adminId(int? value) => RealmObjectBase.set(this, 'adminId', value);

  @override
  int? get subAdminId => RealmObjectBase.get<int>(this, 'subAdminId') as int?;
  @override
  set subAdminId(int? value) => RealmObjectBase.set(this, 'subAdminId', value);

  @override
  int? get assignCityId =>
      RealmObjectBase.get<int>(this, 'assignCityId') as int?;
  @override
  set assignCityId(int? value) =>
      RealmObjectBase.set(this, 'assignCityId', value);

  @override
  String? get registeredDeviceId =>
      RealmObjectBase.get<String>(this, 'registeredDeviceId') as String?;
  @override
  set registeredDeviceId(String? value) =>
      RealmObjectBase.set(this, 'registeredDeviceId', value);

  @override
  int? get ownership => RealmObjectBase.get<int>(this, 'ownership') as int?;
  @override
  set ownership(int? value) => RealmObjectBase.set(this, 'ownership', value);

  @override
  int? get changeBorder =>
      RealmObjectBase.get<int>(this, 'changeBorder') as int?;
  @override
  set changeBorder(int? value) =>
      RealmObjectBase.set(this, 'changeBorder', value);

  @override
  int? get status => RealmObjectBase.get<int>(this, 'status') as int?;
  @override
  set status(int? value) => RealmObjectBase.set(this, 'status', value);

  @override
  int? get deletestatus =>
      RealmObjectBase.get<int>(this, 'deletestatus') as int?;
  @override
  set deletestatus(int? value) =>
      RealmObjectBase.set(this, 'deletestatus', value);

  @override
  int? get otp => RealmObjectBase.get<int>(this, 'otp') as int?;
  @override
  set otp(int? value) => RealmObjectBase.set(this, 'otp', value);

  @override
  int? get time => RealmObjectBase.get<int>(this, 'time') as int?;
  @override
  set time(int? value) => RealmObjectBase.set(this, 'time', value);

  @override
  String? get createdAt =>
      RealmObjectBase.get<String>(this, 'createdAt') as String?;
  @override
  set createdAt(String? value) => RealmObjectBase.set(this, 'createdAt', value);

  @override
  String? get updatedAt =>
      RealmObjectBase.get<String>(this, 'updatedAt') as String?;
  @override
  set updatedAt(String? value) => RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<UserModel>> get changes =>
      RealmObjectBase.getChanges<UserModel>(this);

  @override
  Stream<RealmObjectChanges<UserModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserModel>(this, keyPaths);

  @override
  UserModel freeze() => RealmObjectBase.freezeObject<UserModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'userId': userId.toEJson(),
      'name': name.toEJson(),
      'email': email.toEJson(),
      'password': password.toEJson(),
      'originalPassword': originalPassword.toEJson(),
      'role': role.toEJson(),
      'contact': contact.toEJson(),
      'profileLogo': profileLogo.toEJson(),
      'address': address.toEJson(),
      'stateId': stateId.toEJson(),
      'superAdminId': superAdminId.toEJson(),
      'adminId': adminId.toEJson(),
      'subAdminId': subAdminId.toEJson(),
      'assignCityId': assignCityId.toEJson(),
      'registeredDeviceId': registeredDeviceId.toEJson(),
      'ownership': ownership.toEJson(),
      'changeBorder': changeBorder.toEJson(),
      'status': status.toEJson(),
      'deletestatus': deletestatus.toEJson(),
      'otp': otp.toEJson(),
      'time': time.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserModel value) => value.toEJson();
  static UserModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        UserModel(
          fromEJson(ejson['id']),
          userId: fromEJson(ejson['userId']),
          name: fromEJson(ejson['name']),
          email: fromEJson(ejson['email']),
          password: fromEJson(ejson['password']),
          originalPassword: fromEJson(ejson['originalPassword']),
          role: fromEJson(ejson['role']),
          contact: fromEJson(ejson['contact']),
          profileLogo: fromEJson(ejson['profileLogo']),
          address: fromEJson(ejson['address']),
          stateId: fromEJson(ejson['stateId']),
          superAdminId: fromEJson(ejson['superAdminId']),
          adminId: fromEJson(ejson['adminId']),
          subAdminId: fromEJson(ejson['subAdminId']),
          assignCityId: fromEJson(ejson['assignCityId']),
          registeredDeviceId: fromEJson(ejson['registeredDeviceId']),
          ownership: fromEJson(ejson['ownership']),
          changeBorder: fromEJson(ejson['changeBorder']),
          status: fromEJson(ejson['status']),
          deletestatus: fromEJson(ejson['deletestatus']),
          otp: fromEJson(ejson['otp']),
          time: fromEJson(ejson['time']),
          createdAt: fromEJson(ejson['createdAt']),
          updatedAt: fromEJson(ejson['updatedAt']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserModel, 'UserModel', [
      SchemaProperty('id', RealmPropertyType.int,
          optional: true, primaryKey: true),
      SchemaProperty('userId', RealmPropertyType.int, optional: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('password', RealmPropertyType.string, optional: true),
      SchemaProperty('originalPassword', RealmPropertyType.string,
          optional: true),
      SchemaProperty('role', RealmPropertyType.string, optional: true),
      SchemaProperty('contact', RealmPropertyType.string, optional: true),
      SchemaProperty('profileLogo', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('stateId', RealmPropertyType.int, optional: true),
      SchemaProperty('superAdminId', RealmPropertyType.int, optional: true),
      SchemaProperty('adminId', RealmPropertyType.int, optional: true),
      SchemaProperty('subAdminId', RealmPropertyType.int, optional: true),
      SchemaProperty('assignCityId', RealmPropertyType.int, optional: true),
      SchemaProperty('registeredDeviceId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('ownership', RealmPropertyType.int, optional: true),
      SchemaProperty('changeBorder', RealmPropertyType.int, optional: true),
      SchemaProperty('status', RealmPropertyType.int, optional: true),
      SchemaProperty('deletestatus', RealmPropertyType.int, optional: true),
      SchemaProperty('otp', RealmPropertyType.int, optional: true),
      SchemaProperty('time', RealmPropertyType.int, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.string, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
