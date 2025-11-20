import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class PoseData {
  final Pose pose;
  
  PoseData(this.pose);
  
  // Calculate angle between three points
  double calculateAngle(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) {
    if (a == null || b == null || c == null) return 0.0;
    
    // Vector from b to a
    double radians = atan2(c.y - b.y, c.x - b.x) - 
                     atan2(a.y - b.y, a.x - b.x);
    
    double angle = radians * 180.0 / pi;
    
    // Normalize angle to 0-180 range
    if (angle < 0) {
      angle += 360;
    }
    if (angle > 180) {
      angle = 360 - angle;
    }
    
    return angle.abs();
  }
  
  // Get specific landmark
  PoseLandmark? getLandmark(PoseLandmarkType type) {
    return pose.landmarks[type];
  }
  
  // Calculate knee angle for squat detection
  double getLeftKneeAngle() {
    return calculateAngle(
      getLandmark(PoseLandmarkType.leftHip),
      getLandmark(PoseLandmarkType.leftKnee),
      getLandmark(PoseLandmarkType.leftAnkle),
    );
  }
  
  double getRightKneeAngle() {
    return calculateAngle(
      getLandmark(PoseLandmarkType.rightHip),
      getLandmark(PoseLandmarkType.rightKnee),
      getLandmark(PoseLandmarkType.rightAnkle),
    );
  }
  
  // Calculate hip angle for squat depth
  double getLeftHipAngle() {
    return calculateAngle(
      getLandmark(PoseLandmarkType.leftShoulder),
      getLandmark(PoseLandmarkType.leftHip),
      getLandmark(PoseLandmarkType.leftKnee),
    );
  }
  
  double getRightHipAngle() {
    return calculateAngle(
      getLandmark(PoseLandmarkType.rightShoulder),
      getLandmark(PoseLandmarkType.rightHip),
      getLandmark(PoseLandmarkType.rightKnee),
    );
  }
  
  // Check if user is in correct squat position
  bool isSquatDown() {
    double leftKnee = getLeftKneeAngle();
    double rightKnee = getRightKneeAngle();
    
    // Squat down position: knees bent (angle < 120 degrees)
    return (leftKnee < 120 && rightKnee < 120);
  }
  
  bool isSquatUp() {
    double leftKnee = getLeftKneeAngle();
    double rightKnee = getRightKneeAngle();
    
    // Standing position: knees straight (angle > 160 degrees)
    return (leftKnee > 160 && rightKnee > 160);
  }
  
  // Check posture correctness - Only give feedback when actually wrong
  String getPostureFeedback() {
    double leftKnee = getLeftKneeAngle();
    double rightKnee = getRightKneeAngle();
    double leftHip = getLeftHipAngle();
    double rightHip = getRightHipAngle();
    
    // Only check alignment during squat (when bent)
    if (leftKnee < 140 && rightKnee < 140) {
      // Check if knees are significantly misaligned (more strict threshold)
      if ((leftKnee - rightKnee).abs() > 25) {
        if (leftKnee < rightKnee) {
          return "Left knee too bent";
        } else {
          return "Right knee too bent";
        }
      }
      
      // Check back angle only when clearly squatting down
      if (isSquatDown()) {
        double avgHip = (leftHip + rightHip) / 2;
        if (avgHip < 60) {
          return "Keep back straighter";
        }
        if (avgHip > 130) {
          return "Lean forward more";
        }
      }
    }
    
    return "Good form";
  }
  
  // Calculate visibility/confidence score
  double getConfidence() {
    int visibleLandmarks = 0;
    int totalLandmarks = pose.landmarks.length;
    
    pose.landmarks.forEach((type, landmark) {
      if (landmark.likelihood > 0.5) {
        visibleLandmarks++;
      }
    });
    
    return visibleLandmarks / totalLandmarks;
  }
}