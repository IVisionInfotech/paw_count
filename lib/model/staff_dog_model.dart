class StaffDogModel {
  int? catchId;
  int? dogTypeId;
  String? dogTypeName;
  String? lat;
  String? lng;
  int? surveyorId;
  String? surveyorName;
  String? img;
  String? catchDatetime;
  String? createdAt;
  String? updatedAt;
  String? imgUrl;
  String? remark;

  StaffDogModel(
      {this.catchId,
        this.dogTypeId,
        this.dogTypeName,
        this.lat,
        this.lng,
        this.surveyorId,
        this.surveyorName,
        this.img,
        this.catchDatetime,
        this.createdAt,
        this.updatedAt,
        this.imgUrl,
        this.remark,

      });

  StaffDogModel.fromJson(Map<String, dynamic> json) {
    catchId = json['catch_id'];
    dogTypeId = json['dog_type_id'];
    dogTypeName = json['dog_type_name'];
    lat = json['lat'];
    lng = json['lng'];
    surveyorId = json['surveyor_id'];
    surveyorName = json['surveyor_name'];
    img = json['img'];
    catchDatetime = json['catch_datetime'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imgUrl = json['img_url'];
    remark = json['remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['catch_id'] = catchId;
    data['dog_type_id'] = dogTypeId;
    data['dog_type_name'] = dogTypeName;
    data['lat'] = lat;
    data['lng'] = lng;
    data['surveyor_id'] = surveyorId;
    data['surveyor_name'] = surveyorName;
    data['img'] = img;
    data['catch_datetime'] = catchDatetime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['img_url'] = imgUrl;
    data['remark'] = remark;
    return data;
  }
}