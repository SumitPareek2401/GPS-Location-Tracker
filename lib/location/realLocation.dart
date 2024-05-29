// import 'dart:html';
import 'dart:async';
import 'package:gps_location/location/introScreen.dart';
import 'package:gps_location/location/listenScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart' as pla;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gps_location/location/temp/tempListen.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:gps_location/location/sqflite/database_service.dart'
    as dbservice;
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

// ignore: implementation_imports, unused_import
// import 'package:google_maps_place_picker_mb/src/google_map_place_picker.dart'; // do not import this yourself
import 'dart:io' show Platform;

// Your api key storage.
// import 'keys.dart.example';

// Only to control hybrid composition and the renderer in Android
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class CurrentLocationScreen extends StatefulWidget {
  String latitude = "";
  String longitude = "";
  CurrentLocationScreen({
    required this.latitude,
    required this.longitude,
    Key? key,
  }) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController googleMapController;
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(26.8522015, 75.7820497),
    zoom: 3,
  );
  String receivedData = "";
  String longitude = "";
  String latitude = "";
  String address = "";
  late StreamSubscription<Position> _positionStream;
  GoogleMapController? _googleMapController;
  bool _isMounted = false;
  // PickResult? selectedPlace;
  final bool _showPlacePickerInContainer = false;
  final bool _showGoogleMapInContainer = false;
  static const kInitialPosition = LatLng(-33.8567844, 151.213108);

  static String androidApiKey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";

  double launchLat = 0;
  double launchLong = 0;
  PersistentBottomSheetController? _controller;

  @override
  void initState() {
    super.initState();

    // print("CURLAT: ${widget.curLat}");
    // print("CURLONG: ${widget.curLong}");
    // _determinePosition();
    // initTts();

    _isMounted = true;
    // getUserAddress();
    // _animationController = AnimationController(
    //   vsync: this,
    //   lowerBound: 0.5,
    //   duration: Duration(seconds: 3),
    //   // reverseDuration: Duration(seconds: 5),
    // )..repeat();
    latitude = widget.latitude;
    longitude = widget.longitude;
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      // distanceFilter: 100,
    );
    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (_isMounted) {
        setState(() {
          longitude = position!.longitude.toString();
          latitude = position.latitude.toString();
          _getAddressFromCoordinates(position.latitude, position.longitude);

          // _updateMarkerOnMap(position.latitude, position.longitude);
        });
      }
    });

    print("LATI: $currentLatitude");
    print("LONGI: $currentLongitude");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isMounted = false;
    super.dispose();
  }

  bool _fetchingLocation = false;

  Future<void> _fetchLocation() async {
    if (_fetchingLocation) {
      // Don't allow multiple requests while fetching
      return;
    }

    setState(() {
      _fetchingLocation = true;
    });

    try {
      Position position = await _determinePosition();
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return Future.error("Location services are disabled");
      }
      // if (serviceEnabled) {
      //   setState(() {});
      // }

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
      print("LATI: $currentLatitude");
      print("LONGI: $currentLongitude");
      s1 = position.latitude.toString();
      s2 = position.longitude.toString();
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
          ),
        ),
      );
      // print(images[1]);
      markers.clear();
      final Uint8List markIcons = await getImages(
        images[0],
        (MediaQuery.of(context).size.width * 0.3).toInt(),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          // position: LatLng(double.parse(latitude), double.parse(longitude)),
          icon: BitmapDescriptor.fromBytes(markIcons),
        ),
      );
      // setState(() {});
      // ... (rest of your location fetching code)
    } catch (error) {
      // Handle location fetching errors as needed
      print("Error fetching location: $error");
    } finally {
      setState(() {
        _fetchingLocation = false;
      });
    }
  }

  String realAddress = "";

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
          // print("REALAddress: $realAddress");
          // You can update a UI element with the obtained address here if needed.
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Uint8List? markerimages;
  List<String> images = [
    'assets/images/marker.png',
    'assets/images/mike2.png',
    'assets/images/bike.png',
    'assets/images/marker.png',
  ];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _updateMarkerOnMap(double lat, double long) async {
    if (_googleMapController != null && _isMounted) {
      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, long),
            zoom: 18,
          ),
        ),
      );

      markers.clear();
      final Uint8List markIcons = await getImages(
        images[2],
        (MediaQuery.of(context).size.width * 0.3).toInt(),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation1'),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.fromBytes(markIcons),
        ),
      );
    }
  }

  Set<Marker> markers = {};
  String s1 = "";
  String s2 = "";

  String currentLatitude = "";
  String currentLongitude = "";

  // getUserAddress() async {
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     26.9396514,
  //     75.7569766,
  //   );
  //   List<Location> locations = await locationFromAddress(
  //       "114, Marg No A 10, Kumawat Colony, Jhotwara");
  //   print("PLACEMARKS $placemarks");
  //   print("COORD: $locations");
  // }

  TextEditingController addressController = TextEditingController();

  late Uint8List markIcons;

  String googleApikey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";
  GoogleMapController? mapController; //contrller for Google map
  CameraPosition? cameraPosition;
  // LatLng startLocation = LatLng(
  //   26.9396514,
  //   75.7569766,
  // );
  String location = "Search Location";
  var maptype = MapType.normal;
  bool buildEnable = false;

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      target:
          LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
      zoom: 16,
    );
    markers.clear();
    // final Uint8List markIcons = await getImages(
    //   images[0],
    //   (MediaQuery.of(context).size.width * 0.3).toInt(),
    // );
    markers.add(
      Marker(
        markerId: const MarkerId('AutocurrentLocation'),
        position: LatLng(
            double.parse(widget.latitude), double.parse(widget.longitude)),
        // position: LatLng(double.parse(latitude), double.parse(longitude)),
        // icon: BitmapDescriptor.fromBytes(markIcons),
      ),
    );
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Locations"),
      //   centerTitle: true,
      // ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              // initialCameraPosition: initialCameraPosition,
              initialCameraPosition: initialCameraPosition, //??
              // CameraPosition(
              //   target: LatLng(double.parse(currentLatitude),
              //       double.parse(currentLongitude)),
              //   zoom: 14,
              // ),
              // zoomGesturesEnabled: true,
              // mapToolbarEnabled: true,
              // compassEnabled: true,
              // myLocationButtonEnabled: true,
              buildingsEnabled: true,
              markers: markers,
              // zoomControlsEnabled: true,
              mapType: maptype, //MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.3,
                horizontal: 12,
              ),
              child: Card(
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MapChangeScreen(
                                  initialMapType: maptype,
                                )),
                      );
                      if (result != null) {
                        setState(() {
                          maptype = result;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.13,
                horizontal: 10,
              ),
              child: InkWell(
                onTap: () {
                  // Fluttertoast.showToast(msg: "BACK");
                  Navigator.pop(context);
                },
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.13,
                  width: MediaQuery.of(context).size.width * 0.14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      // IconButton(
                      //   // padding: EdgeInsets.zero,
                      //   constraints: BoxConstraints(),
                      //   onPressed: () {
                      //     Fluttertoast.showToast(msg: "BACK");
                      //     Navigator.pop(context);
                      //   },
                      // icon:
                      const Icon(Icons.arrow_back_outlined),
                  // ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.1,
                  horizontal: 2),
              child: Container(
                decoration: const BoxDecoration(
                    // border: Border.all(color: Colors.black),
                    // color: Colors.black,
                    ),
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width * 0.84,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Center(
                        child: InkWell(
                          onTap: () async {
                            // Fluttertoast.showToast(msg: "TAP");
                            var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: googleApikey,
                                mode: Mode.overlay,
                                types: [],
                                strictbounds: false,
                                components: [
                                  pla.Component(pla.Component.country, 'in')
                                ],
                                //google_map_webservice package
                                onError: (err) {
                                  print(err);
                                });

                            if (place != null) {
                              // Fluttertoast.showToast(msg: "AGAIN");
                              setState(() {
                                location = place.description.toString();
                              });

                              //form google_maps_webservice package
                              final plist = pla.GoogleMapsPlaces(
                                apiKey: googleApikey,
                                apiHeaders:
                                    await const GoogleApiHeaders().getHeaders(),
                                //from google_api_headers package
                              );
                              String placeid = place.placeId ?? "0";
                              final detail =
                                  await plist.getDetailsByPlaceId(placeid);
                              final geometry = detail.result.geometry!;
                              final lat = geometry.location.lat;
                              final lang = geometry.location.lng;
                              launchLat = lat;
                              launchLong = lang;
                              var newlatlang = LatLng(lat, lang);

                              //move map camera to selected place with animation
                              googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(target: newlatlang, zoom: 17),
                                ),
                              );
                              setState(() {
                                markers.clear();
                                // final Uint8List markIcons = await getImages(
                                //   images[3],
                                //   (MediaQuery.of(context).size.width * 0.3)
                                //       .toInt(),
                                // );
                                markers.add(
                                  Marker(
                                    markerId: const MarkerId('currentLocation'),
                                    position: LatLng(lat, lang),
                                    // icon: BitmapDescriptor.fromBytes(
                                    //   markIcons,
                                    // ),
                                  ),
                                );
                              });
                            }
                          },
                          child: Card(
                            child: SizedBox(
                              // color: Colors.red,
                              // padding: EdgeInsets.all(5),
                              // color: Colors.red,
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.15,
                              child: Center(
                                child: ListTile(
                                  leading: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.mic,
                                        // size: MediaQuery.of(context).size.width *
                                        //     0.07,
                                      ),
                                      onPressed: () async {
                                        // showContainer = true;
                                        //   final result = await Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: ((context) {
                                        //         return const ListenTemp();
                                        //       }),
                                        //     ),
                                        //   );
                                        //   if (result != null) {
                                        //     setState(() {
                                        //       receivedData = result;
                                        //       print("RECEIVED: $receivedData");
                                        //       addressController.text =
                                        //           receivedData;
                                        //       location = receivedData;
                                        //       String temp = "";
                                        //       String temp2 = "";

                                        //       getMyAddress() async {
                                        //         // var queryN =
                                        //         //     "114, Marg No A 10, Kumawat Colony, Jhotwara, Jaipur";
                                        //         var queryN =
                                        //             addressController.text;
                                        //         Future<List<Location>>
                                        //             addressesN =
                                        //             locationFromAddress(location);
                                        //         addressesN.then((locations) {
                                        //           for (var location
                                        //               in locations) {
                                        //             print(
                                        //                 "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
                                        //             temp = location.latitude
                                        //                 .toString();
                                        //             temp2 = location.longitude
                                        //                 .toString();
                                        //           }
                                        //         }).catchError((error) {
                                        //           print("Error: $error");
                                        //         });
                                        //       }

                                        //       getMyAddress();

                                        //       // Position position =
                                        //       //     await _determinePosition();
                                        //       Future.delayed(
                                        //           const Duration(seconds: 1),
                                        //           () async {
                                        //         if (temp.isNotEmpty &&
                                        //             temp2.isNotEmpty) {
                                        //           print("MYCOORD:$temp");
                                        //           print("MYLATT:$temp2");
                                        //           googleMapController
                                        //               .animateCamera(
                                        //             CameraUpdate
                                        //                 .newCameraPosition(
                                        //               CameraPosition(
                                        //                 target: LatLng(
                                        //                   double.parse(temp),
                                        //                   double.parse(temp2),
                                        //                 ),
                                        //                 zoom: 18,
                                        //               ),
                                        //             ),
                                        //           );
                                        //           markers.clear();
                                        //           final Uint8List markIcons =
                                        //               await getImages(
                                        //             images[3],
                                        //             (MediaQuery.of(context)
                                        //                         .size
                                        //                         .width *
                                        //                     0.3)
                                        //                 .toInt(),
                                        //           );
                                        //           markers.add(
                                        //             Marker(
                                        //               markerId: const MarkerId(
                                        //                   'searched location'),
                                        //               position: LatLng(
                                        //                 double.parse(temp),
                                        //                 double.parse(temp2),
                                        //               ),
                                        //               icon: BitmapDescriptor
                                        //                   .fromBytes(
                                        //                 markIcons,
                                        //               ),
                                        //             ),
                                        //           );
                                        //           // setState(() {});
                                        //         } else {
                                        //           Fluttertoast.showToast(
                                        //             msg: "Enter Address Again!",
                                        //             backgroundColor: Colors.red,
                                        //           );
                                        //         }
                                        //       });
                                        //     });
                                        //   }
                                        // }

                                        listenUser(context);
                                      }
                                      // () {
                                      //   // getDialogListen(context);
                                      //   // startListening();
                                      //   // Future.delayed(const Duration(seconds: 5), () {
                                      //   // setState(() {
                                      //   //   enableS = true;
                                      //   // });

                                      //   // getBottomSheet(context);
                                      //   final result;
                                      //   // await Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(
                                      //   //     builder: (context) => getBottomSheet(),
                                      //   //   ),
                                      //   // );
                                      //   // final result = await Navigator.push(
                                      //   //   context,
                                      //   //   MaterialPageRoute(
                                      //   //     builder: (context) => HomePageScreen(),
                                      //   //   ),
                                      //   // );
                                      //   // if (result != null && mounted) {
                                      //   //   setState(() {
                                      //   //     receivedData = result;
                                      //   //     print("RECEIVED: $receivedData");
                                      //   //     addressController.text = receivedData;
                                      //   //     location = receivedData;
                                      //   //     String temp = "";
                                      //   //     String temp2 = "";

                                      //   //     getMyAddress() async {
                                      //   //       // var queryN =
                                      //   //       //     "114, Marg No A 10, Kumawat Colony, Jhotwara, Jaipur";
                                      //   //       var queryN = addressController.text;
                                      //   //       Future<List<Location>> addressesN =
                                      //   //           locationFromAddress(location);
                                      //   //       addressesN.then((locations) {
                                      //   //         for (var location in locations) {
                                      //   //           print(
                                      //   //               "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
                                      //   //           temp = location.latitude
                                      //   //               .toString();
                                      //   //           temp2 = location.longitude
                                      //   //               .toString();
                                      //   //         }
                                      //   //       }).catchError((error) {
                                      //   //         print("Error: $error");
                                      //   //       });
                                      //   //     }

                                      //   //     getMyAddress();

                                      //   //     // Position position =
                                      //   //     //     await _determinePosition();
                                      //   //     Future.delayed(
                                      //   //         const Duration(seconds: 1),
                                      //   //         () async {
                                      //   //       if (temp.isNotEmpty &&
                                      //   //           temp2.isNotEmpty) {
                                      //   //         print("MYCOORD:$temp");
                                      //   //         print("MYLATT:$temp2");
                                      //   //         googleMapController.animateCamera(
                                      //   //           CameraUpdate.newCameraPosition(
                                      //   //             CameraPosition(
                                      //   //               target: LatLng(
                                      //   //                 double.parse(temp),
                                      //   //                 double.parse(temp2),
                                      //   //               ),
                                      //   //               zoom: 18,
                                      //   //             ),
                                      //   //           ),
                                      //   //         );
                                      //   //         markers.clear();
                                      //   //         final Uint8List markIcons =
                                      //   //             await getImages(
                                      //   //           images[3],
                                      //   //           (MediaQuery.of(context)
                                      //   //                       .size
                                      //   //                       .width *
                                      //   //                   0.3)
                                      //   //               .toInt(),
                                      //   //         );
                                      //   //         markers.add(
                                      //   //           Marker(
                                      //   //             markerId: const MarkerId(
                                      //   //                 'searched location'),
                                      //   //             position: LatLng(
                                      //   //               double.parse(temp),
                                      //   //               double.parse(temp2),
                                      //   //             ),
                                      //   //             icon: BitmapDescriptor
                                      //   //                 .fromBytes(
                                      //   //               markIcons,
                                      //   //             ),
                                      //   //           ),
                                      //   //         );
                                      //   //         // setState(() {});
                                      //   //       } else {
                                      //   //         Fluttertoast.showToast(
                                      //   //           msg: "Enter Address Again!",
                                      //   //           backgroundColor: Colors.red,
                                      //   //         );
                                      //   //       }
                                      //   //     });
                                      //   //   });
                                      //   // }
                                      // },
                                      ),
                                  title: SingleChildScrollView(
                                    child: Text(
                                      location,
                                      style: GoogleFonts.cabin(
                                          color: location == "Search Location"
                                              ? Colors.black54
                                              : Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.043),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      location != "Search Location"
                                          ? IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                if (location !=
                                                    "Search Location") {
                                                  setState(() {
                                                    location =
                                                        "Search Location";
                                                  });
                                                }
                                              },
                                            )
                                          : const Visibility(
                                              visible: false,
                                              child: Text(""),
                                            ),
                                      const Icon(Icons.search),
                                    ],
                                  ),
                                  dense: true,
                                ),
                              ),
                            ),
                          ),
                        ),

                        //  TextFormField(
                        //   controller: addressController,
                        //   decoration: InputDecoration(
                        //     hintText: "Search here",
                        //     hintStyle: GoogleFonts.cabin(
                        //       color: Colors.black45,
                        //       fontSize:
                        //           MediaQuery.of(context).size.width * 0.045,
                        //     ),
                        //     border: InputBorder.none,
                        //     // hintStyle: GoogleFonts.montserrat(),
                        //     prefixIcon: IconButton(
                        //       icon: Icon(Icons.mic),
                        //       onPressed: () async {
                        //         // getDialogListen(context);
                        //         // startListening();
                        //         // Future.delayed(const Duration(seconds: 5), () {
                        //         final result = await Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => ListenClass(),
                        //           ),
                        //         );
                        //         // final result = await Navigator.push(
                        //         //   context,
                        //         //   MaterialPageRoute(
                        //         //     builder: (context) => HomePageScreen(),
                        //         //   ),
                        //         // );
                        //         if (result != null && mounted) {
                        //           setState(() {
                        //             receivedData = result;
                        //             print("RECEIVED: $receivedData");
                        //             addressController.text = receivedData;
                        //             String temp = "";
                        //             String temp2 = "";

                        //             getMyAddress() async {
                        //               // var queryN =
                        //               //     "114, Marg No A 10, Kumawat Colony, Jhotwara, Jaipur";
                        //               var queryN = addressController.text;
                        //               Future<List<Location>> addressesN =
                        //                   locationFromAddress(
                        //                       addressController.text);
                        //               addressesN.then((locations) {
                        //                 for (var location in locations) {
                        //                   print(
                        //                       "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
                        //                   temp = location.latitude.toString();
                        //                   temp2 =
                        //                       location.longitude.toString();
                        //                 }
                        //               }).catchError((error) {
                        //                 print("Error: $error");
                        //               });
                        //             }

                        //             getMyAddress();

                        //             // Position position =
                        //             //     await _determinePosition();
                        //             Future.delayed(const Duration(seconds: 1),
                        //                 () async {
                        //               if (temp.isNotEmpty &&
                        //                   temp2.isNotEmpty) {
                        //                 print("MYCOORD:$temp");
                        //                 print("MYLATT:$temp2");
                        //                 googleMapController.animateCamera(
                        //                   CameraUpdate.newCameraPosition(
                        //                     CameraPosition(
                        //                       target: LatLng(
                        //                         double.parse(temp),
                        //                         double.parse(temp2),
                        //                       ),
                        //                       zoom: 18,
                        //                     ),
                        //                   ),
                        //                 );
                        //                 markers.clear();
                        //                 final Uint8List markIcons =
                        //                     await getImages(
                        //                   images[3],
                        //                   (MediaQuery.of(context).size.width *
                        //                           0.3)
                        //                       .toInt(),
                        //                 );
                        //                 markers.add(
                        //                   Marker(
                        //                     markerId: const MarkerId(
                        //                         'searched location'),
                        //                     position: LatLng(
                        //                       double.parse(temp),
                        //                       double.parse(temp2),
                        //                     ),
                        //                     icon: BitmapDescriptor.fromBytes(
                        //                       markIcons,
                        //                     ),
                        //                   ),
                        //                 );
                        //                 // setState(() {});
                        //               } else {
                        //                 Fluttertoast.showToast(
                        //                   msg: "Enter Address Again!",
                        //                   backgroundColor: Colors.red,
                        //                 );
                        //               }
                        //             });
                        //           });
                        //         }
                        //       },
                        //     ),
                        //     suffixIcon: Container(
                        //       width: MediaQuery.of(context).size.width * 0.25,
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.end,
                        //         // mainAxisSize: Size.min,
                        //         children: [
                        //           addressController.text.isNotEmpty
                        //               ? IconButton(
                        //                   onPressed: () {
                        //                     addressController.text = "";
                        //                   },
                        //                   icon: Icon(Icons.clear),
                        //                 )
                        //               : Visibility(
                        //                   child: Text(""),
                        //                   visible: false,
                        //                 ),
                        //           IconButton(
                        //             icon: const Icon(Icons.search),
                        //             onPressed: () async {
                        //               if (addressController.text.isEmpty) {
                        //                 Fluttertoast.showToast(
                        //                   msg: "Please enter address",
                        //                   backgroundColor: Colors.red,
                        //                 );
                        //               } else {
                        //                 String temp = "";
                        //                 String temp2 = "";

                        //                 getMyAddress() async {
                        //                   // var queryN =
                        //                   //     "114, Marg No A 10, Kumawat Colony, Jhotwara, Jaipur";
                        //                   var queryN = addressController.text;
                        //                   Future<List<Location>> addressesN =
                        //                       locationFromAddress(
                        //                           addressController.text);
                        //                   addressesN.then((locations) {
                        //                     for (var location in locations) {
                        //                       print(
                        //                           "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
                        //                       temp = location.latitude
                        //                           .toString();
                        //                       temp2 = location.longitude
                        //                           .toString();
                        //                     }
                        //                   }).catchError((error) {
                        //                     print("Error: $error");
                        //                   });
                        //                 }

                        //                 await getMyAddress();

                        //                 Position position =
                        //                     await _determinePosition();
                        //                 Future.delayed(
                        //                     const Duration(seconds: 1),
                        //                     () async {
                        //                   if (temp.isNotEmpty &&
                        //                       temp2.isNotEmpty) {
                        //                     print("MYCOORD:$temp");
                        //                     print("MYLATT:$temp2");
                        //                     googleMapController.animateCamera(
                        //                       CameraUpdate.newCameraPosition(
                        //                         CameraPosition(
                        //                           target: LatLng(
                        //                             double.parse(temp),
                        //                             double.parse(temp2),
                        //                           ),
                        //                           zoom: 18,
                        //                         ),
                        //                       ),
                        //                     );
                        //                     markers.clear();
                        //                     final Uint8List markIcons =
                        //                         await getImages(
                        //                       images[3],
                        //                       (MediaQuery.of(context)
                        //                                   .size
                        //                                   .width *
                        //                               0.3)
                        //                           .toInt(),
                        //                     );
                        //                     markers.add(
                        //                       Marker(
                        //                         markerId: const MarkerId(
                        //                             'searched location'),
                        //                         position: LatLng(
                        //                           double.parse(temp),
                        //                           double.parse(temp2),
                        //                         ),
                        //                         icon: BitmapDescriptor
                        //                             .fromBytes(
                        //                           markIcons,
                        //                         ),
                        //                       ),
                        //                     );
                        //                     // setState(() {});
                        //                   } else {
                        //                     Fluttertoast.showToast(
                        //                       msg: "Enter Address Again!",
                        //                       backgroundColor: Colors.red,
                        //                     );
                        //                   }
                        //                 });
                        //               }
                        //             },
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).size.width * 0.35,
                10, 0,
                // MediaQuery.of(context).size.width * 0.16,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.135,
                width: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  // color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black87,
                      Colors.black54,
                      Colors.black45,
                      Colors.black26,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
                      child: Text(
                        "Latitude: $latitude",
                        style: GoogleFonts.cabin(
                          color: Colors.grey[300],
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
                        // TextStyle(
                        //   color: Colors.grey[300],
                        //   fontSize: MediaQuery.of(context).size.width * 0.045,
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(9, 0, 0, 0),
                      child: Text(
                        "Longitude: $longitude",
                        style: GoogleFonts.cabin(
                          color: Colors.grey[200],
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
                        // TextStyle(
                        //   color: Colors.grey[200],
                        //   fontSize: MediaQuery.of(context).size.width * 0.045,
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(9, 0, 8, 0),
                      child: Text(
                        realAddress,
                        style: GoogleFonts.cabin(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                        ),
                        // TextStyle(
                        //   color: Colors.white,
                        //   fontSize: MediaQuery.of(context).size.width * 0.042,
                        // ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // showContainer
          //     ? Align(
          //         alignment: Alignment.center,
          //         child: Container(
          //           height: MediaQuery.of(context).size.height * 0.5,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: const BorderRadius.vertical(
          //               top: Radius.circular(20),
          //             ),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.2),
          //                 blurRadius: 6.0,
          //               ),
          //             ],
          //           ),
          //           child: const ListenTemp(),
          //         ),
          //       )
          //     : const Visibility(
          //         visible: false,
          //         child: Text(''),
          //       ),
          realAddress.isNotEmpty
              ? Align(
                  alignment: Alignment.bottomLeft,
                  child:
                      // ElevatedButton(
                      //   onPressed: () => MapsLauncher.launchQuery(
                      //       'Poornima College of engineering, isi-6, riico, institutional area,sitapura,jaipur'),
                      //   child: const Text('LAUNCH QUERY'),
                      // ),
                      // const SizedBox(height: 32),
                      Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08,
                      vertical: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: ElevatedButton(
                      onPressed: () => (launchLat != 0 && launchLong != 0) ||
                              (latitude != "" && longitude != "")
                          ?
                          // Fluttertoast.showToast(msg: realAddress)
                          _saveLocation()
                          // MapsLauncher.launchCoordinates(
                          //     launchLat, launchLong, location)
                          : Fluttertoast.showToast(
                              msg: "Enter a location",
                              backgroundColor: Colors.red,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const ui.Color.fromARGB(255, 68, 138, 196),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add to favorite place',
                            style: GoogleFonts.cabin(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045),
                          ),
                          const Icon(
                            Icons.heart_broken,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : const Visibility(
                  visible: false,
                  child: Text(""),
                ),
          Align(
            alignment: Alignment.bottomLeft,
            child:
                // ElevatedButton(
                //   onPressed: () => MapsLauncher.launchQuery(
                //       'Poornima College of engineering, isi-6, riico, institutional area,sitapura,jaipur'),
                //   child: const Text('LAUNCH QUERY'),
                // ),
                // const SizedBox(height: 32),
                Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
                vertical: MediaQuery.of(context).size.width * 0.06,
              ),
              child: ElevatedButton(
                onPressed: () => launchLat != 0 && launchLong != 0
                    ? MapsLauncher.launchCoordinates(
                        launchLat, launchLong, location)
                    : Fluttertoast.showToast(
                        msg: "Enter a location",
                        backgroundColor: Colors.red,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const ui.Color.fromARGB(255, 68, 138, 196),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Directions',
                      style: GoogleFonts.cabin(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                    const Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLocation,
        // () async {
        //   Position position = await _determinePosition();
        //   bool serviceEnabled;
        //   LocationPermission permission;

        //   serviceEnabled = await Geolocator.isLocationServiceEnabled();

        //   if (!serviceEnabled) {
        //     return Future.error("Location services are disabled");
        //   }
        //   // if (serviceEnabled) {
        //   //   setState(() {});
        //   // }

        //   permission = await Geolocator.checkPermission();

        //   if (permission == LocationPermission.denied) {
        //     permission = await Geolocator.requestPermission();

        //     if (permission == LocationPermission.denied) {
        //       return Future.error("Location permission denied");
        //     }
        //   }
        //   if (permission == LocationPermission.deniedForever) {
        //     return Future.error('Location permissions are permanently denied');
        //   }
        //   print("LATI: $currentLatitude");
        //   print("LONGI: $currentLongitude");
        //   s1 = position.latitude.toString();
        //   s2 = position.longitude.toString();
        //   googleMapController.animateCamera(
        //     CameraUpdate.newCameraPosition(
        //       CameraPosition(
        //         target: LatLng(position.latitude, position.longitude),
        //         zoom: 18,
        //       ),
        //     ),
        //   );
        //   // print(images[1]);
        //   markers.clear();
        //   final Uint8List markIcons = await getImages(
        //     images[0],
        //     (MediaQuery.of(context).size.width * 0.3).toInt(),
        //   );
        //   markers.add(
        //     Marker(
        //       markerId: const MarkerId('currentLocation'),
        //       position: LatLng(position.latitude, position.longitude),
        //       // position: LatLng(double.parse(latitude), double.parse(longitude)),
        //       icon: BitmapDescriptor.fromBytes(markIcons),
        //     ),
        //   );
        //   // setState(() {});
        // },
        // // label: const Text(""),
        backgroundColor: Colors.white,
        child: _fetchingLocation
            ? const CircularProgressIndicator()
            : const Icon(
                Icons.gps_fixed,
                color: Colors.blue,
              ),
      ),
    );
  }

  bool showContainer = false;

  void listenUser(BuildContext context) async {
    String spoken = await showModalBottomSheet(
        shape: const CircleBorder(),
        isDismissible: false,
        context: context,
        builder: (sheetContext) {
          return const ListenClass();
          // return const ListenTemp();
          // onSpeechText: (speechText) {
          //   // Handle the speech text returned from the modal bottom sheet
          //   print('Speech Text: $speechText');
          //

          //   // You can use the speech text as needed in your main screen
          // },
          // );
        });
    print(spoken);
    setState(() {
      receivedData = spoken;
      print("RECEIVED: $receivedData");
      addressController.text = receivedData;

      location = receivedData;
    });

    String temp = "";
    String temp2 = "";

    getMyAddress() async {
      // var queryN =
      //     "114, Marg No A 10, Kumawat Colony, Jhotwara, Jaipur";
      var queryN = addressController.text;
      Future<List<Location>> addressesN = locationFromAddress(location);
      addressesN.then((locations) {
        for (var location in locations) {
          print(
              "Latitude: ${location.latitude}, Longitude: ${location.longitude}");
          temp = location.latitude.toString();
          temp2 = location.longitude.toString();
          launchLat = location.latitude;
          launchLong = location.longitude;
        }
      }).catchError((error) {
        print("Error: $error");
      });
    }

    getMyAddress();

    // Position position =
    //     await _determinePosition();
    Future.delayed(const Duration(seconds: 1), () async {
      if (temp.isNotEmpty && temp2.isNotEmpty) {
        print("MYCOORD:$temp");
        print("MYLATT:$temp2");
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                double.parse(temp),
                double.parse(temp2),
              ),
              zoom: 15,
            ),
          ),
        );
        markers.clear();
        // final Uint8List markIcons = await getImages(
        //   images[3],
        //   (MediaQuery.of(context).size.width * 0.3).toInt(),
        // );
        markers.add(
          Marker(
            markerId: const MarkerId('searched location'),
            position: LatLng(
              double.parse(temp),
              double.parse(temp2),
            ),
            // icon: BitmapDescriptor.fromBytes(
            //   markIcons,
            // ),
          ),
        );
        // setState(() {});
      } else {
        Fluttertoast.showToast(
          msg: "Enter Address Again!",
          backgroundColor: Colors.red,
        );
      }
    });
  }

  bool enableS = false;
  void _saveLocation() {
    final String placeName =
        location != "Search Location" ? location : realAddress;
    final double latitudes =
        launchLat != 0 ? launchLat : double.parse(latitude);
    final double longitudes =
        launchLong != 0 ? launchLong : double.parse(longitude);

    if (placeName.isNotEmpty) {
      final location = dbservice.Location(
        placeName: placeName,
        latitude: latitudes,
        longitude: longitudes,
      );

      dbservice.LocationDatabase.instance
          .addLocation(location)
          .then((locationId) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location saved with ID: $locationId'),
        ));
        Fluttertoast.showToast(msg: "Place added");
        // Navigate back to the location list screen or any other screen.
        // Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving location: $error'),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Place Name is required'),
      ));
    }
  }

  // Future _speak(String message) async {
  //   if (Platform.isIOS) {
  //     volume = 0.7;
  //   } else {
  //     volume = 0.5;
  //   }
  //   await flutterTts?.setVolume(volume);
  //   await flutterTts?.setSpeechRate(rate);
  //   await flutterTts?.setPitch(pitch);
  //   if (message.isNotEmpty) {
  //     //!= null) {
  //     if (message.isNotEmpty) {
  //       var result = await flutterTts?.speak(message);
  //       if (result == 1) setState(() => ttsState = TtsState.playing);
  //     }
  //   }
  // }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = false;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }
    // if (serviceEnabled) {
    //   setState(() {});
    //   Fluttertoast.showToast(msg: "ENABLE");
    // }

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
    // if (serviceEnabled) {
    //   setState(() {});
    // }
    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}

class MapChangeScreen extends StatefulWidget {
  final MapType initialMapType;
  const MapChangeScreen({
    super.key,
    required this.initialMapType,
  });

  @override
  State<MapChangeScreen> createState() => _MapChangeScreenState();
}

class _MapChangeScreenState extends State<MapChangeScreen> {
  @override
  bool status = false;
  bool status2 = false;
  bool status3 = false;
  var m = MapType.normal;
  @override
  void initState() {
    super.initState();
    // Initialize status and status2 based on the initialMapType parameter
    if (widget.initialMapType == MapType.normal) {
      status = true;
      status2 = false;
      status3 = false;
    } else if (widget.initialMapType == MapType.satellite) {
      status = false;
      status2 = true;
      status3 = false;
    } else if (widget.initialMapType == MapType.terrain) {
      status = false;
      status2 = false;
      status3 = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            if (status == true || status2 == true || status3 == true) {
              if (status2 == true) {
                m = MapType.satellite;
              } else if (status == true) {
                m = MapType.normal;
              } else if (status3 == true) {
                m = MapType.terrain;
              }
              Navigator.pop(context, m);
            } else {
              Fluttertoast.showToast(msg: "Choose a map type");
            }
          },
        ),
        title: Text(
          "Change Map Type",
          style: GoogleFonts.cabin(
              color: Colors.black87,
              fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (status == true || status2 == true || status3 == true) {
            if (status2 == true) {
              m = MapType.satellite;
            } else if (status == true) {
              m = MapType.normal;
            } else if (status3 == true) {
              m = MapType.terrain;
            }
            Navigator.pop(context, m);
            return Future.value(true);
          } else {
            Fluttertoast.showToast(msg: "Choose a map type");
            return Future.value(false);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        "assets/images/default.png",
                        width: MediaQuery.of(context).size.width * 0.13,
                        height: MediaQuery.of(context).size.width * 0.13,
                      ),
                    ),
                    Text(
                      "Normal",
                      style: GoogleFonts.cabin(
                          color: Colors.black87,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                    FlutterSwitch(
                      activeColor: Colors.green,
                      width: MediaQuery.of(context).size.width * 0.17,
                      height: MediaQuery.of(context).size.width * 0.08,
                      valueFontSize: 30.0,
                      toggleSize: 25.0,
                      value: status,
                      borderRadius: 30.0,
                      padding: 8.0,
                      // showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                          status2 = false;
                          status3 = false;
                          // toggleSwitch(val);
                          // setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        "assets/images/satellite.png",
                        width: MediaQuery.of(context).size.width * 0.13,
                        height: MediaQuery.of(context).size.width * 0.13,
                      ),
                    ),
                    Text(
                      "Satellite",
                      style: GoogleFonts.cabin(
                          color: Colors.black87,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                    FlutterSwitch(
                      activeColor: Colors.green,
                      width: MediaQuery.of(context).size.width * 0.17,
                      height: MediaQuery.of(context).size.width * 0.08,
                      valueFontSize: 30.0,
                      toggleSize: 25.0,
                      value: status2,
                      borderRadius: 30.0,
                      padding: 8.0,
                      // showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          status2 = val;
                          status = false;
                          status3 = false;
                          // toggleSwitch(val);
                          // setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        "assets/images/terrain.png",
                        width: MediaQuery.of(context).size.width * 0.13,
                        height: MediaQuery.of(context).size.width * 0.13,
                      ),
                    ),
                    Text(
                      "Terrain",
                      style: GoogleFonts.cabin(
                          color: Colors.black87,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                    FlutterSwitch(
                      activeColor: Colors.green,
                      width: MediaQuery.of(context).size.width * 0.17,
                      height: MediaQuery.of(context).size.width * 0.08,
                      valueFontSize: 30.0,
                      toggleSize: 25.0,
                      value: status3,
                      borderRadius: 30.0,
                      padding: 8.0,
                      // showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          status = false;
                          status2 = false;
                          status3 = val;
                          // toggleSwitch(val);
                          // setState(() {});
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
