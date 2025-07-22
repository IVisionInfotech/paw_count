import 'package:google_maps_flutter/google_maps_flutter.dart';
// State Model
class StateModel {
  int? id;
  String? name;
  StateModel({required this.id, required this.name});
}
// Updated City Model
class City {
  int? id;
  String? name;
  int? stateId;
  List<List<LatLng>> borderCoordinates;
  City({this.id, this.name, this.stateId, this.borderCoordinates = const []});
}
class Zone {
  int? id;
  String? name;
  int? cityId;
  double? latitude;
  double? longitude;
  Zone({this.id, this.name, this.cityId, this.latitude, this.longitude});
}
class Ward {
  int? id;
  String? name;
  int? zoneId;
  String? wardNo;
  Ward({this.id, this.name, this.zoneId, this.wardNo});
}
class Area {
  int? id;
  String? name;
  int? wardId;
  Area({this.id, this.name, this.wardId});
}