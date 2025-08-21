import 'package:flutter/material.dart';
import 'package:survey_dogapp/utils/Common.dart';

class UrlConstants {
  // Base URL
  static const String baseUrl = "https://pawcount.com/BetaVersion/api/";
  static const String apiKey = "tLJmY6AHDZ9jR3XqNa7QpWcRVfGhUsyM";

  static const String SUPER_ADMIN = "SUPER ADMIN";
  static const String ADMIN = "ADMIN";
  static const String STATE_ADMIN = "STATE ADMIN";
  static const String SUB_ADMIN = "SUB ADMIN";
  static const String CITY_ADMIN = "CITY ADMIN";
  static const String SURVEYOR = "SURVEYOR";
  static const String STAFF = "STAFF";

  static const superAdminRoles = [
    'STATE ADMIN',
    'CITY ADMIN',
    'SURVEYOR',
    'ASSOCIATES',
  ];
  static const adminRoles = ['CITY ADMIN', 'SURVEYOR', 'ASSOCIATES'];
  static const subAdminRoles = ['SURVEYOR','ASSOCIATES'];

  static const String routePending = "In Pending";
  static const String routeProcessing = "In Processing";
  static const String routeComplete = "Completed";
  static const String routeUnComplete = "UnCompleted";
  static const String routeFlagStart = "START";
  static const String routeFlagEnd = "END";
  static const String routeFlagConfirm = "CONFIRM";
  static const String routeFlagReject = "REJECT";

  static const List<Map<String, dynamic>> ownershipOptions = [
    {'id': 0, 'type': 'Without Pet Ownership'},
    {'id': 1, 'type': 'With Pet Ownership'},
  ];

  static List<Map<String, dynamic>> getActionItems() {
    final ownership = CommonUtils.getCurrentUser()?.ownership ?? 0;
    final role = CommonUtils.getUserRole();

    List<Map<String, dynamic>> items = [
      {'title': 'Edit Profile', 'icon': Icons.edit, 'action': 'edit'},
      {
        'title': 'Change Password',
        'icon': Icons.lock_reset,
        'action': 'password',
      },
    ];

    if (role == SUPER_ADMIN || role == ADMIN) {
      items.addAll([
        {
          'title': 'Pet Owner Profile',
          'icon': Icons.person,
          'action': 'addOwner',
        },
        {
          'title': 'Pet Dog Color Management',
          'icon': Icons.palette,
          'action': 'color',
        },
        {
          'title': 'Pet Dog Breed Management',
          'icon': Icons.pets,
          'action': 'breed',
        },
      ]);
    } else if (ownership == 1) {
      items.addAll([
        {
          'title': 'Pet Owner Profile',
          'icon': Icons.person,
          'action': 'addOwner',
        },
        {
          'title': 'Pet Dog Color Management',
          'icon': Icons.palette,
          'action': 'color',
        },
        {
          'title': 'Pet Dog Breed Management',
          'icon': Icons.pets,
          'action': 'breed',
        },
      ]);
    }

    items.add({'title': 'Logout', 'icon': Icons.logout, 'action': 'logout'});

    return items;
  }

  // Auth endpoints
  static const String loginUrl = "${baseUrl}login";
  static const String signupUrl = "${baseUrl}signup";
  static const String forgotPasswordUrl = "${baseUrl}forget-password";
  static const String changePasswordUrl = "${baseUrl}change-password";
  static const String verifyOtpUrl = "${baseUrl}verify-device-id";

  //Dog Type endpoints
  static const String dogTypeCreate = "${baseUrl}dog-type/create";
  static const String dogTypeFetchAll = "${baseUrl}dog-type/all";
  static const String dogTypeUpdate = "${baseUrl}dog-type/update";
  static const String dogTypeDelete = "${baseUrl}dog-type/delete";

  //Dog Breeds endpoints
  static const String dogBreedsCreate = "${baseUrl}dog-breeds/create";
  static const String dogBreedsFetchAll = "${baseUrl}dog-breeds/all";
  static const String dogBreedsUpdate = "${baseUrl}dog-breeds/update";
  static const String dogBreedsDelete = "${baseUrl}dog-breeds/delete";

  //Dog Color endpoints
  static const String dogColorCreate = "${baseUrl}dog-color/create";
  static const String dogColorFetchAll = "${baseUrl}dog-color/all";
  static const String dogColorUpdate = "${baseUrl}dog-color/update";
  static const String dogColorDelete = "${baseUrl}dog-color/delete";

  //Location endpoints
  static const String allLocation = "${baseUrl}location/all";
  static const String createLocation = "${baseUrl}location/create";
  static const String editLocation = "${baseUrl}location/update";
  static const String deleteLocation = "${baseUrl}location/delete";

  //Pet Owner endpoints
  static const String allPetOwner = "${baseUrl}owner/all";
  static const String createPetOwner = "${baseUrl}owner/create";
  static const String editPetOwner = "${baseUrl}owner/update";
  static const String deletePetOwner = "${baseUrl}owner/delete";

  // Other endpoints
  static const String getUsersList = "${baseUrl}user/role";
  static const String createUsers = "${baseUrl}user/create";
  static const String editUsers = "${baseUrl}user/update";
  static const String deleteUsers = "${baseUrl}user/delete";
  static const String updateUsers = "${baseUrl}user/update/profile";
  static const String getAssignUsersList = "${baseUrl}assign-user-list";
  static const String userRegister = "${baseUrl}user-register";

  //City Border endpointsstatic
  static const String cityBorderCreate = "${baseUrl}city-border/create";
  static const String cityBorderUpdate = "${baseUrl}city-border/update";
  static const String cityBorderEdit = "${baseUrl}city-border/edit";

  //Route Map endpoints
  static const String routeMapCreate = "${baseUrl}route/create";
  static const String routeMapUpdate = "${baseUrl}route/update";
  static const String routeMapFetchAll = "${baseUrl}route/all";
  static const String routeMapAccept = "${baseUrl}route/accept";
  static const String routeMapCatchDog = "${baseUrl}catch-dog/add";
  static const String routeMapCatchAll = "${baseUrl}catch-dog/all";
  static const String routeMapPending = "${baseUrl}route/pending-route";
  static const String routeMapProcessing = "${baseUrl}route/processing-route";

  //Count endpoints
  static const String countManage = "${baseUrl}master-count";
  static const String viewReport = "${baseUrl}report";

  //Staff
  static const String staff = "${baseUrl}dog-catch-staff";
}
