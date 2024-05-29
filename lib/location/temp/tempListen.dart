import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

typedef SpeechTextCallback = void Function(String speechText);

class ListenTemp extends StatefulWidget {
  // final SpeechTextCallback onSpeechText;
  const ListenTemp({
    Key? key,
    // required this.onSpeechText,
  }) : super(key: key);

  @override
  ListenTempState createState() => ListenTempState();
}

class ListenTempState extends State<ListenTemp> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechAvailable = false;
  String _lastWords = '';
  String _currentWords = '';
  final String _selectedLocaleId = 'en_EN';

  printLocales() async {
    var locales = await _speechToText.locales();
    for (var local in locales) {
      debugPrint(local.name);
      debugPrint(local.localeId);
    }
  }

  @override
  void initState() {
    super.initState();
    // final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    _mounted = true;
    _initSpeech();
  }

  // void _initSpeech(SpeechProvider speechProvider) async {
  //   _speechAvailable = await _speechToText.initialize(
  //     onError: errorListener,
  //     onStatus: statusListener,
  //   );

  //   if (_speechAvailable) {
  //     speechProvider.speechEnabled = true;
  //   }

  //   setState(() {});
  // }

  void errorListener(SpeechRecognitionError error) {
    debugPrint(error.errorMsg.toString());
  }

  void statusListener(String status) async {
    debugPrint("status $status");
    if (status == "done" && _speechEnabled) {
      setState(() {
        if (_currentWords != " " && _currentWords != "") {
          _lastWords += " $_currentWords";
          _currentWords = "";
          _speechEnabled = false;
        }
      });
      await _startListening();
    }
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    _speechAvailable = await _speechToText.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );

    if (_speechAvailable) {
      speechProvider.speechEnabled = true;
    }

    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future _startListening() async {
    debugPrint("=================================================");
    await _stopListening();
    await Future.delayed(const Duration(milliseconds: 50));
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLocaleId,
        cancelOnError: false,
        partialResults: true,
        listenMode: ListenMode.dictation);
    setState(() {
      _speechEnabled = true;
    });
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    speechProvider.speechEnabled = true;
  }

  @override
  void dispose() {
    _stopListening();
    _lastWords = "";
    _speechEnabled = false;
    _speechAvailable = false;
    _mounted = false;
    super.dispose();
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  // Future _stopListening() async {
  //   setState(() {
  //     _speechEnabled = false;
  //   });
  //   final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
  //   speechProvider.speechEnabled = false;
  //   await _speechToText.stop();
  // }
  bool _mounted = false;
  Future<void> _stopListening() async {
    if (!_mounted) return;

    try {
      Fluttertoast.showToast(msg: "STOP");
      await _speechToText.stop();
    } catch (e) {
      // Handle errors if needed
      Fluttertoast.showToast(msg: "ERROR");
      print("Error stopping speech: $e");
    }
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _currentWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('TEMP Speech Demo'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _lastWords.isNotEmpty
                      ? '$_lastWords $_currentWords'
                      : _speechAvailable
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.1),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const ui.Color.fromARGB(255, 68, 138, 196),
                  minimumSize: Size(
                    MediaQuery.of(context).size.width * 0.15,
                    MediaQuery.of(context).size.width * 0.15,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                onPressed: _speechToText.isNotListening
                    ? _startListening
                    : _stopListening,
                child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.08,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width * 0.1),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const ui.Color.fromARGB(255, 68, 138, 196),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  // widget.onSpeechText(
                  //   _lastWords,
                  // );
                  _lastWords = "";
                  _speechEnabled = false;
                  _speechAvailable = false;
                  _currentWords = '';
                  _speechToText.cancel();

                  // final SpeechToText _speechToText = SpeechToText();
                  // bool _speechEnabled = false;
                  // bool _speechAvailable = false;
                  // String _lastWords = '';
                  // String _currentWords = '';
                  Navigator.pop(context, _lastWords);
                },
                child: Text(
                  'Done',
                  style: GoogleFonts.cabin(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.045),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed:
      //       _speechToText.isNotListening ? _startListening : _stopListening,
      //   tooltip: 'Listen',
      //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      // ),
    );
  }
}

class SpeechProvider with ChangeNotifier {
  bool _speechEnabled = false;

  bool get speechEnabled => _speechEnabled;

  set speechEnabled(bool value) {
    _speechEnabled = value;
    notifyListeners();
  }
}
