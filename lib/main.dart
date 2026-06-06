import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(const OmniSightApp());
}

class OmniSightApp extends StatelessWidget {
  const OmniSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniSight',
      theme: ThemeData.dark(),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FlutterTts _tts = FlutterTts();

  // null = still checking, true = granted, false = denied
  bool? _permissionsGranted;

  // WebSocket
  WebSocketChannel? _channel;

  // Demo UX: flag set when AI response arrives to cancel pending announcements.
  bool _responseReceived = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInit();
    _connectWebSocket();
  }

  // ── WebSocket ──────────────────────────────────────────────────────────────

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://10.175.128.27:8000/ws'),
      );
      debugPrint('WebSocket Connected');

      _channel!.stream.listen(
        (message) async {
          debugPrint('Received: $message');
          _responseReceived = true;
          await _tts.stop();
          await _tts.setLanguage('en-US');
          await _tts.setSpeechRate(0.45);
          await _tts.setVolume(1.0);
          await _tts.setPitch(1.0);
          await _tts.speak(message.toString());
        },
        onError: (error) {
          debugPrint('WebSocket Error');
        },
        onDone: () {
          debugPrint('WebSocket Disconnected');
        },
      );
    } catch (e) {
      debugPrint('WebSocket Error');
    }
  }

  // ── Camera ─────────────────────────────────────────────────────────────────

  Future<void> _requestPermissionsAndInit() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    final granted =
        cameraStatus == PermissionStatus.granted &&
        micStatus == PermissionStatus.granted;

    if (!mounted) return;
    setState(() => _permissionsGranted = granted);

    if (granted) {
      _initCamera();
    }
  }

  void _initCamera() {
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      _speakStartup();
    });

    // Trigger a rebuild so FutureBuilder picks up the new future.
    if (mounted) setState(() {});
  }

  // ── TTS ────────────────────────────────────────────────────────────────────

  Future<void> _speakStartup() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak('OmniSight Active');
  }

  // Single tap — scene description with staged voice feedback
  Future<void> _speakScanning() async {
    _responseReceived = false;
    // Backend capture runs in parallel — fires immediately, independent of speech.
    _captureAndSend('SCENE');

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true); // each speak() blocks until audio done

    // Stage 1 — immediate
    await _tts.speak('Scanning surroundings.');

    // Delay after 'Scanning surroundings' finishes: wait 2 seconds
    if (!_responseReceived) {
      await Future.delayed(const Duration(seconds: 2));
    }

    // Stage 2 — after stage 1 finishes speaking
    if (!_responseReceived) {
      await _tts.speak('Capturing details.');
    }

    // Delay after 'Capturing details' finishes: wait 3 seconds
    if (!_responseReceived) {
      await Future.delayed(const Duration(seconds: 3));
    }

    // Stage 3 — after stage 2 finishes speaking
    if (!_responseReceived) {
      await _tts.speak('Analyzing the environment.');
    }

    // Delay after 'Analyzing the environment' finishes: wait 3 seconds
    if (!_responseReceived) {
      await Future.delayed(const Duration(seconds: 3));
    }

    // Stage 4 — after stage 3 finishes speaking
    if (!_responseReceived) {
      await _tts.speak('Almost done.');
    }
  }

  // Double tap — OCR / text reading
  Future<void> _speakReading() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak('Reading text');
    await _captureAndSend('OCR');
  }

  // Shared: capture image and send with mode prefix
  Future<void> _captureAndSend(String mode) async {
    try {
      final XFile imageFile = await _controller.takePicture();
      debugPrint('Captured image');

      final Uint8List imageBytes = await File(imageFile.path).readAsBytes();
      debugPrint('Image size: ${imageBytes.length}');

      final String base64Image = base64Encode(imageBytes);
      final String payload = 'MODE:$mode|$base64Image';
      debugPrint('Sending image...');

      _channel?.sink.add(payload);
      debugPrint('Image sent successfully');
    } catch (e) {
      debugPrint('Image capture error: $e');
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _tts.stop();
    _channel?.sink.close();
    if (_permissionsGranted == true) {
      _controller.dispose();
    }
    super.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Still checking permissions.
    if (_permissionsGranted == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Permissions denied.
    if (_permissionsGranted == false) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Camera and microphone permissions are required.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    // Permissions granted — show camera preview.
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: _speakScanning,
              onDoubleTap: _speakReading,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.previewSize!.height,
                    height: _controller.value.previewSize!.width,
                    child: CameraPreview(_controller),
                  ),
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
