import 'package:flutter/material.dart';
import 'package:gps_location/location/realLocation.dart';
import 'package:gps_location/location/sqflite/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:gps_location/location/temp/tempListen.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

const kGoogleApiKey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";

class MapTypesScreen extends StatefulWidget {
  const MapTypesScreen({super.key});

  @override
  State<MapTypesScreen> createState() => _MapTypesScreenState();
}

class _MapTypesScreenState extends State<MapTypesScreen> {
  late StreamSubscription<Position> _positionStream;
  String longitude = "";
  String latitude = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      // distanceFilter: 100,
    );
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (mounted) {
        setState(() {
          longitude = position!.longitude.toString();
          latitude = position.latitude.toString();
          isLoading = true;
          // _updateMarkerOnMap(position.latitude, position.longitude);
          _getAddressFromCoordinates(position.latitude, position.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool isLoading = false;

  String realAddress = "";
  final bool _isMounted = false;

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // realAddress = "";
      if (_isMounted) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0]; // Use the first result
          String address =
              "${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.administrativeArea}";
          realAddress = address;
          // Fluttertoast.showToast(msg: "REAddress: $address");
          if (realAddress.isNotEmpty) {
            // Fluttertoast.showToast(msg: "READD: $realAddress");
          }
          // print("REALAddress: $realAddress");
          // You can update a UI element with the obtained address here if needed.
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GPS Tracker: Family Locator',
          style: GoogleFonts.cabin(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.055,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () {
              // Fluttertoast.showToast(msg: realAddress);
              //
              if (isLoading != true) {
                Fluttertoast.showToast(msg: "Tap Again");
                Stack(
                  children: [
                    const CircularProgressIndicator(),
                    // You can also add a semi-transparent background to indicate loading
                    Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                );
                // CircularProgressIndicator();
              } else {
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => CurrentLocationScreen(
                            latitude: latitude,
                            longitude: longitude,
                          )),
                    ),
                  );
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(130, 177, 212, 240),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/realtime.jpg",
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real Time Tracker',
                            style: GoogleFonts.cabin(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Track your current location and\nconnections',
                            style: GoogleFonts.cabin(
                              color: Colors.black54,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                            // textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: ((context) => const LocationNearby(
                      // getLat: double.parse(latitude),
                      // getLong: double.parse(longitude),
                      )),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(130, 255, 193, 230),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/nearby.png",
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Nearby',
                            style: GoogleFonts.cabin(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Easily search for what you want\nnear you quickly',
                            style: GoogleFonts.cabin(
                              color: Colors.black54,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                            // textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              if (latitude.isNotEmpty && longitude.isNotEmpty) {
                String textToSend = "";
                // Fluttertoast.showToast(msg: "In Progress");
                // Position position = await Geolocator.getCurrentPosition(
                //   desiredAccuracy: LocationAccuracy.high,
                // );
                String latitudes = latitude; //position.latitude.toString();
                String longitudes = longitude; //position.longitude.toString();
                textToSend =
                    'Check out my location: https://maps.google.com/maps?q=$latitudes,$longitudes';

                // Open the URL with the textToSend included
                // _launchWhatsApp(textToSend);
                await Share.share(textToSend);
                // _launchWhatsApp();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: ((context) => LocationListScreen()),
                //   ),
                // );
              } else {
                Fluttertoast.showToast(msg: "Tap again");
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(130, 221, 240, 177),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/sharelocation.png",
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share My Tracking Info',
                            style: GoogleFonts.cabin(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Turn on activity and share your\ninfo so your friends can track',
                            style: GoogleFonts.cabin(
                              color: Colors.black54,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                            // textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: ((context) => const ListenTemp()),
                  builder: ((context) => const LocationListScreen()),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromARGB(130, 244, 232, 159),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/favorite.png",
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorite Places',
                            style: GoogleFonts.cabin(
                              color: Colors.black,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Add places to favorite for\neasily locate again',
                            style: GoogleFonts.cabin(
                              color: Colors.black54,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                            // textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // _launchWhatsApp() async {
  //   var url = 'whatsapp://send';
  //   if (await canLaunchUrl(Uri.parse(url))) {
  //     await launchUrl(Uri.parse(url));
  //   } else {
  //     throw 'Could not launch WhatsApp';
  //   }
  // }

  _launchWhatsApp(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class LocationNearby extends StatefulWidget {
  // double getLat = 0;
  // double getLong = 0;
  const LocationNearby({
    super.key,
    // required this.getLat,
    // required this.getLong,
  });

  @override
  State<LocationNearby> createState() => _LocationNearbyState();
}

class _LocationNearbyState extends State<LocationNearby> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Location Near By",
          style: GoogleFonts.cabin(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade200,
                ),
                child: Center(
                  child: Text(
                    'Food & drink',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                ),
              ),
            ),
            buildNearbyTile(
                "assets/images/bar.png", "Bars", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/restaurant.png", "Restaurants",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/coffee.png", "Coffee",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/takeaway.png", "Takeaway",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/delivery.png", "Delivery",
                openGoogleMapsForNearbyPlaces),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade200,
                ),
                child: Center(
                  child: Text(
                    'Things to do',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                ),
              ),
            ),
            buildNearbyTile("assets/images/nearby/parks.png", "Parks",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/gym.png", "Gyms",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/art.png", "Art",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/spa.png", "Attractions",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/nightlife.png", "Nightlife",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/livemusic.jpeg", "Live Music",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/films.png", "Films",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/museums.jpeg", "Museums",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/library.png", "Libraries",
                openGoogleMapsForNearbyPlaces),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade200,
                ),
                child: Center(
                  child: Text(
                    'Shopping',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                ),
              ),
            ),
            buildNearbyTile("assets/images/nearby/groceries.png", "Groceries",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/beauty.png",
                "Beauty supplies", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/cardealer.png", "Car dealers",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/home&garden.png",
                "Home & garden", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/clothing.jpeg", "Clothing",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/shopping.png",
                "Shopping centres", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/electronics.png",
                "Electronics", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/sporting.jpeg",
                "Sporting goods", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/spa.png", "Convenience",
                openGoogleMapsForNearbyPlaces),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade200,
                ),
                child: Center(
                  child: Text(
                    'Services',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                    ),
                  ),
                ),
              ),
            ),
            buildNearbyTile("assets/images/nearby/food&shelters.png",
                "Food shelters", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/nightshelter.png",
                "Night shelters", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/hotel.png", "Hotels",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile(
                "assets/images/atm.png", "ATMs", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/beauty.png", "Beauty salons",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/rent.png", "Car hire",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/repair.png", "Car repair",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/wash.png", "Car wash",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/drycleaning.png",
                "Dry cleaning", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/charging.png",
                "Charging stations", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/petrol.png", "Petrol",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/hospital.jpeg",
                "Hospitals & clinic", openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/post.png", "Post",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/parking.jpeg", "Parking",
                openGoogleMapsForNearbyPlaces),
            buildNearbyTile("assets/images/nearby/chemist.png", "Chemists",
                openGoogleMapsForNearbyPlaces),
          ],
        ),
      ),
    );
  }

  Widget buildNearbyTile(
      String imagePath, String title, Function(String) onSearch) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 15,
      ),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.width * 0.09,
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(),
        ),
        tileColor: const Color.fromRGBO(238, 238, 238, 1),
        trailing: TextButton(
          onPressed: () {
            onSearch(title);
          },
          child: Text(
            'Search',
            style: GoogleFonts.lato(),
          ),
        ),
      ),
    );
  }

  void openGoogleMapsForNearbyPlaces(String query) async {
    const latitude = 26.7656561; // Replace with your latitude
    const longitude = 75.85299995; // Replace with your longitude

    final url =
        'https://www.google.com/maps/search/?api=1&query=$query&query=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class FavoritePlaceScreen extends StatefulWidget {
  const FavoritePlaceScreen({super.key});

  @override
  State<FavoritePlaceScreen> createState() => _FavoritePlaceScreenState();
}

class _FavoritePlaceScreenState extends State<FavoritePlaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          color: Colors.black,
        ),
        title: Text(
          'Favorite Places',
          style: GoogleFonts.cabin(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.055,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TextFormField(),
        ],
      ),
    );
  }
}
