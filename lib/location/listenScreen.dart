// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// // import 'package:flutter_voice_recording_to_text_convert/speech_to_text/provider.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:string_stats/string_stats.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

// import 'dart:async';

// enum TtsState { playing, stopped }

// class SpeechToTextPage extends StatefulWidget {
//   // final Note note;
//   const SpeechToTextPage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   SpeechToTextPageState createState() => SpeechToTextPageState();
// }

// class SpeechToTextPageState extends State<SpeechToTextPage> {
//   final SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   bool _speechAvailable = false;
//   String _lastWords = '';
//   String resultWords = '';
//   String _currentWords = '';
//   final List<String> _removedWords = [];
//   final String _selectedLocaleId = 'en_En';

//   printLocales() async {
//     var locales = await _speechToText.locales();
//     for (var local in locales) {
//       debugPrint(local.name);
//       debugPrint(local.localeId);
//       debugPrint(_currentWords);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//     initTts();
//   }

//   void errorListener(SpeechRecognitionError error) {
//     debugPrint(error.errorMsg.toString());
//     Fluttertoast.showToast(msg: "Unable to detect");
//     Fluttertoast.showToast(msg: "Please restart mic");
//   }

//   void statusListener(String status) async {
//     debugPrint("status $status");
//     if (status == "done" && _speechEnabled) {
//       setState(() {
//         if (_currentWords != " " && _currentWords != "") {
//           _lastWords += " $_currentWords";
//           resultWords += " $_currentWords";
//           _currentWords = "";
//           _speechEnabled = false;

//           // final updatedNote = note?.copyWith(
//           //       title: titleController.text,
//           //       content: bodyController.text,
//           //       createdDateTime: dateTimenow.toString().substring(0, 16),
//           //     ) ??
//           //     Note(
//           //       title: titleController.text,
//           //       content: bodyController.text,
//           //       createdDateTime: dateTimenow.toString().substring(0, 16),
//           //     );

//           // if (note != null) {
//           //   noteController.updateNote(updatedNote);
//           // } else {
//           //   noteController.saveNote(updatedNote);
//           // }
//           // Get.back();
//         }
//       });
//       await _startListening();
//     }
//   }

//   double volume = 0.9;
//   double rate = 0.5;
//   double pitch = 0.6;

//   /// This has to happen only once per app
//   void _initSpeech() async {
//     _speechAvailable = await _speechToText.initialize(
//         onError: errorListener, onStatus: statusListener);
//     setState(() {});
//   }

//   Future _speak(String message) async {
//     if (Platform.isIOS) {
//       volume = 0.7;
//     } else {
//       volume = 1;
//     }
//     await flutterTts?.setVolume(volume);
//     await flutterTts?.setSpeechRate(rate);
//     await flutterTts?.setPitch(pitch);
//     if (message.isNotEmpty) {
//       //!= null) {
//       if (message.isNotEmpty) {
//         Fluttertoast.showToast(msg: "TEXT");
//         speechStarted = true;
//         var result = await flutterTts?.speak(message);
//         if (result == 1) setState(() => ttsState = TtsState.playing);
//       }
//     } else {
//       Fluttertoast.showToast(msg: "eMTPy TEXT");
//     }
//   }

//   /// Each time to start a speech recognition session
//   Future _startListening() async {
//     debugPrint("=================================================");
//     await _stopListening();
//     await Future.delayed(const Duration(milliseconds: 50));
//     await _speechToText.listen(
//         onResult: _onSpeechResult,
//         localeId: _selectedLocaleId,
//         cancelOnError: false,
//         partialResults: true,
//         listenMode: ListenMode.dictation);
//     setState(() {
//       _speechEnabled = true;
//     });
//   }

//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   Future _stopListening() async {
//     setState(() {
//       _speechEnabled = false;
//     });
//     await _speechToText.stop();
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _currentWords = result.recognizedWords;
//     });
//   }

//   FlutterTts? flutterTts;
//   TtsState ttsState = TtsState.stopped;
//   double fontsize = 0.0;
//   initTts() {
//     flutterTts = FlutterTts();

//     _getLanguages();

//     flutterTts?.setStartHandler(() {
//       setState(() {
//         ttsState = TtsState.playing;
//       });
//     });

//     flutterTts?.setCompletionHandler(() {
//       setState(() {
//         ttsState = TtsState.stopped;
//         speechStarted = false;
//       });
//     });

//     flutterTts?.setErrorHandler((msg) {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });
//     flutterTts?.stop();
//   }

//   bool speechStarted = false;
//   void stopSpeech() {
//     setState(() {
//       speechStarted = false;
//     });
//     flutterTts?.pause();
//   }

//   void continueSpeech() async {
//     if (!speechStarted) {
//       speechStarted = true;
//       var result =
//           await flutterTts?.speak(_lastWords.substring(_currentWords.length));
//       if (result == 1) {
//         setState(() => ttsState = TtsState.playing);
//       }
//     }
//   }

//   dynamic languages;
//   Future _getLanguages() async {
//     languages = await flutterTts?.getLanguages;
//     if (languages != null) setState(() => languages);
//   }

//   final GlobalKey<PopupMenuButtonState<int>> _key = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     // fontsize = MediaQuery.of(context).size.width * 0.045;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Speech Demo',
//           style: GoogleFonts.cabin(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () async {
//               if (_lastWords.isNotEmpty) {
//                 speechStarted == true ? stopSpeech() : continueSpeech();
//                 // Fluttertoast.showToast(msg: msg);
//               } else {
//                 Fluttertoast.showToast(msg: "Nothing to say");
//                 // _speak("Please say something");
//               }
//             },
//             icon: Icon(
//               speechStarted == false ? Icons.play_arrow : Icons.stop,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         // crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(_lastWords),
//           Center(
//             child: InkWell(
//               onTap:
//                   // () {
//                   //   // print("VA/LUE:${provider.textsizeP}");
//                   //   provider.printSize();
//                   //   print("GETTER:${provider.sizee}");
//                   // },
//                   _speechToText.isNotListening
//                       ? _startListening
//                       : _stopListening,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   // horizontal: MediaQuery.of(context).size.width * 0.4,
//                   vertical: 20, //MediaQuery.of(context).size.width * 0.15,
//                 ),
//                 child: Container(
//                   height: MediaQuery.of(context).size.width * 0.15,
//                   width: MediaQuery.of(context).size.width * 0.15,
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 39, 97, 177),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Icon(
//                     _speechToText.isNotListening ? Icons.mic : Icons.square,
//                     color: Colors.white,
//                     size: MediaQuery.of(context).size.width * 0.09,
//                   ),
//                   // Icon(
//                   //   Icons.mic,
//                   //   color: Colors.white,
//                   //   size: MediaQuery.of(context).size.width * 0.1,
//                   // ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//     // floatingActionButton: FloatingActionButton(
//     //   onPressed:
//     //       _speechToText.isNotListening ? _startListening : _stopListening,
//     //   tooltip: 'Listen',
//     //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
//     // ),
//   }

//   List<String> notes = ["Page 1 initial text"];
//   int currentPageIndex = 0;
//   PageController pageController = PageController(initialPage: 0);

//   void updateNoteText(String newText) {
//     notes[currentPageIndex] = newText;
//   }

//   // _launchWhatsApp(String url) async {
//   //   if (await canLaunchUrl(Uri.parse(url))) {
//   //     await launchUrl(Uri.parse(url));
//   //   } else {
//   //     throw 'Could not launch $url';
//   //   }
//   // }

//   Widget buildCopyButton() {
//     return ListTile(
//       leading: const Icon(Icons.copy_all),
//       title: Text(
//         "Copy all",
//         style: GoogleFonts.cabin(
//           color: Colors.black,
//           fontSize: MediaQuery.of(context).size.width * 0.04,
//         ),
//       ),
//     );
//   }

//   void _showInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'Info',
//             style: GoogleFonts.cabin(
//               color: Colors.black,
//               fontSize: MediaQuery.of(context).size.width * 0.05,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Creation date:',
//                 style: GoogleFonts.cabin(
//                   color: Colors.black54,
//                   fontSize: MediaQuery.of(context).size.width * 0.045,
//                 ),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 'Words count: ${wordCount(_lastWords)}',
//                 style: GoogleFonts.cabin(
//                   color: Colors.black54,
//                   fontSize: MediaQuery.of(context).size.width * 0.045,
//                 ),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 'Characters count: ${charCount(_lastWords)}',
//                 style: GoogleFonts.cabin(
//                   color: Colors.black54,
//                   fontSize: MediaQuery.of(context).size.width * 0.045,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 elevation: 0,
//               ),

//               // textColor: Colors.black,
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text(
//                 'OK',
//                 style: GoogleFonts.cabin(
//                   color: Colors.blue,
//                   fontSize: MediaQuery.of(context).size.width * 0.04,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:scroll_to_index/scroll_to_index.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// enum TtsState { playing, stopped }

// /*
// Title:HomePageScreen
// Purpose:HomePageScreen
// Created By:Kalpesh Khandla
// */

// class ListenClass extends StatefulWidget {
//   ListenClass({Key? key}) : super(key: key);

//   @override
//   _ListenClassState createState() => _ListenClassState();
// }

// class _ListenClassState extends State<ListenClass>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   final SpeechToText speech = SpeechToText();
//   bool _hasSpeech = false;
//   bool speechTest = false;
//   bool _isAnimating = false;
//   bool isMatchFound = false;
//   String lastError = "";
//   String lastStatus = "";
//   String lastWords = "";
//   String totalWords = "";
//   PersistentBottomSheetController?
//       _controller; // = PersistentBottomSheetController<T>;
//   late final AnimationController _animationController;
//   GlobalKey<ScaffoldState> _key = GlobalKey();
//   dynamic languages;
//   FlutterTts? flutterTts;
//   TtsState ttsState = TtsState.stopped;
//   double volume = 0.5;
//   double rate = 0.5;
//   double pitch = 1.0;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initSpeechState();
//     _animationController = AnimationController(
//       vsync: this,
//       lowerBound: 0.7,
//       duration: Duration(seconds: 3),
//       // reverseDuration: Duration(seconds: 5),
//     )..repeat();
//     initTts();
//   }

//   initTts() {
//     flutterTts = FlutterTts();

//     _getLanguages();

//     flutterTts?.setStartHandler(() {
//       setState(() {
//         ttsState = TtsState.playing;
//       });
//     });

//     flutterTts?.setCompletionHandler(() {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });

//     flutterTts?.setErrorHandler((msg) {
//       setState(() {
//         ttsState = TtsState.stopped;
//       });
//     });
//   }

//   Future _getLanguages() async {
//     languages = await flutterTts?.getLanguages;
//     if (languages != null) setState(() => languages);
//   }

//   Future<void> initSpeechState() async {
//     bool hasSpeech = await speech.initialize(
//       onError: errorListener,
//       onStatus: statusListener,
//       debugLogging: false,
//     );

//     if (!mounted) return;
//     setState(() {
//       _hasSpeech = hasSpeech;
//     });
//   }

//   void errorListener(SpeechRecognitionError error) {
//     setState(() {
//       lastError = "${error.errorMsg} - ${error.permanent}";
//     });
//   }

//   void statusListener(String status) {
//     if (status == "listening") {
//     } else if (status == "notListening") {
//       _animationController.reset();
//       _isAnimating = false;
//     }
//   }

//   void resultListenerCheck(SpeechRecognitionResult result) {
//     // Future.delayed(const Duration(seconds: 5), () {
//     if (!speech.isListening) {
//       resultListener(result);
//     }
//     // });
//   }

//   void nullFunc(String strNull) {
//     DateTime currentDate = DateTime.now();
//     messagess.add(strNull);
//     datalist.add(
//       currentDate.toString().substring(10, 19),
//     );
//   }

//   void resultListener(SpeechRecognitionResult result) {
//     _animationController.reset();
//     _isAnimating = false;

//     _controller!.setState!(() {
//       //lastWords = "${result.recognizedWords} - ${result.finalResult}";
//       lastWords = "${result.recognizedWords}";
//       DateTime currentDate = DateTime.now();
//       _speak(lastWords);
//       // Future.delayed(Duration(seconds: 2), () {
//       // print("Wait for 10 seconds");
//       // Navigator.pop(context, lastWords);
//       // Navigator.pop(context, lastWords);
//       // });

//       messagess.add(lastWords);
//       datalist.add(
//         currentDate.toString().substring(10, 19),
//       );
//       // if (speech.isListening) nullFunc(lastWords);
//     });
//     if (speech.isListening) {
//       return;
//     } else {
//       lastWords.isNotEmpty && //!= null &&
//           lastWords.length > 0 &&
//           !speech.isListening &&
//           !isMatchFound;

//       ///lastWords="Sorry No Match Founds";
//       isMatchFound = true;
//       // _speak("sorry we can not found any match! please try again");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _key,
//       resizeToAvoidBottomInset: false,
//       body: Padding(
//         padding: const EdgeInsets.only(
//           left: 15,
//           right: 15,
//           top: 30,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 // _speak("sorry we can not found any match! please try again");
//                 getBottomSheet(context);
//                 startListening();
//               },
//               child: Image.asset(
//                 'assets/images/mike2.png',
//                 height: 120,
//                 width: 200,
//               ),
//             ),
//             Text(
//               "Tap on Mike to Convert Your Speech to Text",
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     fontSize: 18,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w700,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void stopListening() {
//     speech.stop();
//   }

//   void startListening() {
//     _animationController.addListener(() {
//       // setState(() {});
//     });
//     //_animationController.forward();
//     _animationController.repeat(period: Duration(seconds: 2));
//     _isAnimating = true;
//     lastWords = "";
//     lastError = "";
//     isMatchFound = false;
//     int listenForSeconds = 30;
//     if (Platform.isIOS) {
//       listenForSeconds = 25;
//     }
//     Duration listenFor = Duration(seconds: listenForSeconds);

//     speech.listen(onResult: resultListenerCheck, listenFor: listenFor);
//     setState(() {
//       speechTest = true;
//     });
//   }

//   Future _speak(String message) async {
//     if (Platform.isIOS) {
//       volume = 0.7;
//     } else {
//       volume = 0.5;
//     }
//     await flutterTts?.setVolume(volume);
//     await flutterTts?.setSpeechRate(rate);
//     await flutterTts?.setPitch(pitch);
//     if (message.isNotEmpty) {
//       //!= null) {
//       if (message.isNotEmpty) {
//         var result = await flutterTts?.speak(message);
//         if (result == 1) setState(() => ttsState = TtsState.playing);
//       }
//     }
//   }

//   bool isSpeak = true;
//   final ScrollController _scrollController = ScrollController();
//   bool _needsScroll = false;

//   AutoScrollController controller = AutoScrollController();
//   final scrollDirection = Axis.vertical;
//   List<String> datalist = [];
//   List<String> messagess = [];

//   Widget _getRow(int index, List<String> datalist) {
//     return _wrapScrollTag(
//       index: index,
//       // child: Text(datalist[index],style: TextStyle(color: Colors.lightBlueAccent),)
//       child: Row(
//         children: [
//           Text(
//             "${datalist[index]} ",
//             style: const TextStyle(color: Colors.black),
//           ),
//           Expanded(
//             child: Text(
//               messagess[index],
//               style: const TextStyle(color: Color.fromARGB(255, 31, 181, 251)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _wrapScrollTag({int index = 0, Widget? child}) => AutoScrollTag(
//         key: ValueKey(index),
//         controller: controller,
//         index: index,
//         highlightColor: Colors.black.withOpacity(0.1),
//         child: child,
//       );

//   Future<void> getBottomSheet(BuildContext context) async {
//     _controller = _key.currentState?.showBottomSheet(
//       (_) {
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(
//                   20,
//                 ),
//               ),
//               shape: BoxShape.rectangle,
//               border: Border.all(
//                 width: 5,
//                 color: Colors.grey,
//               ),
//             ),
//             height: 650,
//             width: 500,
//             child: Column(
//               children: <Widget>[
//                 // SizedBox(
//                 //   height: 10,
//                 // ),
//                 Container(
//                   padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: <Widget>[
//                       // Expanded(
//                       //   child: Text(
//                       //     lastWords,
//                       //     style: TextStyle(
//                       //       color: Colors.black,
//                       //     ),
//                       //   ),
//                       // ),
//                       IconButton(
//                         icon: Icon(Icons.close),
//                         onPressed: () {
//                           // Navigator.of(context).pop();
//                           print("LAST::$lastWords");
//                           _controller?.close();
//                           // totalWords = "";
//                           datalist = [];
//                           messagess = [];
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.35,
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black54),
//                     borderRadius: BorderRadius.circular(20),
//                     shape: BoxShape.rectangle,
//                   ),
//                   child: SingleChildScrollView(
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height * 0.62,
//                       width: MediaQuery.of(context).size.width * 0795,
//                       // height:  MediaQuery.of(context).size.height-300,
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Center(
//                             child: datalist.isEmpty
//                                 ? const Text(
//                                     "",
//                                     style: TextStyle(color: Colors.white),
//                                   )
//                                 : SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         0.68,
//                                     child: ListView.builder(
//                                       scrollDirection: scrollDirection,
//                                       controller: controller,
//                                       itemCount: datalist.length,
//                                       itemBuilder:
//                                           (BuildContext context, int index) {
//                                         return _getRow(index, datalist);
//                                       },
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 _hasSpeech
//                     ? Expanded(
//                         child: AnimatedBuilder(
//                           animation: CurvedAnimation(
//                               parent: _animationController,
//                               curve: Curves.fastOutSlowIn),
//                           builder: (context, child) {
//                             return Stack(
//                               alignment: Alignment.center,
//                               children: <Widget>[
//                                 _buildContainer(
//                                     150 * _animationController.value),
//                                 _buildContainer(
//                                     200 * _animationController.value),
//                                 GestureDetector(
//                                   onTap: () {
//                                     // totalWords += lastWords;

//                                     _controller!.setState!(() {
//                                       lastWords = "";
//                                     });

//                                     if (speech.isListening) {
//                                       DateTime currentDate = DateTime.now();
//                                       messagess.add(lastWords);
//                                       datalist.add(
//                                         currentDate
//                                             .toString()
//                                             .substring(10, 19),
//                                       );

//                                       stopListening();
//                                     }
//                                     if (speech.isNotListening) {
//                                       startListening();
//                                     }
//                                   },
//                                   child: Center(
//                                     child: Image.asset(
//                                       'assets/images/mike2.png',
//                                       height: 120,
//                                       width: 200,
//                                     ),
//                                   ),
//                                 ),
//                                 //Text(lastWords)
//                               ],
//                             );
//                           },
//                         ),
//                       )
//                     : Container(
//                         height: 0,
//                         width: 0,
//                       ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildContainer(double radius) {
//     radius = !speechTest || !_isAnimating ? 0 : radius;
//     return Container(
//       width: radius,
//       height: radius,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Color.fromARGB(255, 130, 175, 243)
//             .withOpacity(1 - _animationController.value),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:google_fonts/google_fonts.dart';

enum TtsState { playing, stopped }

class ListenClass extends StatefulWidget {
  const ListenClass({super.key});

  @override
  State<ListenClass> createState() => _ListenClassState();
}

class _ListenClassState extends State<ListenClass>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SpeechToText speech = SpeechToText();
  bool _hasSpeech = false;
  bool speechTest = false;
  bool _isAnimating = false;
  bool isMatchFound = false;
  String lastError = "";
  String lastStatus = "";
  String lastWords = "";
  String totalWords = "";
  PersistentBottomSheetController?
      _controller; // = PersistentBottomSheetController<T>;
  late final AnimationController _animationController;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  dynamic languages;
  FlutterTts? flutterTts;
  TtsState ttsState = TtsState.stopped;
  double volume = 0.5;
  double rate = 0.5;
  double pitch = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
    initSpeechState();

    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 3),
      // reverseDuration: Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose of the AnimationController.
    stopListening();
    // speech.cancel();
    super.dispose();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts?.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts?.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts?.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts?.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
      debugLogging: false,
    );

    if (!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // setState(() {
    lastError = "${error.errorMsg} - ${error.permanent}";
    // });
  }

  void statusListener(String status) {
    if (status == "listening") {
    } else if (status == "notListening") {
      _animationController.reset();
      _isAnimating = false;
    }
  }

  void resultListenerCheck(SpeechRecognitionResult result) {
    // Future.delayed(const Duration(seconds: 5), () {
    if (!speech.isListening) {
      resultListener(result);
    }
    // });
  }

  void nullFunc(String strNull) {
    DateTime currentDate = DateTime.now();
    messagess.add(strNull);
    datalist.add(
      currentDate.toString().substring(10, 19),
    );
  }

  void resultListener(SpeechRecognitionResult result) {
    _animationController.reset();
    _isAnimating = false;

    setState(() {
      //lastWords = "${result.recognizedWords} - ${result.finalResult}";
      lastWords = result.recognizedWords;
      DateTime currentDate = DateTime.now();
      // Navigator.pop(context, lastWords);
      Future.delayed(const Duration(seconds: 3), () {
        // print("Wait for 3000 milliseconds");
        Navigator.pop(context, lastWords);
      });

      // messagess.add(lastWords);
      // datalist.add(
      //   currentDate.toString().substring(10, 19),
      // );
      // if (speech.isListening) nullFunc(lastWords);
    });
    if (speech.isListening) {
      return;
    } else {
      lastWords.isNotEmpty && //!= null &&
          lastWords.isNotEmpty &&
          !speech.isListening &&
          !isMatchFound;

      ///lastWords="Sorry No Match Founds";
      isMatchFound = true;
      // _speak("sorry we can not found any match! please try again");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20,
                    ),
                  ),
                  shape: BoxShape.rectangle,
                  // border: Border.all(
                  //   width: 5,
                  //   color: Colors.grey,
                  // ),
                ),
                height: 350,
                width: 500,
                child: Column(
                  children: <Widget>[
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          // IconButton(
                          //   icon: Icon(Icons.close),
                          //   onPressed: () {
                          //     // Navigator.of(context).pop();
                          //     print("LAST::$lastWords");
                          //     // _controller?.close();
                          //     // totalWords = "";
                          //     datalist = [];
                          //     messagess = [];
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: const BoxDecoration(
                          // border: Border.all(color: Colors.black54),
                          // borderRadius: BorderRadius.circular(20),
                          // shape: BoxShape.rectangle,
                          ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.32,
                        width: MediaQuery.of(context).size.width * 0795,
                        // height:  MediaQuery.of(context).size.height-300,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  // color: Colors.grey,
                                  // gradient: const LinearGradient(
                                  //   begin: Alignment.topCenter,
                                  //   end: Alignment.bottomCenter,
                                  // colors: [
                                  //   Color.fromARGB(255, 231, 230, 230),
                                  //   Color.fromARGB(255, 243, 241, 241),
                                  //   Colors.white,
                                  //   Color.fromARGB(255, 222, 221, 221),
                                  // ],
                                  // ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Center(
                                  child: lastWords.isNotEmpty
                                      ? Text(
                                          lastWords,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.065,
                                          ),
                                        )
                                      : Text(
                                          "Tap on mic to listen...",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.065,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _hasSpeech
                        ? Expanded(
                            child: AnimatedBuilder(
                              animation: CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.fastOutSlowIn),
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    _buildContainer(
                                        150 * _animationController.value),
                                    _buildContainer(
                                        200 * _animationController.value),
                                    GestureDetector(
                                      onTap: () {
                                        // totalWords += lastWords;

                                        setState(() {
                                          lastWords = "";
                                        });

                                        if (speech.isListening) {
                                          // DateTime currentDate = DateTime.now();
                                          // messagess.add(lastWords);
                                          // datalist.add(
                                          //   currentDate
                                          //       .toString()
                                          //       .substring(10, 19),
                                          // );

                                          stopListening();
                                          // Navigator.pop(context);
                                        }
                                        if (speech.isNotListening) {
                                          startListening();
                                        }
                                      },
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/mike2.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                        ),
                                      ),
                                    ),
                                    //Text(lastWords)
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(
                            // height: 0,
                            // width: 0,
                            child: const Center(
                              child: Text('Please Enable Permission'),
                            ),
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

  void stopListening() {
    speech.stop();
  }

  void startListening() {
    _animationController.addListener(() {
      // setState(() {});
    });
    //_animationController.forward();
    _animationController.repeat(period: const Duration(seconds: 2));
    _isAnimating = true;
    lastWords = "";
    lastError = "";
    isMatchFound = false;
    int listenForSeconds = 30;
    if (Platform.isIOS) {
      listenForSeconds = 25;
    }
    Duration listenFor = Duration(seconds: listenForSeconds);

    speech.listen(onResult: resultListenerCheck, listenFor: listenFor);
    // setState(() {
    speechTest = true;
    // });
  }

  Future _speak(String message) async {
    if (Platform.isIOS) {
      volume = 0.7;
    } else {
      volume = 0.5;
    }
    await flutterTts?.setVolume(volume);
    await flutterTts?.setSpeechRate(rate);
    await flutterTts?.setPitch(pitch);
    if (message.isNotEmpty) {
      //!= null) {
      if (message.isNotEmpty) {
        var result = await flutterTts?.speak(message);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  bool isSpeak = true;
  final ScrollController _scrollController = ScrollController();
  final bool _needsScroll = false;

  AutoScrollController controller = AutoScrollController();
  final scrollDirection = Axis.vertical;
  List<String> datalist = [];
  List<String> messagess = [];

  Future<void> getBottomSheet(BuildContext context) async {
    _controller = _key.currentState?.showBottomSheet(
      (_) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(
                  20,
                ),
              ),
              shape: BoxShape.rectangle,
              border: Border.all(
                width: 5,
                color: Colors.grey,
              ),
            ),
            height: 650,
            width: 500,
            child: Column(
              children: <Widget>[
                // SizedBox(
                //   height: 10,
                // ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // Navigator.of(context).pop();
                          print("LAST::$lastWords");
                          _controller?.close();
                          // totalWords = "";
                          datalist = [];
                          messagess = [];
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(20),
                    shape: BoxShape.rectangle,
                  ),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.62,
                      width: MediaQuery.of(context).size.width * 0795,
                      // height:  MediaQuery.of(context).size.height-300,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: lastWords.isEmpty
                                ? const Text(
                                    "",
                                    style: TextStyle(color: Colors.white),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.68,
                                    child: Text(lastWords),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _hasSpeech
                    ? Expanded(
                        child: AnimatedBuilder(
                          animation: CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.fastOutSlowIn),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                _buildContainer(
                                    150 * _animationController.value),
                                _buildContainer(
                                    200 * _animationController.value),
                                GestureDetector(
                                  onTap: () {
                                    // totalWords += lastWords;

                                    _controller!.setState!(() {
                                      lastWords = "";
                                    });

                                    if (speech.isListening) {
                                      DateTime currentDate = DateTime.now();
                                      messagess.add(lastWords);
                                      datalist.add(
                                        currentDate
                                            .toString()
                                            .substring(10, 19),
                                      );

                                      stopListening();
                                    }
                                    if (speech.isNotListening) {
                                      startListening();
                                    }
                                  },
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/mike2.png',
                                      height: 120,
                                      width: 200,
                                    ),
                                  ),
                                ),
                                //Text(lastWords)
                              ],
                            );
                          },
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    radius = !speechTest || !_isAnimating ? 0 : radius;
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 130, 175, 243)
            .withOpacity(1 - _animationController.value),
      ),
    );
  }
}
