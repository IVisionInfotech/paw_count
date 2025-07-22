class LocationModel {
  final int locationId;
  final int parentId;
  final String locationName;
  final String locationType;
  final String? latitude;
  final String? longitude;
  final String? wardNo;
  final int deleteStatus;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;
  final String? dogtypeId;

  LocationModel({
    required this.locationId,
    required this.parentId,
    required this.locationName,
    required this.locationType,
    this.latitude,
    this.longitude,
    this.wardNo,
    required this.deleteStatus,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.dogtypeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      locationId: json['location_id'],
      parentId: json['parent_id'],
      locationName: json['location_name'],
      locationType: json['location_type'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      wardNo: json['ward_no']?.toString(),
      deleteStatus: json['deletestatus'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      dogtypeId: json['dogtype_id'],
    );
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      locationId: map['location_id'],
      parentId: map['parent_id'],
      locationName: map['location_name'],
      locationType: map['location_type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      wardNo: map['ward_no'],
      deleteStatus: map['deletestatus'],
      userId: map['user_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      dogtypeId: map['dogtype_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location_id': locationId,
      'parent_id': parentId,
      'location_name': locationName,
      'location_type': locationType,
      'latitude': latitude,
      'longitude': longitude,
      'ward_no': wardNo,
      'deletestatus': deleteStatus,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'dogtype_id': dogtypeId,
    };
  }

}
