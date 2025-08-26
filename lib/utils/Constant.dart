import 'package:flutter/material.dart';
import 'package:survey_dogapp/utils/Common.dart';

class UrlConstants {
  // Base URL
  static const String baseUrl = "https://pawcount.com/api/";
  static const String apiKey = "tLJmY6AHDZ9jR3XqNa7QpWcRVfGhUsyM";

  static const String SUPER_ADMIN = "SUPER ADMIN";
  static const String ADMIN = "ADMIN";
  static const String STATE_ADMIN = "STATE ADMIN";
  static const String SUB_ADMIN = "SUB ADMIN";
  static const String CITY_ADMIN = "CITY ADMIN";
  static const String SURVEYOR = "SURVEYOR";
  static const String STAFF = "STAFF";
  static const String ASSOCIATES = "ASSOCIATES";

  static const superAdminRoles = [
    'STATE ADMIN',
    'CITY ADMIN',
    'SURVEYOR',
    'ASSOCIATES',
  ];

  static const superAdmin = [
    'STATE ADMIN',
    'CITY ADMIN',
    'SURVEYOR',
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
  static const String setDataUrl = "${baseUrl}set-data-roles";
  static const String logoutUrl = "${baseUrl}logout";


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
  static const String userUpdateRole = "${baseUrl}add-user-roles";


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

  static const List<Color> dogTypeColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.yellow,
    Colors.grey,
    Colors.lightBlue,
    Colors.blueGrey,
    Colors.black,
    Color(0xFF1ABC9C),
    Color(0xFF2ECC71),
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFF34495E),
    Color(0xFFF1C40F),
    Color(0xFFE67E22),
    Color(0xFFE74C3C),
    Color(0xFFECF0F1),
    Color(0xFF95A5A6),
    Color(0xFF16A085),
    Color(0xFF27AE60),
    Color(0xFF2980B9),
    Color(0xFF8E44AD),
    Color(0xFF2C3E50),
    Color(0xFFF39C12),
    Color(0xFFD35400),
    Color(0xFFC0392B),
    Color(0xFFBDC3C7),
    Color(0xFF7F8C8D),
    Color(0xFF00695C),
    Color(0xFF00897B),
    Color(0xFF43A047),
    Color(0xFF558B2F),
    Color(0xFF9E9D24),
    Color(0xFFF9A825),
    Color(0xFFFF8F00),
    Color(0xFFEF6C00),
    Color(0xFFD84315),
    Color(0xFF6D4C41),
    Color(0xFF4E342E),
    Color(0xFF424242),
    Color(0xFF37474F),
    Color(0xFF1E88E5),
    Color(0xFF1976D2),
    Color(0xFF0D47A1),
    Color(0xFF01579B),
    Color(0xFF00ACC1),
    Color(0xFF00838F),
    Color(0xFF006064),
    Color(0xFF00BCD4),
    Color(0xFF26C6DA),
    Color(0xFF80DEEA),
    Color(0xFFB2EBF2),
    Color(0xFFB2DFDB),
    Color(0xFFC8E6C9),
    Color(0xFFD1C4E9),
    Color(0xFFE1BEE7),
    Color(0xFFF8BBD0),
    Color(0xFFFFCDD2),
    Color(0xFFFFECB3),
    Color(0xFFE6EE9C),
    Color(0xFFFFF59D),
    Color(0xFFFFCCBC),
    Color(0xFFD7CCC8),
    Color(0xFFCFD8DC),
    Color(0xFFE0E0E0),
    Color(0xFFFAFAFA),
    Color(0xFFF5F5F5),
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF03A9F4),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFCDDC39),
    Color(0xFFFFEB3B),
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF9E9E9E),
    Color(0xFF607D8B),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
  ];
}
