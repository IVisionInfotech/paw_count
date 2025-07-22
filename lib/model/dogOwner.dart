class DogOwner {
  int? id;
  int? userId;
  int? routeId;
  String? ownerImage;
  String? dogImage;
  String? ownerName;
  String? ownerContact;
  String? petName;
  int? dogBreed;
  int? dogColor;
  String? dogBreedName;
  String? dogColorName;
  String? microchipNo;
  String? gender;
  String? dob;
  int? age;
  String? currentAddress;
  String? address;
  String? latLong;
  String? placeType;
  String? createdAt;
  String? updatedAt;

  DogOwner(
      {this.id,
        this.userId,
        this.routeId,
        this.ownerImage,
        this.dogImage,
        this.ownerName,
        this.ownerContact,
        this.petName,
        this.dogBreed,
        this.dogColor,
        this.dogBreedName,
        this.dogColorName,
        this.microchipNo,
        this.gender,
        this.dob,
        this.age,
        this.currentAddress,
        this.address,
        this.latLong,
        this.placeType,
        this.createdAt,
        this.updatedAt});

  DogOwner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    routeId = json['route_id'];
    ownerImage = json['owner_image'];
    dogImage = json['dog_image'];
    ownerName = json['owner_name'];
    ownerContact = json['owner_contact'];
    petName = json['pet_name'];
    dogBreed = json['dog_breed'];
    dogColor = json['dog_color'];
    dogBreedName = json['dog_breed_name'];
    dogColorName = json['dog_color_name'];
    microchipNo = json['microchip_no'];
    gender = json['gender'];
    dob = json['dob'];
    age = json['age'];
    currentAddress = json['current_address'];
    address = json['address'];
    latLong = json['lat_long'];
    placeType = json['place_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['route_id'] = routeId;
    data['owner_image'] = ownerImage;
    data['dog_image'] = dogImage;
    data['owner_name'] = ownerName;
    data['owner_contact'] = ownerContact;
    data['pet_name'] = petName;
    data['dog_breed'] = dogBreed;
    data['dog_color'] = dogColor;
    data['dog_breed_name'] = dogBreedName;
    data['dog_color_name'] = dogColorName;
    data['microchip_no'] = microchipNo;
    data['gender'] = gender;
    data['dob'] = dob;
    data['age'] = age;
    data['current_address'] = currentAddress;
    data['address'] = address;
    data['lat_long'] = latLong;
    data['place_type'] = placeType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
