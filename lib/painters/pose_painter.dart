import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose? pose;
  final Size imageSize;
  final Size widgetSize;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pose == null) return;

    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 8.0
      ..style = PaintingStyle.fill;

    // Draw skeleton connections
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.leftElbow],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftElbow],
      pose!.landmarks[PoseLandmarkType.leftWrist],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      pose!.landmarks[PoseLandmarkType.rightElbow],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.rightElbow],
      pose!.landmarks[PoseLandmarkType.rightWrist],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftShoulder],
      pose!.landmarks[PoseLandmarkType.leftHip],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.rightShoulder],
      pose!.landmarks[PoseLandmarkType.rightHip],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftHip],
      pose!.landmarks[PoseLandmarkType.rightHip],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftHip],
      pose!.landmarks[PoseLandmarkType.leftKnee],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.leftKnee],
      pose!.landmarks[PoseLandmarkType.leftAnkle],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.rightHip],
      pose!.landmarks[PoseLandmarkType.rightKnee],
      paint,
    );
    
    _drawLine(
      canvas,
      pose!.landmarks[PoseLandmarkType.rightKnee],
      pose!.landmarks[PoseLandmarkType.rightAnkle],
      paint,
    );

    // Draw key points (joints)
    pose!.landmarks.forEach((type, landmark) {
      if (landmark.likelihood > 0.5) {
        final point = _translatePoint(landmark);
        canvas.drawCircle(point, 6, pointPaint);
      }
    });
  }

  void _drawLine(
    Canvas canvas,
    PoseLandmark? start,
    PoseLandmark? end,
    Paint paint,
  ) {
    if (start == null || end == null) return;
    if (start.likelihood < 0.5 || end.likelihood < 0.5) return;

    final startPoint = _translatePoint(start);
    final endPoint = _translatePoint(end);
    canvas.drawLine(startPoint, endPoint, paint);
  }

  Offset _translatePoint(PoseLandmark landmark) {
    // Convert from image coordinates to widget coordinates
    final double scaleX = widgetSize.width / imageSize.width;
    final double scaleY = widgetSize.height / imageSize.height;

    return Offset(
      landmark.x * scaleX,
      landmark.y * scaleY,
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}