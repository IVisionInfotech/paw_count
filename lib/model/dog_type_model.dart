class DogTypeModel {
  int? id;
  String? name;
  String? description;
  String? imagePath;
  int? imageStatus;

  DogTypeModel({this.id, this.name, this.description, this.imagePath,this.imageStatus});

  factory DogTypeModel.fromJson(Map<String, dynamic> json) {
    return DogTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['img'],
      imageStatus: json['image_upload_status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'image_upload_status': imageStatus,
  };
}