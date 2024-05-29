import 'package:flutter/material.dart';
import 'package:gps_location/location/mapKind.dart';
import 'package:gps_location/location/realLocation.dart';
import 'package:gps_location/location/checkLocationScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreenDemo extends StatefulWidget {
  const IntroScreenDemo({super.key});

  @override
  State<IntroScreenDemo> createState() => _IntroScreenDemoState();
}

class _IntroScreenDemoState extends State<IntroScreenDemo> {
  // 1. Define a `GlobalKey` as part of the parent widget's state
  final _introKey = GlobalKey<IntroductionScreenState>();
  final String _status = 'Click...';
  bool serviceEnabledd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: IntroductionScreen(
          pages: [
            PageViewModel(
              titleWidget: Text(
                'Publish to Map',
                style: GoogleFonts.cabin(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
              bodyWidget: Text(
                'Allow GPS Phone Tracker to access this devices location to know where you are',
                style: GoogleFonts.cabin(
                  color: Colors.black45,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              image: buildImage("assets/images/intro1.png"),
              //getPageDecoration, a method to customise the page style
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              titleWidget: Text(
                'Nearby Popular Places',
                style: GoogleFonts.cabin(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
              bodyWidget: Text(
                'Locate your nearby location on maps to visit',
                style: GoogleFonts.cabin(
                  color: Colors.black45,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              image: buildImage("assets/images/intro2.png"),
              //getPageDecoration, a method to customise the page style
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              titleWidget: Text(
                'Favorite places',
                style: GoogleFonts.cabin(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
              bodyWidget: Text(
                'Add visited places to favorite to locate again and easily',
                style: GoogleFonts.cabin(
                  color: Colors.black45,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
              image: buildImage("assets/images/favorite.png"),
              //getPageDecoration, a method to customise the page style
              decoration: getPageDecoration(),
            ),
            // PageViewModel(
            //   title: 'Title of 3rd Page',
            //   body: 'Body of 3rd Page',
            //   image: buildImage("assets/images/introMap.jpeg"),
            //   //getPageDecoration, a method to customise the page style
            //   decoration: getPageDecoration(),
            // ),
          ],
          onDone: () async {
            // if (kDebugMode) {
            print("Done clicked");
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse) {
              // Fluttertoast.showToast(msg: "DONETRUE");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MapTypesScreen()),
              );
            } else {
              // Fluttertoast.showToast(msg: "DONEFALSE");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AskScreen()),
              );
            }
            // }
          },
          //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
          scrollPhysics: const ClampingScrollPhysics(),
          showDoneButton: true,
          showNextButton: true,
          // showSkipButton: true,
          // isBottomSafeArea: true,
          skip:
              const Text("Skip", style: TextStyle(fontWeight: FontWeight.w600)),
          next: const Icon(Icons.forward),
          done:
              const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: getDotsDecorator()),
    );
  }

  Widget buildImage(String imagePath) {
    return Center(
      child: Image.asset(
        imagePath,
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.6,
      ),
    );
  }

  //method to customise the page style
  PageDecoration getPageDecoration() {
    return const PageDecoration(
      imagePadding: EdgeInsets.only(top: 50),
      pageColor: Colors.white,
      bodyPadding: EdgeInsets.only(top: 8, left: 20, right: 20),
      titlePadding: EdgeInsets.only(top: 50),
      bodyTextStyle: TextStyle(color: Colors.black54, fontSize: 15),
    );
  }

  //method to customize the dots style
  DotsDecorator getDotsDecorator() {
    return const DotsDecorator(
      spacing: EdgeInsets.symmetric(horizontal: 2),
      activeColor: Colors.indigo,
      color: Colors.grey,
      activeSize: Size(12, 5),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }
}
