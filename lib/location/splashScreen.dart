// import 'package:flutter/material.dart';
// import 'package:flutter_voice_recording_to_text_convert/location/checkLocationScreen.dart';
// import 'package:flutter_voice_recording_to_text_convert/location/introScreen.dart';
// import 'package:flutter_voice_recording_to_text_convert/location/realLocation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_gif/flutter_gif.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   bool serviceEnabledd = false;
//   final splashDelay = 2;
//   // Location location = ;
//   // bool checkLoc = Permission.location.isGranted;
//   @override
//   void initState() {
//     super.initState();

//     // funcc();
//     controller = FlutterGifController(vsync: this);
//     controller.repeat(min: 0, max: 50, period: const Duration(seconds: 3));
//     // _loadWidget();
//     // Future.delayed(Duration(seconds: 3), () {
//     //   // Navigate to the CurrentLocationScreen after the splash screen is done
//     //   Navigator.pushReplacement(
//     //     context,
//     //     MaterialPageRoute(builder: (context) => IntroScreenDemo()),
//     //   );
//     // });
//   }

//   _loadWidget() async {
//     var _duration = Duration(seconds: splashDelay);
//     return Timer(_duration, checkFirstSeen);
//   }

//   Future checkFirstSeen() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool _introSeen = (prefs.getBool('intro_seen') ?? false);

//     Navigator.pop(context);
//     if (_introSeen) {
//       // Navigator.pushNamed(context, Routing.HomeViewRoute);
//       Future.delayed(Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => CurrentLocationScreen()),
//         );
//       });
//     } else {
//       await prefs.setBool('intro_seen', true);
//       // Navigator.pushNamed(context, Routing.IntroViewRoute);
//       Future.delayed(Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => AskScreen()),
//         );
//       });
//     }
//   }

//   // FlutterGifController controller = FlutterGifController(vsync: this);
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     controller.dispose();
//     super.dispose();
//   }

//   // Future<void> funcc() async {
//   //   serviceEnabledd = await Geolocator.isLocationServiceEnabled();

//   //   if (serviceEnabledd) {
//   //     Fluttertoast.showToast(msg: "LOCTRUE");
//   //   } else {
//   //     Fluttertoast.showToast(msg: "FALSE");
//   //   }
//   //   if (serviceEnabledd) {
//   //     Future.delayed(Duration(seconds: 5), () {
//   //       CircularProgressIndicator();
//   //       // Navigate to the CurrentLocationScreen after the splash screen is done
//   //       // Navigator.pushReplacement(
//   //       //   context,
//   //       //   MaterialPageRoute(builder: (context) => AskScreen()),
//   //       // );
//   //     });
//   //   } else {
//   //     Future.delayed(Duration(seconds: 5), () {
//   //       // CircularProgressIndicator();
//   //       // Navigate to the CurrentLocationScreen after the splash screen is done
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => CurrentLocationScreen()),
//   //       );
//   //     });
//   //   }
//   // }

//   late FlutterGifController controller;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: GifImage(
//           controller: controller,
//           image: AssetImage("assets/images/splash.gif"),
//         ),
//       ),
//     );
//   }

//   // AskScreen objs = AskScreen();
// }
