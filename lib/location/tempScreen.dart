// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';

// // void main(){
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget{
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       home: Home(),
// //     );
// //   }
// // }

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   String googleApikey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";
//   GoogleMapController? mapController; //contrller for Google map
//   CameraPosition? cameraPosition;
//   LatLng startLocation = LatLng(
//     26.9396514,
//     75.7569766,
//   );
//   String location = "Search Location";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Place Search Autocomplete Google Map"),
//         backgroundColor: Colors.deepPurpleAccent,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             //Map widget from google_maps_flutter package
//             zoomGesturesEnabled: true, //enable Zoom in, out on map
//             initialCameraPosition: CameraPosition(
//               //innital position in map
//               target: startLocation, //initial position
//               zoom: 14.0, //initial zoom level
//             ),
//             mapType: MapType.normal, //map type
//             onMapCreated: (controller) {
//               //method called when map is created
//               setState(() {
//                 mapController = controller;
//               });
//             },
//           ),

//           //search autoconplete input
//           Positioned(
//             //search input bar
//             top: 10,
//             child: InkWell(
//               onTap: () async {
//                 var place = await PlacesAutocomplete.show(
//                     context: context,
//                     apiKey: googleApikey,
//                     mode: Mode.overlay,
//                     types: [],
//                     strictbounds: false,
//                     components: [Component(Component.country, 'in')],
//                     //google_map_webservice package
//                     onError: (err) {
//                       print(err);
//                     });

//                 if (place != null) {
//                   setState(() {
//                     location = place.description.toString();
//                   });

//                   //form google_maps_webservice package
//                   final plist = GoogleMapsPlaces(
//                     apiKey: googleApikey,
//                     apiHeaders: await GoogleApiHeaders().getHeaders(),
//                     //from google_api_headers package
//                   );
//                   String placeid = place.placeId ?? "0";
//                   final detail = await plist.getDetailsByPlaceId(placeid);
//                   final geometry = detail.result.geometry!;
//                   final lat = geometry.location.lat;
//                   final lang = geometry.location.lng;
//                   var newlatlang = LatLng(lat, lang);

//                   //move map camera to selected place with animation
//                   mapController?.animateCamera(CameraUpdate.newCameraPosition(
//                       CameraPosition(target: newlatlang, zoom: 17)));
//                 }
//               },
//               child: Padding(
//                 padding: EdgeInsets.all(15),
//                 child: Card(
//                   child: Container(
//                     padding: EdgeInsets.all(0),
//                     width: MediaQuery.of(context).size.width - 40,
//                     child: ListTile(
//                       title: Text(
//                         location,
//                         style: TextStyle(fontSize: 18),
//                       ),
//                       trailing: Icon(Icons.search),
//                       dense: true,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// // ignore: implementation_imports, unused_import
// import 'package:google_maps_place_picker_mb/src/google_map_place_picker.dart'; // do not import this yourself
// import 'dart:io' show Platform;

// // Your api key storage.
// // import 'keys.dart.example';

// // Only to control hybrid composition and the renderer in Android
// import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// // void main() => runApp(MyApp());

// // class MyApp extends StatelessWidget {
// //   // Light Theme
// //   final ThemeData lightTheme = ThemeData.light().copyWith(
// //     // Background color of the FloatingCard
// //     cardColor: Colors.white,
// //   );

// //   // Dark Theme
// //   final ThemeData darkTheme = ThemeData.dark().copyWith(
// //     // Background color of the FloatingCard
// //     cardColor: Colors.grey,
// //   );

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Google Map Place Picker Demo',
// //       theme: lightTheme,
// //       darkTheme: darkTheme,
// //       themeMode: ThemeMode.light,
// //       home: HomePage(),
// //       debugShowCheckedModeBanner: false,
// //     );
// //   }
// // }

// class HomePage extends StatefulWidget {
//   HomePage({Key? key}) : super(key: key);

//   static final kInitialPosition = LatLng(-33.8567844, 151.213108);

//   final GoogleMapsFlutterPlatform mapsImplementation =
//       GoogleMapsFlutterPlatform.instance;

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   PickResult? selectedPlace;
//   bool _showPlacePickerInContainer = false;
//   bool _showGoogleMapInContainer = false;

//   static String androidApiKey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";

//   bool _mapsInitialized = false;
//   String _mapsRenderer = "latest";

//   void initRenderer() {
//     if (_mapsInitialized) return;
//     if (widget.mapsImplementation is GoogleMapsFlutterAndroid) {
//       switch (_mapsRenderer) {
//         case "legacy":
//           (widget.mapsImplementation as GoogleMapsFlutterAndroid)
//               .initializeWithRenderer(AndroidMapRenderer.legacy);
//           break;
//         case "latest":
//           (widget.mapsImplementation as GoogleMapsFlutterAndroid)
//               .initializeWithRenderer(AndroidMapRenderer.latest);
//           break;
//       }
//     }
//     setState(() {
//       _mapsInitialized = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Google Map Place Picker Demo"),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (!_mapsInitialized &&
//                       widget.mapsImplementation
//                           is GoogleMapsFlutterAndroid) ...[
//                     Switch(
//                         value: (widget.mapsImplementation
//                                 as GoogleMapsFlutterAndroid)
//                             .useAndroidViewSurface,
//                         onChanged: (value) {
//                           setState(() {
//                             (widget.mapsImplementation
//                                     as GoogleMapsFlutterAndroid)
//                                 .useAndroidViewSurface = value;
//                           });
//                         }),
//                     Text("Hybrid Composition"),
//                   ]
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (!_mapsInitialized &&
//                       widget.mapsImplementation
//                           is GoogleMapsFlutterAndroid) ...[
//                     Text("Renderer: "),
//                     Radio(
//                         groupValue: _mapsRenderer,
//                         value: "auto",
//                         onChanged: (value) {
//                           setState(() {
//                             _mapsRenderer = "auto";
//                           });
//                         }),
//                     Text("Auto"),
//                     Radio(
//                         groupValue: _mapsRenderer,
//                         value: "legacy",
//                         onChanged: (value) {
//                           setState(() {
//                             _mapsRenderer = "legacy";
//                           });
//                         }),
//                     Text("Legacy"),
//                     Radio(
//                         groupValue: _mapsRenderer,
//                         value: "latest",
//                         onChanged: (value) {
//                           setState(() {
//                             _mapsRenderer = "latest";
//                           });
//                         }),
//                     Text("Latest"),
//                   ]
//                 ],
//               ),
//               !_showPlacePickerInContainer
//                   ? ElevatedButton(
//                       child: Text("Load Place Picker"),
//                       onPressed: () {
//                         initRenderer();
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return PlacePicker(
//                                 resizeToAvoidBottomInset:
//                                     false, // only works in page mode, less flickery
//                                 apiKey:
//                                     // Platform.isAndroid
//                                     //     ?
//                                     androidApiKey,
//                                 // : APIKeys.iosApiKey,
//                                 hintText: "Find a place ...",
//                                 searchingText: "Please wait ...",
//                                 selectText: "Select place",
//                                 outsideOfPickAreaText: "Place not in area",
//                                 initialPosition: HomePage.kInitialPosition,
//                                 useCurrentLocation: true,
//                                 selectInitialPosition: true,
//                                 usePinPointingSearch: true,
//                                 usePlaceDetailSearch: true,
//                                 zoomGesturesEnabled: true,
//                                 zoomControlsEnabled: true,
//                                 ignoreLocationPermissionErrors: true,
//                                 onMapCreated: (GoogleMapController controller) {
//                                   print("Map created");
//                                 },
//                                 onPlacePicked: (PickResult result) {
//                                   print(
//                                       "Place picked: ${result.formattedAddress}");
//                                   setState(() {
//                                     selectedPlace = result;
//                                     Navigator.of(context).pop();
//                                   });
//                                 },
//                                 onMapTypeChanged: (MapType mapType) {
//                                   print(
//                                       "Map type changed to ${mapType.toString()}");
//                                 },
//                                 // #region additional stuff
//                                 // forceSearchOnZoomChanged: true,
//                                 // automaticallyImplyAppBarLeading: false,
//                                 // autocompleteLanguage: "ko",
//                                 // region: 'au',
//                                 // pickArea: CircleArea(
//                                 //   center: HomePage.kInitialPosition,
//                                 //   radius: 300,
//                                 //   fillColor: Colors.lightGreen
//                                 //       .withGreen(255)
//                                 //       .withAlpha(32),
//                                 //   strokeColor: Colors.lightGreen
//                                 //       .withGreen(255)
//                                 //       .withAlpha(192),
//                                 //   strokeWidth: 2,
//                                 // ),
//                                 // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
//                                 //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
//                                 //   return isSearchBarFocused
//                                 //       ? Container()
//                                 //       : FloatingCard(
//                                 //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
//                                 //           leftPosition: 0.0,
//                                 //           rightPosition: 0.0,
//                                 //           width: 500,
//                                 //           borderRadius: BorderRadius.circular(12.0),
//                                 //           child: state == SearchingState.Searching
//                                 //               ? Center(child: CircularProgressIndicator())
//                                 //               : ElevatedButton(
//                                 //                   child: Text("Pick Here"),
//                                 //                   onPressed: () {
//                                 //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
//                                 //                     //            this will override default 'Select here' Button.
//                                 //                     print("do something with [selectedPlace] data");
//                                 //                     Navigator.of(context).pop();
//                                 //                   },
//                                 //                 ),
//                                 //         );
//                                 // },
//                                 // pinBuilder: (context, state) {
//                                 //   if (state == PinState.Idle) {
//                                 //     return Icon(Icons.favorite_border);
//                                 //   } else {
//                                 //     return Icon(Icons.favorite);
//                                 //   }
//                                 // },
//                                 // introModalWidgetBuilder: (context,  close) {
//                                 //   return Positioned(
//                                 //     top: MediaQuery.of(context).size.height * 0.35,
//                                 //     right: MediaQuery.of(context).size.width * 0.15,
//                                 //     left: MediaQuery.of(context).size.width * 0.15,
//                                 //     child: Container(
//                                 //       width: MediaQuery.of(context).size.width * 0.7,
//                                 //       child: Material(
//                                 //         type: MaterialType.canvas,
//                                 //         color: Theme.of(context).cardColor,
//                                 //         shape: RoundedRectangleBorder(
//                                 //             borderRadius: BorderRadius.circular(12.0),
//                                 //         ),
//                                 //         elevation: 4.0,
//                                 //         child: ClipRRect(
//                                 //           borderRadius: BorderRadius.circular(12.0),
//                                 //           child: Container(
//                                 //             padding: EdgeInsets.all(8.0),
//                                 //             child: Column(
//                                 //               children: [
//                                 //                 SizedBox.fromSize(size: new Size(0, 10)),
//                                 //                 Text("Please select your preferred address.",
//                                 //                   style: TextStyle(
//                                 //                     fontWeight: FontWeight.bold,
//                                 //                   )
//                                 //                 ),
//                                 //                 SizedBox.fromSize(size: new Size(0, 10)),
//                                 //                 SizedBox.fromSize(
//                                 //                   size: Size(MediaQuery.of(context).size.width * 0.6, 56), // button width and height
//                                 //                   child: ClipRRect(
//                                 //                     borderRadius: BorderRadius.circular(10.0),
//                                 //                     child: Material(
//                                 //                       child: InkWell(
//                                 //                         overlayColor: MaterialStateColor.resolveWith(
//                                 //                           (states) => Colors.blueAccent
//                                 //                         ),
//                                 //                         onTap: close,
//                                 //                         child: Row(
//                                 //                           mainAxisAlignment: MainAxisAlignment.center,
//                                 //                           children: [
//                                 //                             Icon(Icons.check_sharp, color: Colors.blueAccent),
//                                 //                             SizedBox.fromSize(size: new Size(10, 0)),
//                                 //                             Text("OK",
//                                 //                               style: TextStyle(
//                                 //                                 color: Colors.blueAccent
//                                 //                               )
//                                 //                             )
//                                 //                           ],
//                                 //                         )
//                                 //                       ),
//                                 //                     ),
//                                 //                   ),
//                                 //                 )
//                                 //               ]
//                                 //             )
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //     )
//                                 //   );
//                                 // },
//                                 // #endregion
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     )
//                   : Container(),
//               !_showPlacePickerInContainer
//                   ? ElevatedButton(
//                       child: Text("Load Place Picker in Container"),
//                       onPressed: () {
//                         initRenderer();
//                         setState(() {
//                           _showPlacePickerInContainer = true;
//                         });
//                       },
//                     )
//                   : Container(
//                       width: MediaQuery.of(context).size.width * 0.75,
//                       height: MediaQuery.of(context).size.height * 0.35,
//                       child: PlacePicker(
//                           apiKey:
//                               // Platform.isAndroid
//                               //     ?
//                               androidApiKey,
//                           // : APIKeys.iosApiKey,
//                           hintText: "Find a place ...",
//                           searchingText: "Please wait ...",
//                           selectText: "Select place",
//                           initialPosition: HomePage.kInitialPosition,
//                           useCurrentLocation: true,
//                           selectInitialPosition: true,
//                           usePinPointingSearch: true,
//                           usePlaceDetailSearch: true,
//                           zoomGesturesEnabled: true,
//                           zoomControlsEnabled: true,
//                           ignoreLocationPermissionErrors: true,
//                           onPlacePicked: (PickResult result) {
//                             setState(() {
//                               selectedPlace = result;
//                               _showPlacePickerInContainer = false;
//                             });
//                           },
//                           onTapBack: () {
//                             setState(() {
//                               _showPlacePickerInContainer = false;
//                             });
//                           })),
//               if (selectedPlace != null) ...[
//                 Text(selectedPlace!.formattedAddress!),
//                 Text("(lat: " +
//                     selectedPlace!.geometry!.location.lat.toString() +
//                     ", lng: " +
//                     selectedPlace!.geometry!.location.lng.toString() +
//                     ")"),
//               ],
//               // #region Google Map Example without provider
//               _showPlacePickerInContainer
//                   ? Container()
//                   : ElevatedButton(
//                       child: Text("Toggle Google Map w/o Provider"),
//                       onPressed: () {
//                         initRenderer();
//                         setState(() {
//                           _showGoogleMapInContainer =
//                               !_showGoogleMapInContainer;
//                         });
//                       },
//                     ),
//               !_showGoogleMapInContainer
//                   ? Container()
//                   : Container(
//                       width: MediaQuery.of(context).size.width * 0.75,
//                       height: MediaQuery.of(context).size.height * 0.25,
//                       child: GoogleMap(
//                         zoomGesturesEnabled: false,
//                         zoomControlsEnabled: false,
//                         myLocationButtonEnabled: false,
//                         mapToolbarEnabled: false,
//                         initialCameraPosition: new CameraPosition(
//                             target: HomePage.kInitialPosition, zoom: 15),
//                         mapType: MapType.normal,
//                         myLocationEnabled: true,
//                         onMapCreated: (GoogleMapController controller) {},
//                         onCameraIdle: () {},
//                         onCameraMoveStarted: () {},
//                         onCameraMove: (CameraPosition position) {},
//                       )),
//               !_showGoogleMapInContainer ? Container() : TextField(),
//               // #endregion
//             ],
//           ),
//         ));
//   }
// }



















// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:google_maps_webservice/places.dart';
// // // import 'package:google_maps_webservice/google_maps_webservice.dart';
// // import 'package:flutter_google_places/flutter_google_places.dart';


// // const kGoogleApiKey = "YOUR_API_KEY";

// // // final googlePlace = GooglePlace(kGoogleApiKey);


// // class PlacesAutocompleteWidget extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Place Autocomplete Example"),
// //       ),
// //       body: Center(
// //         child: ElevatedButton(
// //           onPressed: () {
// //             showPlacesAutocomplete(context, kGoogleApiKey);
// //           },
// //           child: Text("Search for Places"),
// //         ),
// //       ),
// //     );
// //   }

// //    Future<void> showPlacesAutocomplete(BuildContext context, String apiKey) async {
// //     Prediction? p = await PlacesAutocomplete.show(
// //       context: context,
// //       apiKey: apiKey,
// //       mode: Mode.overlay,
// //       language: "en",
// //       components: [Component(Component.country, "US")],
// //     );

// //     if (p != null) {
// //       // Use the selected prediction (p) to get details or other information.
// //       var detail = await PlacesAutocomplete.getPlaceDetailByPlaceId(p.placeId, apiKey);
// //       if (detail != null) {
// //         double lat = detail.lat;
// //         double lng = detail.lng;
// //         print("Latitude: $lat");
// //         print("Longitude: $lng");
// //       }
// //     }
// //   }
// // }








// // // import 'dart:async';
// // // // import 'package:google_maps_webservice/places.dart';
// // // import 'package:flutter_google_places/flutter_google_places.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // // import 'package:location/location.dart' as LocationManage;
// // // // import 'place_detail.dart';

// // // const kGoogleApiKey = "AIzaSyA0eGBoFH35UACgzF4UZM34t2NC-SWDFIA";
// // // GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// // // void main() {
// // // runApp(MaterialApp(
// // // title: "PlaceZ",
// // // home: Home(),
// // // debugShowCheckedModeBanner: false,
// // // ));
// // // }

// // // class Home extends StatefulWidget {
// // // @override
// // // State<StatefulWidget> createState() {
// // // return HomeState();
// // // }
// // // }

// // // class HomeState extends State<Home> {
// // // final homeScaffoldKey = GlobalKey<ScaffoldState>();
// // // GoogleMapController mapController;
// // // List<PlacesSearchResult> places = [];
// // // bool isLoading = false;
// // // String errorMessage;

// // // @override
// // // Widget build(BuildContext context) {
// // // Widget expandedChild;
// // // if (isLoading) {
// // // expandedChild = Center(child: CircularProgressIndicator(value: null));
// // // } else if (errorMessage != null) {
// // // expandedChild = Center(
// // // child: Text(errorMessage),
// // // );
// // // } else {
// // // expandedChild = buildPlacesList();
// // // }

// // // return Scaffold(
// // // key: homeScaffoldKey,
// // // appBar: AppBar(
// // // title: const Text(“PlaceZ”),
// // // actions: <Widget>[
// // // isLoading
// // // ? IconButton(
// // // icon: Icon(Icons.timer),
// // // onPressed: () {},
// // // )
// // // : IconButton(
// // // icon: Icon(Icons.refresh),
// // // onPressed: () {
// // // refresh();
// // // },
// // // ),
// // // IconButton(
// // // icon: Icon(Icons.search),
// // // onPressed: () {
// // // _handlePressButton();
// // // },
// // // ),
// // // ],
// // // ),
// // // body: Column(
// // // children: <Widget>[
// // // Container(
// // // child: SizedBox(
// // // height: 200.0,
// // // child: GoogleMap(
// // // onMapCreated: _onMapCreated,
// // // options: GoogleMapOptions(
// // // myLocationEnabled: true,
// // // cameraPosition:
// // // const CameraPosition(target: LatLng(0.0, 0.0),),),),),
// // // ),
// // // Expanded(child: expandedChild)
// // // ],
// // // ));
// // // }

// // // void refresh() async {
// // // final center = await getUserLocation();

// // // mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
// // // target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
// // // getNearbyPlaces(center);
// // // }

// // // void _onMapCreated(GoogleMapController controller) async {
// // // mapController = controller;
// // // refresh();
// // // }

// // // Future<LatLng> getUserLocation() async {
// // // var currentLocation = <String, double>{};
// // // final location = LocationManager.Location();
// // // try {
// // // currentLocation = await location.getLocation();
// // // final lat = currentLocation[“latitude”];
// // // final lng = currentLocation[“longitude”];
// // // final center = LatLng(lat, lng);
// // // return center;
// // // } on Exception {
// // // currentLocation = null;
// // // return null;
// // // }
// // // }

// // // void getNearbyPlaces(LatLng center) async {
// // // setState(() {
// // // this.isLoading = true;
// // // this.errorMessage = null;
// // // });

// // // final location = Location(center.latitude, center.longitude);
// // // final result = await _places.searchNearbyWithRadius(location, 2500);
// // // setState(() {
// // // this.isLoading = false;
// // // if (result.status == “OK”) {
// // // this.places = result.results;
// // // result.results.forEach((f) {
// // // final markerOptions = MarkerOptions(
// // // position:
// // // LatLng(f.geometry.location.lat, f.geometry.location.lng),
// // // infoWindowText: InfoWindowText(“${f.name}”, “${f.types?.first}”));
// // // mapController.addMarker(markerOptions);
// // // });
// // // } else {
// // // this.errorMessage = result.errorMessage;
// // // }
// // // });
// // // }

// // // void onError(PlacesAutocompleteResponse response) {
// // // homeScaffoldKey.currentState.showSnackBar(
// // // SnackBar(content: Text(response.errorMessage)),
// // // );
// // // }

// // // Future<void> _handlePressButton() async {
// // // try {
// // // final center = await getUserLocation();
// // // Prediction p = await PlacesAutocomplete.show(
// // // context: context,
// // // strictbounds: center == null ? false : true,
// // // apiKey: kGoogleApiKey,
// // // onError: onError,
// // // mode: Mode.fullscreen,
// // // language: “en”,
// // // location: center == null
// // // ? null
// // // : Location(center.latitude, center.longitude),
// // // radius: center == null ? null : 10000);

// // // showDetailPlace(p.placeId);
// // // } catch (e) {
// // // return;
// // // }
// // // }

// // // Future<Null> showDetailPlace(String placeId) async {
// // // if (placeId != null) {
// // // Navigator.push(
// // // context,
// // // MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
// // // );
// // // }
// // // }

// // // ListView buildPlacesList() {
// // // final placesWidget = places.map((f) {
// // // List<Widget> list = [
// // // Padding(
// // // padding: EdgeInsets.only(bottom: 4.0),
// // // child: Text(
// // // f.name,
// // // style: Theme.of(context).textTheme.subtitle,
// // // ),
// // // )
// // // ];
// // // if (f.formattedAddress != null) {
// // // list.add(Padding(
// // // padding: EdgeInsets.only(bottom: 2.0),
// // // child: Text(
// // // f.formattedAddress,
// // // style: Theme.of(context).textTheme.subtitle,
// // // ),
// // // ));
// // // }

// // // if (f.vicinity != null) {
// // // list.add(Padding(
// // // padding: EdgeInsets.only(bottom: 2.0),
// // // child: Text(
// // // f.vicinity,
// // // style: Theme.of(context).textTheme.body1,
// // // ),
// // // ));
// // // }

// // // if (f.types?.first != null) {
// // // list.add(Padding(
// // // padding: EdgeInsets.only(bottom: 2.0),
// // // child: Text(
// // // f.types.first,
// // // style: Theme.of(context).textTheme.caption,
// // // ),
// // // ));
// // // }

// // // return Padding(
// // // padding: EdgeInsets.only(top: 4.0, bottom: 4.0, left: 8.0, right: 8.0),
// // // child: Card(
// // // child: InkWell(
// // // onTap: () {
// // // showDetailPlace(f.placeId);
// // // },
// // // highlightColor: Colors.lightBlueAccent,
// // // splashColor: Colors.red,
// // // child: Padding(
// // // padding: EdgeInsets.all(8.0),
// // // child: Column(
// // // mainAxisAlignment: MainAxisAlignment.start,
// // // crossAxisAlignment: CrossAxisAlignment.start,
// // // children: list,
// // // ),
// // // ),
// // // ),
// // // ),
// // // );
// // // }).toList();

// // // return ListView(shrinkWrap: true, children: placesWidget);
// // // }
// // // }