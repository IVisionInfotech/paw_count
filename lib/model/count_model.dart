class CountModel {
  int? adminCount;
  int? subadminCount;
  int? surveyorCount;
  int? dogTypeCount;
  int? surveyRouteCount;
  int? staffCount;

  CountModel(
      {this.adminCount,
        this.subadminCount,
        this.surveyorCount,
        this.dogTypeCount,
        this.surveyRouteCount,
        this.staffCount
      });

  CountModel.fromJson(Map<String, dynamic> json) {
    adminCount = json['admin_count'];
    subadminCount = json['subadmin_count'];
    surveyorCount = json['surveyor_count'];
    dogTypeCount = json['dog_type_count'];
    surveyRouteCount = json['route_count'];
    staffCount = json['staff_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_count'] = this.adminCount;
    data['subadmin_count'] = this.subadminCount;
    data['surveyor_count'] = this.surveyorCount;
    data['dog_type_count'] = this.dogTypeCount;
    data['route_count'] = this.surveyRouteCount;
    data['staff_count'] = this.staffCount;
    return data;
  }
}