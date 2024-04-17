import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:particular/particular.dart';
import 'package:particular/particular_controller.dart';
import 'package:image/image.dart' as image;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _particleController = ParticularController();

  @override
  void initState() {
    super.initState();
    _loadParticleAssets();
  }

  Future<void> _loadParticleAssets() async {
    // load json config
    var json = await rootBundle.loadString("assets/fire.json");
    var configsMap = jsonDecode(json);

    // Load particle texture
    final ByteData assetImageByteData =
        await rootBundle.load("assets/${configsMap["textureFileName"]}");
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage!,
        height: baseSizeImage.width, width: baseSizeImage.height);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    _particleController.initialize(configsMap, frameInfo.image);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            GestureDetector(
              onPanUpdate: (details) {
                _particleController.update(
                    emitterX: details.localPosition.dx,
                    emitterY: details.localPosition.dy);
              },
              onTapDown: (details) {
                _particleController.update(
                    emitterX: details.localPosition.dx,
                    emitterY: details.localPosition.dy);
              },
              child: Particular(
                width: 600,
                height: 600,
                color: Colors.black,
                controller: _particleController,
              ),
            ),
            TextButton(
                onPressed: () {
                  _particleController.update(
                      maxParticles:
                          _particleController.maxParticles > 500 ? 300 : 13000);
                },
                child: const Text("Update"))
          ],
        ),
      ),
    );
  }
}
