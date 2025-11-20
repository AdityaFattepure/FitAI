import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../models/pose_data.dart';
import 'tts_service.dart';

enum SquatState { standing, goingDown, down, goingUp }

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );
  
  final TTSService _tts = TTSService();
  
  // Rep counting state
  SquatState _currentState = SquatState.standing;
  int _repCount = 0;
  DateTime _lastRepTime = DateTime.now();
  DateTime _lastFeedbackTime = DateTime.now();
  
  int get repCount => _repCount;
  
  Future<void> initialize() async {
    await _tts.initialize();
    _repCount = 0;
    _currentState = SquatState.standing;
  }
  
  Future<PoseData?> detectPose(CameraImage image, CameraDescription camera) async {
    try {
      final InputImage inputImage = _convertCameraImage(image, camera);
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isEmpty) return null;
      
      final pose = poses.first;
      final poseData = PoseData(pose);
      
      // Only process if confidence is good
      if (poseData.getConfidence() < 0.7) {
        return poseData;
      }
      
      // Update rep counting state machine
      _updateRepCount(poseData);
      
      // Provide posture feedback (less frequently)
      _providePostureFeedback(poseData);
      
      return poseData;
      
    } catch (e) {
      // Error detecting pose - silent fail in production
      return null;
    }
  }
  
  void _updateRepCount(PoseData poseData) {
    final now = DateTime.now();
    final timeSinceLastRep = now.difference(_lastRepTime).inMilliseconds;
    
    // Prevent counting too fast (minimum 1 second between reps)
    if (timeSinceLastRep < 1000) return;
    
    switch (_currentState) {
      case SquatState.standing:
        if (poseData.isSquatDown()) {
          _currentState = SquatState.down;
        }
        break;
        
      case SquatState.down:
        if (poseData.isSquatUp()) {
          // Complete rep!
          _repCount++;
          _currentState = SquatState.standing;
          _lastRepTime = now;
          _tts.announceRep(_repCount);
        }
        break;
        
      default:
        if (poseData.isSquatUp()) {
          _currentState = SquatState.standing;
        } else if (poseData.isSquatDown()) {
          _currentState = SquatState.down;
        }
    }
  }
  
  void _providePostureFeedback(PoseData poseData) {
  final now = DateTime.now();
  final timeSinceFeedback = now.difference(_lastFeedbackTime).inSeconds;
  
  // Give feedback every 8 seconds and only when actually wrong
  if (timeSinceFeedback < 8) return;
  
  String feedback = poseData.getPostureFeedback();
  
  // Only speak if there's an actual issue (not "Good form")
  if (feedback != "Good form") {
    _tts.announcePosture(feedback);
    _lastFeedbackTime = now;
  }
}
  
  InputImage _convertCameraImage(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    
    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) 
        ?? InputImageRotation.rotation0deg;
    
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) 
        ?? InputImageFormat.nv21;
    
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
  
  void resetCount() {
    _repCount = 0;
    _currentState = SquatState.standing;
  }
  
  void dispose() {
    _poseDetector.close();
  }
}