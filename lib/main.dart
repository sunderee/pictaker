import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pictaker/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(App(availableCameras: cameras));
}
