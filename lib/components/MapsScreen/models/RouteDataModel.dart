class LatLngModel {
  final double lat;
  final double lng;

  LatLngModel({required this.lat, required this.lng});

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}

class DogCountModel {
  final String dogType;
  final int count;

  DogCountModel({required this.dogType, required this.count});

  factory DogCountModel.fromJson(Map<String, dynamic> json) {
    return DogCountModel(
      dogType: json['dog_type'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'dog_type': dogType,
    'count': count,
  };
}

class DogMarkerModel {
  final double lat;
  final double lng;
  final String dogType;
  final String dogTypeImg;
  final String surveyorName;

  DogMarkerModel({
    required this.lat,
    required this.lng,
    required this.dogType,
    required this.dogTypeImg,
    required this.surveyorName,
  });

  factory DogMarkerModel.fromJson(Map<String, dynamic> json) {
    return DogMarkerModel(
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      dogType: json['DogType'] ?? '',
      dogTypeImg: json['dog_type_img'] ?? '',
      surveyorName: json['surveyor_nm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
    'DogType': dogType,
    'dog_type_img': dogTypeImg,
    'surveyor_nm': surveyorName,
  };
}

class RouteDataModel {
  int routeId;
  int createdBy;
  int cityId;
  int subAdminId;
  String routeName;
  int zoneId;
  int wardId;
  int areaId;
  List<int> surveyorIds;
  List<String> assignSurveyorNames;
  int reallocation;
  int routeConfirm;
  String startDate;
  String endDate;
  String? remark;
  int routeStatus;
  int acceptBy;
  List<LatLngModel> map;
  List<LatLngModel>? surveyorMap;

  // Additional display names
  String? zoneName;
  String? wardName;
  String? areaName;
  String? cityName;

  // Dog Count & Marker Data
  List<DogCountModel> dogCount;
  List<DogMarkerModel>? dogMarkers;

  RouteDataModel({
    required this.routeId,
    required this.createdBy,
    required this.cityId,
    required this.subAdminId,
    required this.routeName,
    required this.zoneId,
    required this.wardId,
    required this.areaId,
    required this.surveyorIds,
    required this.assignSurveyorNames,
    required this.reallocation,
    required this.routeConfirm,
    required this.startDate,
    required this.endDate,
    required this.routeStatus,
    required this.acceptBy,
    required this.map,
    required this.dogCount,
    this.dogMarkers,
    this.zoneName,
    this.wardName,
    this.areaName,
    this.cityName,
    this.remark,
    this.surveyorMap,
  });

  factory RouteDataModel.fromJson(Map<String, dynamic> json) {
    List<int> parsedSurveyorIds = json['surveyor_id']
        .toString()
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .toList();

    List<String> parsedSurveyorNames = (json['assign_surveyor'] as List<dynamic>?)
        ?.map((e) => e['name']?.toString() ?? '')
        .toList() ??
        [];

    List<DogCountModel> parsedDogCount = (json['dog_count'] as List<dynamic>?)
        ?.map((v) => DogCountModel.fromJson(v))
        .toList() ??
        [];

    List<DogMarkerModel> parsedDogMarkers = (json['catchmapdata'] as List<dynamic>?)
        ?.map((v) => DogMarkerModel.fromJson(v))
        .toList() ??
        [];

    return RouteDataModel(
      routeId: json['route_id'],
      createdBy: json['created_by'],
      cityId: json['city_id'],
      subAdminId: json['sub_admin_id'],
      routeName: json['route_name'],
      zoneId: json['zone_id'],
      wardId: json['ward_id'],
      areaId: json['area_id'],
      surveyorIds: parsedSurveyorIds,
      assignSurveyorNames: parsedSurveyorNames,
      reallocation: json['reallocation'],
      routeConfirm: json['route_confirm'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      routeStatus: json['route_status'],
      remark: json['remark'],
      acceptBy: json['accept_by'],
      map: (json['map'] as List<dynamic>)
          .map((coord) => LatLngModel.fromJson(coord))
          .toList(),
      surveyorMap: (json['map_history'] != null && (json['map_history'] as List).isNotEmpty)
          ? (json['map_history'] as List<dynamic>)
          .map((coord) => LatLngModel.fromJson(coord))
          .toList()
          : null,
      dogCount: parsedDogCount,
      dogMarkers: parsedDogMarkers,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'route_id': routeId,
      'created_by': createdBy,
      'city_id': cityId,
      'sub_admin_id': subAdminId,
      'route_name': routeName,
      'zone_id': zoneId,
      'ward_id': wardId,
      'area_id': areaId,
      'surveyor_id': surveyorIds.join(','),
      'assign_surveyor': assignSurveyorNames,
      'reallocation': reallocation,
      'route_confirm': routeConfirm,
      'start_date': startDate,
      'end_date': endDate,
      'route_status': routeStatus,
      'accept_by': acceptBy,
      'remark': remark,
      'map': map.map((e) => e.toJson()).toList(),
      'dog_count': dogCount.map((e) => e.toJson()).toList(),
      if (dogMarkers != null)
        'catchmapdata': dogMarkers!.map((e) => e.toJson()).toList(),
    };

    if (surveyorMap != null && surveyorMap!.isNotEmpty) {
      data['map_history'] = surveyorMap!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}
