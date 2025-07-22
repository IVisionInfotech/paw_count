import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:survey_dogapp/components/common/custom_appbar.dart';
import 'package:survey_dogapp/components/common/custom_form_button.dart';
import 'package:survey_dogapp/components/theme.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({Key? key}) : super(key: key);

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  LatLng? _selectedLatLng;
  GoogleMapController? _mapController;
  String _address = 'Fetching your location...';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _selectedLatLng = latLng;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    _getAddressFromLatLng(latLng);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _address =
              "${place.street}, ${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      setState(() {
        _address = "Unable to get address";
      });
    }
  }

  Future<void> _searchAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = LatLng(location.latitude, location.longitude);
        _mapController?.animateCamera(CameraUpdate.newLatLng(position));
        setState(() {
          _selectedLatLng = position;
        });
        _getAddressFromLatLng(position);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar.cusAppBarWidget(
              "Pick Location",
              20,
              context,
              () => Get.back(),
            ),
            Expanded(
              child:
                  _selectedLatLng == null
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLatLng!,
                              zoom: 15,
                            ),
                            onMapCreated:
                                (controller) => _mapController = controller,
                            onCameraMove:
                                (position) => _selectedLatLng = position.target,
                            onCameraIdle:
                                () => _getAddressFromLatLng(_selectedLatLng!),
                            myLocationEnabled: true,
                            mapType: MapType.hybrid,
                          ),
                          const Center(
                            child: Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 15,
                            right: 60,
                            child: Card(
                              elevation: 5,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search address',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: _searchAddress,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Center(
                              child: CustomFormButton(
                                innerText: "Select This Location",
                                onPressed: () {
                                  Navigator.pop(context, {
                                    'address': _address,
                                    'lat_long':
                                        "${_selectedLatLng?.latitude},${_selectedLatLng?.longitude}",
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
