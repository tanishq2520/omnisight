import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  @override
  void initState() {
    super.initState();

    // Back camera
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      _speakStartup();
    });
  }

  Future<void> _speakStartup() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak('OmniSight Active');
  }

  @override
  void dispose() {
    _tts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.previewSize!.height,
                  height: _controller.value.previewSize!.width,
                  child: CameraPreview(_controller),
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
