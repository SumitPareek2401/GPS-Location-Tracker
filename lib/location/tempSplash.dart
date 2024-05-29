import 'package:flutter/material.dart';
import 'package:gps_location/location/checkLocationScreen.dart';
import 'package:gps_location/location/introScreen.dart';
import 'package:gps_location/location/mapKind.dart';
import 'package:gps_location/location/realLocation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class TempSplashScreen extends StatefulWidget {
  const TempSplashScreen({super.key});

  @override
  State<TempSplashScreen> createState() => _TempSplashScreenState();
}

class _TempSplashScreenState extends State<TempSplashScreen>
    with SingleTickerProviderStateMixin {
  bool serviceEnabledd = false;
  final splashDelay = 2;
  // Location location = ;
  // bool checkLoc = Permission.location.isGranted;
  @override
  void initState() {
    super.initState();

    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, checkFirstSeen);
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _introSeen = (prefs.getBool('intro_seen') ?? false);
    LocationPermission permissionCheck = await Geolocator.checkPermission();

    // Navigator.pop(context);
    if (_introSeen &&
        (permissionCheck == LocationPermission.always ||
            permissionCheck == LocationPermission.whileInUse)) {
      // Navigator.pushNamed(context, Routing.HomeViewRoute);
      Future.delayed(Duration(seconds: 0), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapTypesScreen()),
        );
      });
    } else {
      await prefs.setBool('intro_seen', true);
      // Navigator.pushNamed(context, Routing.IntroViewRoute);
      Future.delayed(Duration(seconds: 0), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => IntroScreenDemo()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/images/splash3.png",
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
            Text(
              'GPS Tracker: Family Locator',
              style: GoogleFonts.cabin(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
          ],
        ),
      ),
      // Container(
      //   decoration: BoxDecoration(
      //     // color: Colors.black54,
      //     borderRadius: BorderRadius.circular(20),
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: [
      //         Colors.black,
      //         Colors.black87,
      //         Colors.black54,
      //         // Colors.black26,
      //       ],
      //     ),
      //   ),
      //   child: Center(
      //     child: Image.asset(
      //       "assets/images/splash2.jpg",
      //       width: MediaQuery.of(context).size.width * 0.7,
      //       height: MediaQuery.of(context).size.height * 0.3,
      //     ),
      //     // Image(
      //     //   // controller: controller,
      //     //   image: AssetImage("assets/images/splash2.jpg",),
      //     // ),
      //   ),
      // ),
    );
  }
}
