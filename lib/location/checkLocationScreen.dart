import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:gps_location/location/mapKind.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:permission_handler/permission_handler.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  bool isSwitched = false;
  bool status = false;
  var textValue = 'Switch is OFF';
  bool loading = false; // Add this variable

  void toggleSwitch(bool value) async {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
        loading = true;
        status = true;
      });
      await _requestPermission().then((permissionGranted) {
        setState(() {
          loading =
              false; // Set loading to false regardless of permission outcome
          if (!permissionGranted) {
            isSwitched =
                false; // If permission is not granted, turn off the switch
            status = false;
          }
        });

        // ... rest of your code
      }).catchError((error) {
        print('Error: $error');
        // Handle errors if needed
        setState(() {
          loading = false; // Set loading to false on error
          isSwitched =
              false; // If permission is not granted, turn off the switch
          status = false;
        });
      });
      await _determinePosition();

      print('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
        loading = false;
        status = false;
      });
      // if (serviceEnabled) {
      // setState(() {});

      // }
      print('Switch Button is OFF');
    }
  }

  Future<bool> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        // Permission is denied, turn off the switch
        setState(() {
          isSwitched = false;
          textValue = 'Switch Button is OFF';
          loading = false;
          status = false;
        });
        return false;
      }
    }

    return true; // Permission is granted or already granted
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   return permission == LocationPermission.always ||
    //       permission == LocationPermission.whileInUse;
    // } else {
    //   return true; // Permission already granted
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Permission',
            style: GoogleFonts.cabin(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width * 0.06,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                Center(
                  child: Image.asset(
                    "assets/images/location.png",
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: Text(
                    'GPS Tracker: Family Locator requires permission to access device\'s location',
                    style: GoogleFonts.cabin(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.055,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.width * 0.046,
                  ),
                  child: Container(
                    // width: MediaQuery.of(context).size.width * 0.96,
                    height: MediaQuery.of(context).size.width * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[300],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Device\'s Location',
                          style: GoogleFonts.cabin(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                          ),
                        ),
                        FlutterSwitch(
                          activeColor: Colors.green,
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.width * 0.1,
                          valueFontSize: 30.0,
                          toggleSize: 25.0,
                          value: status,
                          borderRadius: 30.0,
                          padding: 8.0,
                          // showOnOff: true,
                          onToggle: (val) async {
                            setState(() {
                              status = val;
                              toggleSwitch(val);
                              // setState(() {});
                            });
                          },
                        ),
                        // Switch(
                        //   onChanged: toggleSwitch,
                        //   value: isSwitched,
                        //   activeColor: Colors.blue,
                        //   activeTrackColor: Colors.green,
                        //   inactiveThumbColor: Colors.redAccent,
                        //   inactiveTrackColor: Colors.orange,
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  bool serviceEnabled = false;
  Future<Position> _determinePosition() async {
    // serviceEnabled = false;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }
    // if (serviceEnabled) {
    //   setState(() {});
    //   Fluttertoast.showToast(msg: "ENABLE");
    // }
    bool permissionGranted = false;

    while (!permissionGranted) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          return Future.error("Location permission denied");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showInfoDialog(context);
        return Future.error('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition();
      LocationPermission permissionCheck = await Geolocator.checkPermission();

      if (permissionCheck == LocationPermission.always ||
          permissionCheck == LocationPermission.whileInUse) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapTypesScreen()),
        );
        permissionGranted = true;
      } else if (permissionCheck == LocationPermission.deniedForever) {
        // per.openAppSettings();
        _showInfoDialog(context);
        break;
      } else {
        // You can handle the case where the user denies permission if needed
        // For example, you can show a message or take appropriate action
        print('Location permission denied');
        // You might want to add a delay here to avoid continuously asking in a tight loop
        await Future.delayed(Duration(seconds: 1));
      }
    }
    // permission = await Geolocator.checkPermission();

    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();

    //   if (permission == LocationPermission.denied) {
    //     return Future.error("Location permission denied");
    //   }
    // }
    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error('Location permissions are permanently denied');
    // }
    // if (serviceEnabled) {
    //   setState(() {});
    // }
    Position position = await Geolocator.getCurrentPosition();
    LocationPermission permissionCheck = await Geolocator.checkPermission();
    if (permissionCheck == LocationPermission.always ||
        permissionCheck == LocationPermission.whileInUse) {
      // isSwitched = true;
      // status = true;
      // Fluttertoast.showToast(msg: "Waiting...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapTypesScreen()),
      );
    } else {
      setState(() {
        isSwitched = false;
        status = false;
        loading = false;
      });
    }

    return position;
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'To use app, please allow access to your location. We cannot move forward without this permission',
                  style: GoogleFonts.cabin(
                    color: Colors.black54,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.width * 0.045),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),

                  // textColor: Colors.black,
                  onPressed: () {
                    openAppSettings();
                    // Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Allow',
                      style: GoogleFonts.cabin(
                        color: Colors.blue,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
