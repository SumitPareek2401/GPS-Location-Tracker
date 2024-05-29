import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  GoogleMapController? googleMapController;
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.42796122580664, -122.085749655962),
    zoom: 14,
  );

  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    getUserAddress();
  }

  getUserAddress() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(26.9396514, 75.7569766,);
    List<Location> locations =
        await locationFromAddress("114, Marg No A 10, Kumawat Colony, Jhotwara");
    print("PLACEMARKS $placemarks");
    print("COORD: $locations");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Locations"),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _determinePosition();

          googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                // target: LatLng(position.latitude, position.longitude),
                target: LatLng(20.42796133580664, 80.885749655962),
                zoom: 14,
              ),
            ),
          );
          // markers.clear();
          // markers.add(
          //   Marker(
          //     markerId: const MarkerId('currentLocation'),
          //     position: LatLng(position.latitude, position.longitude),
          //   ),
          // );
          setState(() {
            markers.clear();
            markers.add(
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(position.latitude, position.longitude),
              ),
            );
          });
        },
        label: const Text("Current Location"),
        icon: const Icon(Icons.location_history),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
