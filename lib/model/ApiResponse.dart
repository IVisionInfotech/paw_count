import 'package:survey_dogapp/components/City/Model/LocationModel.dart';
import 'package:survey_dogapp/components/MapsScreen/models/CityBorderModel.dart';
import 'package:survey_dogapp/components/MapsScreen/models/RouteDataModel.dart';
import 'package:survey_dogapp/model/dogOwner.dart';
import 'package:survey_dogapp/model/count_model.dart';
import 'package:survey_dogapp/model/dog_type_model.dart';
import 'package:survey_dogapp/model/report_model.dart';

import 'User.dart';

class ApiResponse {
  int? status;
  String? message;
  String? pdfurl;
  User? user;
  List<User>? userList;
  DogTypeModel? dogTypeModel;
  List<DogTypeModel>? dogTypeList;
  LocationModel? location;
  CountModel? countModel;
  List<LocationModel>? locationsList;
  List<CityBorderModel>? cityBorders;
  DogOwner? dogOwnerModel;
  List<DogOwner>? dogOwnerList;
  DogTypeModel? dogDetails;
  List<DogTypeModel>? dogDetailsList;
  List<RouteDataModel>? routePendingList;
  List<RouteDataModel>? routeProcessingList;
  List<RouteDataModel>? routeCompleteList;
  List<RouteDataModel>? routeUncompleteList;
  List<DogCatchDataModel>? dogCatchList;

  ApiResponse({
    this.status,
    this.message,
    this.pdfurl,
    this.user,
    this.userList,
    this.dogTypeModel,
    this.dogTypeList,
    this.location,
    this.countModel,
    this.locationsList,
    this.cityBorders,
    this.dogOwnerModel,
    this.dogOwnerList,
    this.dogDetails,
    this.dogDetailsList,
  });

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    pdfurl = json['pdfurl'];

    if (json['userlist'] != null) {
      if (json['userlist'] is List) {
        userList = (json['userlist'] as List)
            .map((v) => User.fromJson(v))
            .toList();
      } else if (json['userlist'] is Map<String, dynamic>) {
        user = User.fromJson(json['userlist']);
      }
    }

    if (json['locationlist'] != null) {
      if (json['locationlist'] is List) {
        locationsList = (json['locationlist'] as List)
            .map((v) => LocationModel.fromJson(v))
            .toList();
      } else if (json['locationlist'] is Map<String, dynamic>) {
        location = LocationModel.fromJson(json['locationlist']);
      }
    }

    if (json['dogtypelist'] != null) {
      if (json['dogtypelist'] is List) {
        dogTypeList = (json['dogtypelist'] as List)
            .map((v) => DogTypeModel.fromJson(v))
            .toList();
      } else if (json['dogtypelist'] is Map<String, dynamic>) {
        dogTypeModel = DogTypeModel.fromJson(json['dogtypelist']);
      }
    }

    if (json['routependinglist'] != null) {
      routePendingList = (json['routependinglist'] as List)
          .map((v) => RouteDataModel.fromJson(v))
          .toList();
    }
    if (json['routeprocessinglist'] != null) {
      routeProcessingList = (json['routeprocessinglist'] as List)
          .map((v) => RouteDataModel.fromJson(v))
          .toList();
    }
    if (json['routecompletelist'] != null) {
      routeCompleteList = (json['routecompletelist'] as List)
          .map((v) => RouteDataModel.fromJson(v))
          .toList();
    }
    if (json['routeuncompletelist'] != null) {
      routeUncompleteList = (json['routeuncompletelist'] as List)
          .map((v) => RouteDataModel.fromJson(v))
          .toList();
    }

    if (json['cityborder'] != null && json['cityborder'] is List) {
      cityBorders = (json['cityborder'] as List)
          .map((v) => CityBorderModel.fromJson(v))
          .toList();
    }

    if (json['count_list'] != null &&
        json['count_list'] is Map<String, dynamic>) {
      countModel = CountModel.fromJson(json['count_list']);
    }

    if (json['ownerlist'] != null) {
      if (json['ownerlist'] is List) {
        dogOwnerList = (json['ownerlist'] as List)
            .map((v) => DogOwner.fromJson(v))
            .toList();
      } else if (json['ownerlist'] is Map<String, dynamic>) {
        dogOwnerModel = DogOwner.fromJson(json['ownerlist']);
      }
    }

    parseDogList(json['dogbreedlist'],
            (list) => dogDetailsList = list,
            (single) => dogDetails = single
    );

    parseDogList(json['dogcolorlist'],
            (list) => dogDetailsList = list,
            (single) => dogDetails = single
    );
    if (json['CatchData'] != null && json['CatchData'] is List) {
      dogCatchList = (json['CatchData'] as List)
          .map((v) => DogCatchDataModel.fromJson(v))
          .toList();
    }

  }

  void parseDogList(dynamic jsonList, Function(List<DogTypeModel>) setList, Function(DogTypeModel) setSingle) {
    if (jsonList != null) {
      if (jsonList is List) {
        setList((jsonList).map((v) => DogTypeModel.fromJson(v)).toList());
      } else if (jsonList is Map<String, dynamic>) {
        setSingle(DogTypeModel.fromJson(jsonList));
      }
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'status': status,
      'message': message,
      'pdfurl': pdfurl,
    };

    if (userList != null) {
      jsonMap['userlist'] = userList!.map((user) => user.toJson()).toList();
    } else if (user != null) {
      jsonMap['userlist'] = user!.toJson();
    }

    if (locationsList != null) {
      jsonMap['locationlist'] =
          locationsList!.map((loc) => loc.toMap()).toList();
    } else if (location != null) {
      jsonMap['locationlist'] = location!.toMap();
    }

    if (dogTypeList != null) {
      jsonMap['dogtypelist'] = dogTypeList!.map((dog) => dog.toJson()).toList();
    } else if (dogTypeModel != null) {
      jsonMap['dogtypelist'] = dogTypeModel!.toJson();
    }

    if (cityBorders != null) {
      jsonMap['cityborder'] =
          cityBorders!.map((city) => city.toJson()).toList();
    }

    if (countModel != null) {
      jsonMap['count_list'] = countModel!.toJson();
    }

    return jsonMap;
  }
}
