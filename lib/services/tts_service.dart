import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();
  
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  DateTime _lastSpokenTime = DateTime.now();
  String _lastSpokenText = "";
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _isInitialized = true;
  }
  
  Future<void> speak(String text, {bool force = false}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Prevent speaking the same thing too frequently
    final now = DateTime.now();
    final timeDiff = now.difference(_lastSpokenTime).inSeconds;
    
    if (!force && _lastSpokenText == text && timeDiff < 3) {
      return; // Don't repeat the same message within 3 seconds
    }
    
    _lastSpokenTime = now;
    _lastSpokenText = text;
    
    await _flutterTts.speak(text);
  }
  
  Future<void> announceRep(int repCount) async {
    await speak("$repCount", force: true);
  }
  
  Future<void> announcePosture(String feedback) async {
    await speak(feedback);
  }
  
  Future<void> stop() async {
    await _flutterTts.stop();
  }
  
  Future<void> announceStart() async {
    await speak("Get ready! Starting workout", force: true);
  }
  
  Future<void> announceComplete(int totalReps) async {
    await speak("Workout complete! You did $totalReps repetitions", force: true);
  }
}