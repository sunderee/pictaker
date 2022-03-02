import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pictaker/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  print('CAMERAS: ${cameras.map((e) => e.toString())}');

  runApp(App(availableCameras: cameras));
}
