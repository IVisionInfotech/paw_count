class CityBorderModel {
  int? borderId;
  int? userId;
  int? cityId;
  double? lat;
  double? lng;
  int? deletestatus;
  String? createdAt;
  String? updatedAt;

  CityBorderModel({
    this.borderId,
    this.userId,
    this.cityId,
    this.lat,
    this.lng,
    this.deletestatus,
    this.createdAt,
    this.updatedAt,
  });

  factory CityBorderModel.fromJson(Map<String, dynamic> json) {
    return CityBorderModel(
      borderId: json['border_id'],
      userId: json['user_id'],
      cityId: json['city_id'],
      lat: double.tryParse(json['lat'] ?? "0"),
      lng: double.tryParse(json['lng'] ?? "0"),
      deletestatus: json['deletestatus'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    "border_id": borderId,
    "user_id": userId,
    "city_id": cityId,
    "lat": lat.toString(),
    "lng": lng.toString(),
    "deletestatus": deletestatus,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
