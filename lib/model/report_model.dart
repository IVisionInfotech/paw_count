class DogCatchDataModel {
  final int dogTypeId;
  final int dogCount;
  final String name;

  DogCatchDataModel({
    required this.dogTypeId,
    required this.dogCount,
    required this.name,
  });

  factory DogCatchDataModel.fromJson(Map<String, dynamic> json) {
    return DogCatchDataModel(
      dogTypeId: json['dog_type_id'] ?? 0,
      dogCount: json['Dogcount'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dog_type_id': dogTypeId,
      'Dogcount': dogCount,
      'name': name,
    };
  }
}
