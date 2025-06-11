
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SpeechModule {
  /// Provides Speech to Text serv
  SpeechToText provideSpeechToText() {
    return SpeechToText();
  }

  FlutterTts provideFlutterTts() {
    return FlutterTts();
  }

  Future<List<CameraDescription>> provideCameras() async {
    try {
      final cameras = await availableCameras();
      return cameras;
    } catch (e) {
      // Return empty list if camera initialization fails
      return <CameraDescription>[];
    }
  }

  Future<SharedPreferences> provideSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }
}
