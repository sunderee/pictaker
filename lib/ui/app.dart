import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pictaker/ui/screens/home.screen.dart';

class App extends StatelessWidget {
  final List<CameraDescription> availableCameras;

  const App({
    Key? key,
    required this.availableCameras,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF216869),
          background: Colors.white,
        ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF75B8C8),
          background: const Color(0xFF1F2421),
          surface: const Color(0xFF1F2421),
        ),
      ),
      home: HomeScreen(
        availableCameras: availableCameras,
      ),
    );
  }
}
