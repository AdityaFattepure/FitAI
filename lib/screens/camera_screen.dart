import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/pose_detector_service.dart';
import '../painters/pose_painter.dart';

class CameraScreen extends StatefulWidget {
  final String workoutName;
  
  const CameraScreen({Key? key, required this.workoutName}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  final PoseDetectorService _poseService = PoseDetectorService();
  
  bool _isDetecting = false;
  bool _isInitialized = false;
  bool _isProcessing = false;
  
  String _feedbackMessage = "Position yourself in frame";
  int _repCount = 0;
  Pose? _currentPose;
  String _debugAngles = "";
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _feedbackMessage = "Camera permission denied";
      });
      return;
    }
    
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _feedbackMessage = "No camera found";
        });
        return;
      }
      
      // Use front camera for better user experience
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      
      await _cameraController!.initialize();
      await _poseService.initialize();
      
      // Start image stream
      _cameraController!.startImageStream(_processCameraImage);
      
      setState(() {
        _isInitialized = true;
        _feedbackMessage = "Ready! Start your squats";
      });
      
    } catch (e) {
      setState(() {
        _feedbackMessage = "Error initializing camera: $e";
      });
    }
  }
  
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || !_isDetecting) return;
    
    _isProcessing = true;
    
    try {
      final poseData = await _poseService.detectPose(
        image,
        _cameraController!.description,
      );
      
      if (poseData != null && mounted) {
        setState(() {
          _repCount = _poseService.repCount;
          _feedbackMessage = poseData.getPostureFeedback();
          _currentPose = poseData.pose;
          _debugAngles = "L Knee: ${poseData.getLeftKneeAngle().toInt()}° | "
                        "R Knee: ${poseData.getRightKneeAngle().toInt()}°";
        });
      }
    } catch (e) {
      // Silent error handling
    } finally {
      _isProcessing = false;
    }
  }
  
  void _toggleDetection() {
    setState(() {
      _isDetecting = !_isDetecting;
      if (_isDetecting) {
        _feedbackMessage = "Detecting... Start exercising!";
      } else {
        _feedbackMessage = "Paused";
      }
    });
  }
  
  void _resetCount() {
    _poseService.resetCount();
    setState(() {
      _repCount = 0;
      _feedbackMessage = "Counter reset. Ready!";
    });
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    _poseService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitialized && _cameraController != null
            ? Stack(
                children: [
                  // Camera Preview
                  Center(
                    child: CameraPreview(_cameraController!),
                  ),
                  
                  // Skeleton Overlay
                  if (_isDetecting && _currentPose != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: PosePainter(
                          pose: _currentPose,
                          imageSize: Size(
                            _cameraController!.value.previewSize!.height,
                            _cameraController!.value.previewSize!.width,
                          ),
                          widgetSize: MediaQuery.of(context).size,
                        ),
                      ),
                    ),
                  
                  // Top Bar with feedback
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FitAI Squat Trainer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _feedbackMessage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Rep Counter - Center
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_repCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'REPS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Controls
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Reset Button
                          _buildControlButton(
                            icon: Icons.refresh,
                            label: 'Reset',
                            onPressed: _resetCount,
                            color: Colors.orange,
                          ),
                          
                          // Start/Stop Button
                          _buildControlButton(
                            icon: _isDetecting ? Icons.pause : Icons.play_arrow,
                            label: _isDetecting ? 'Pause' : 'Start',
                            onPressed: _toggleDetection,
                            color: _isDetecting ? Colors.red : Colors.green,
                            isLarge: true,
                          ),
                          
                          // Info Button
                          _buildControlButton(
                            icon: Icons.info_outline,
                            label: 'Help',
                            onPressed: _showHelpDialog,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _feedbackMessage,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: CircleBorder(),
            padding: EdgeInsets.all(isLarge ? 24 : 16),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isLarge ? 40 : 28,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('How to Use'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Position yourself fully in frame\n\n'
                '2. Press START button\n\n'
                '3. Perform squats:\n'
                '   • Stand straight\n'
                '   • Lower down (bend knees)\n'
                '   • Return to standing\n\n'
                '4. Listen to voice feedback\n\n'
                '5. Watch your rep count increase!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }
}