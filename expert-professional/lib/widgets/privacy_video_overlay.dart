import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:expert_professional/theme/app_theme.dart';

class PrivacyVideoOverlay extends StatefulWidget {
  final String privacyMode; // 'normal', 'blur', 'avatar', 'audio'
  final double blurStrength;
  final String avatarAsset;
  final Function(ui.Image, Uint8List) onFramePushed;

  const PrivacyVideoOverlay({
    super.key,
    required this.privacyMode,
    required this.blurStrength,
    required this.avatarAsset,
    required this.onFramePushed,
  });

  @override
  State<PrivacyVideoOverlay> createState() => _PrivacyVideoOverlayState();
}

class _PrivacyVideoOverlayState extends State<PrivacyVideoOverlay> {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions(enableTracking: true));
  bool _isDetecting = false;
  List<Face> _faces = [];
  final GlobalKey _globalKey = GlobalKey();
  Timer? _frameTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();

    _cameraController!.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();

        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
        final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(frontCamera.sensorOrientation) ?? InputImageRotation.rotation0deg;
        final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

        final metadata = InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
        
        final faces = await _faceDetector.processImage(inputImage);
        
        if (mounted) {
          setState(() {
            _faces = faces;
          });
        }
      } catch (e) {
        debugPrint('Face detection error: $e');
      } finally {
        _isDetecting = false;
      }
    });

    // Capture frames from RepaintBoundary at ~15 FPS
    _frameTimer = Timer.periodic(const Duration(milliseconds: 66), (timer) {
      _captureAndPushFrame();
    });

    if (mounted) setState(() {});
  }

  Future<void> _captureAndPushFrame() async {
    if (widget.privacyMode == 'audio' || widget.privacyMode == 'normal') return;
    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData != null) {
        widget.onFramePushed(image, byteData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Error capturing frame: $e');
    }
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (widget.privacyMode == 'audio') {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text('Audio Only Mode', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (widget.privacyMode == 'normal') {
      return CameraPreview(_cameraController!);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController!),
                  ..._faces.map((face) {
                    final imageSize = Size(
                      _cameraController!.value.previewSize!.height,
                      _cameraController!.value.previewSize!.width,
                    );

                final scaleX = size.width / imageSize.width;
                final scaleY = size.height / imageSize.height;

                final boundingBox = face.boundingBox;
                
                final left = size.width - (boundingBox.right * scaleX);
                final top = boundingBox.top * scaleY;
                final width = boundingBox.width * scaleX;
                final height = boundingBox.height * scaleY;

                final padX = width * 0.2;
                final padY = height * 0.2;

                if (widget.privacyMode == 'blur') {
                  return Positioned(
                    left: left - padX,
                    top: top - padY,
                    width: width + (padX * 2),
                    height: height + (padY * 2),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: widget.blurStrength,
                          sigmaY: widget.blurStrength,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  );
                } else if (widget.privacyMode == 'avatar') {
                  return Positioned(
                    left: left - padX,
                    top: top - padY,
                    width: width + (padX * 2),
                    height: height + (padY * 2),
                    child: Image.asset(
                      widget.avatarAsset,
                      fit: BoxFit.contain,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ],
    );
  },
);
  }
}
