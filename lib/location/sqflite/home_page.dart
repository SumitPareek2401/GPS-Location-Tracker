import 'package:flutter/material.dart';
import 'database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'dart:ui' as ui;

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  _LocationListScreenState createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
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
      body: FutureBuilder<List<Location>>(
        future: LocationDatabase.instance.getLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final locations = snapshot.data;

            return locations != null && locations.isNotEmpty
                ? ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 15,
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.215,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(130, 221, 240, 177),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                // color: Colors.red,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 4, 12, 4),
                                      // horizontal: 12.0, vertical: 8),
                                      child: Text(
                                        location.placeName,
                                        style: GoogleFonts.cabin(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 4),
                                      child: Text(
                                        'Latitude: ${location.latitude}, \nLongitude: ${location.longitude}',
                                        style: GoogleFonts.cabin(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                // color: Colors.blue,
                                height:
                                    MediaQuery.of(context).size.height * 0.165,
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const ui.Color.fromARGB(
                                                255, 68, 138, 196),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                      onPressed: () => MapsLauncher.launchQuery(
                                          location.placeName),
                                      child: Text(
                                        'Locate',
                                        style: GoogleFonts.cabin(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const ui.Color.fromARGB(
                                                255, 68, 138, 196),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          // openGoogleMapsForNearbyPlaces("Restaurants"),
                                          _deleteLocation(location.id!),
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.cabin(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
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
                      // ListTile(
                      //   title: Text(location.placeName),
                      //   subtitle: Text(
                      //     'Latitude: ${location.latitude}, Longitude: ${location.longitude}',
                      //   ),
                      //   trailing: Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       IconButton(
                      //         padding: EdgeInsets.zero,
                      //         constraints: BoxConstraints(),
                      //         // onPressed: () {
                      //         onPressed: () =>
                      //             MapsLauncher.launchQuery(location.placeName),
                      //         // },
                      //         icon: Icon(Icons.close),
                      //       ),
                      //       IconButton(
                      //         padding: EdgeInsets.zero,
                      //         constraints: BoxConstraints(),
                      //         icon: Icon(Icons.delete),
                      //         onPressed: () {
                      //           _deleteLocation(location.id!);
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                  )
                : const Center(
                    child: Text('No locations added.'),
                  );
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   onPressed: () {
      //     // Navigate to the screen for adding a new location.
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => AddLocationScreen(),
      //       ),
      //     );
      //   },
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.black,
      //   ),
      // ),
    );
  }

  void _deleteLocation(int id) {
    LocationDatabase.instance.deleteLocation(id).then((_) {
      setState(() {});
    });
  }
}

// import 'package:flutter/material.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Location',
          style: GoogleFonts.cabin(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.055,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              validator: (value) {
                if (placeNameController.text.isEmpty) {
                  return "Place Name required";
                }
                return null;
              },
              controller: placeNameController,
              decoration: const InputDecoration(labelText: 'Place Name'),
            ),
            // TextField(
            //   controller: latitudeController,
            //   decoration: InputDecoration(labelText: 'Latitude'),
            // ),
            // TextField(
            //   controller: longitudeController,
            //   decoration: InputDecoration(labelText: 'Longitude'),
            // ),
            const SizedBox(height: 26.0),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: ui.Color.fromARGB(255, 68, 138, 196),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.all(
            //         Radius.circular(20),
            //       ),
            //     ),
            //   ),
            //   onPressed: () {
            //     // Save the location to the database
            //     _saveLocation();
            //   },
            //   child: Text(
            //     'Save Location',
            //     style: GoogleFonts.cabin(
            //       color: Colors.white,
            //       fontSize: MediaQuery.of(context).size.width * 0.05,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _saveLocation() {
    final String placeName = placeNameController.text;
    final double latitude = double.tryParse(latitudeController.text) ?? 0.0;
    final double longitude = double.tryParse(longitudeController.text) ?? 0.0;

    if (placeName.isNotEmpty) {
      final location = Location(
        placeName: placeName,
        latitude: latitude,
        longitude: longitude,
      );

      LocationDatabase.instance.addLocation(location).then((locationId) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location saved with ID: $locationId'),
        ));
        // Navigate back to the location list screen or any other screen.
        Navigator.pop(context);
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
}
















// import 'package:flutter/material.dart';
// // import 'package:flutter_sqflite_example/common_widgets/dog_builder.dart';
// // import 'package:flutter_sqflite_example/common_widgets/breed_builder.dart';
// import 'placeDetail.dart';
// // import 'package:flutter_sqflite_example/models/dog.dart';
// // import 'package:flutter_sqflite_example/pages/breed_form_page.dart';
// // import 'package:flutter_sqflite_example/pages/dog_form_page.dart';
// import 'database_service.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final DatabaseService _databaseService = DatabaseService();

//   Future<List<Dog>> _getDogs() async {
//     return await _databaseService.dogs();
//   }

//   // Future<List<Breed>> _getBreeds() async {
//   //   return await _databaseService.breeds();
//   //  }

//   // Future<void> _onDogDelete(Dog dog) async {
//   //   await _databaseService.deleteDog(dog.id!);
//   //   setState(() {});
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Favorite Place'),
//       ),
//       // body: ,
//     );
//   }
// }

// // DefaultTabController(
// //       length: 2,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: Text('Dog Database'),
// //           centerTitle: true,
// //           bottom: TabBar(
// //             tabs: [
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                 child: Text('Dogs'),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(vertical: 16.0),
// //                 child: Text('Breeds'),
// //               ),
// //             ],
// //           ),
// //         ),
// //         body: TabBarView(
// //           children: [
// //             // DogBuilder(
// //             //   future: _getDogs(),
// //             //   onEdit: (value) {
// //             //     {
// //             //       Navigator.of(context)
// //             //           .push(
// //             //             MaterialPageRoute(
// //             //               builder: (_) => DogFormPage(dog: value),
// //             //               fullscreenDialog: true,
// //             //             ),
// //             //           )
// //             //           .then((_) => setState(() {}));
// //             //     }
// //             //   },
// //             //   onDelete: _onDogDelete,
// //             // ),
// //             BreedBuilder(
// //               future: _getBreeds(),
// //             ),
// //           ],
// //         ),
// //         floatingActionButton: Column(
// //           mainAxisAlignment: MainAxisAlignment.end,
// //           children: [
// //             FloatingActionButton(
// //               onPressed: () {
// //                 Navigator.of(context)
// //                     .push(
// //                       MaterialPageRoute(
// //                         builder: (_) => BreedFormPage(),
// //                         fullscreenDialog: true,
// //                       ),
// //                     )
// //                     .then((_) => setState(() {}));
// //               },
// //               heroTag: 'addBreed',
// //               child: FaIcon(FontAwesomeIcons.plus),
// //             ),
// //             SizedBox(height: 12.0),
// //             FloatingActionButton(
// //               onPressed: () {
// //                 Navigator.of(context)
// //                     .push(
// //                       MaterialPageRoute(
// //                         builder: (_) => DogFormPage(),
// //                         fullscreenDialog: true,
// //                       ),
// //                     )
// //                     .then((_) => setState(() {}));
// //               },
// //               heroTag: 'addDog',
// //               child: FaIcon(FontAwesomeIcons.paw),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );