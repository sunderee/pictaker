import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(App(availableCameras: cameras));
}

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

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> availableCameras;

  const HomeScreen({
    Key? key,
    required this.availableCameras,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _cameraControllerInitializer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.availableCameras.first,
      ResolutionPreset.medium,
    );
    _cameraControllerInitializer = _controller?.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !(_controller?.value.isInitialized ?? false)) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _onNewCameraSelected(_controller!.description);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () async => await _pickPhotoFromGallery(),
          icon: const Icon(Icons.photo_library),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final isBack = _controller?.description.lensDirection ==
                  CameraLensDirection.back;
              final newCameraDescription = widget.availableCameras.firstWhere(
                  (CameraDescription element) => isBack
                      ? element.lensDirection == CameraLensDirection.front
                      : element.lensDirection == CameraLensDirection.back);
              _controller = CameraController(
                newCameraDescription,
                ResolutionPreset.medium,
              );
              await _controller?.initialize();
              if (mounted) {
                setState(() {});
              }
            },
            icon: Icon(
              _controller?.description.lensDirection == CameraLensDirection.back
                  ? Icons.camera_rear
                  : Icons.camera_front,
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _cameraControllerInitializer,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;

            final camera = _controller?.value;
            double scale =
                size.aspectRatio * (camera?.aspectRatio ?? size.aspectRatio);
            if (scale < 1) {
              scale = 1 / scale;
            }
            return ((_controller?.value.isInitialized ?? false) &&
                    _controller != null)
                ? Transform.scale(
                    scale: scale,
                    child: Center(
                      child: Stack(
                        children: [
                          CameraPreview(_controller!),
                          Positioned.fill(
                            bottom: -MediaQuery.of(context).size.height / 2,
                            child: ShutterButtonWidget(
                              onPressed: () async =>
                                  await _takePhotoWithCamera(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller?.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    _controller?.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (_controller?.value.hasError ?? true) {
        context.showCustomSnackBar('Failed to open device camera');
      }
    });

    try {
      await _controller?.initialize();
    } on CameraException catch (e) {
      context.showCustomSnackBar(
        e.description ?? 'Failed to initialize device camera',
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePhotoWithCamera() async {
    final file = await _controller?.takePicture();
    context.showCustomSnackBar(
      file?.name ?? 'Did not take a photo at all :(',
    );
  }

  Future<void> _pickPhotoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    context.showCustomSnackBar(
      result?.files.first.name ?? 'You did not pick any photo :(',
    );
  }
}

class ShutterButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;

  const ShutterButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<ShutterButtonWidget> createState() => _ShutterButtonWidgetState();
}

class _ShutterButtonWidgetState extends State<ShutterButtonWidget> {
  Size _outerSize = const Size(72.0, 72.0);
  Size _innerSize = const Size(56.0, 56.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _outerSize.width,
      height: _outerSize.height,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: () {
          widget.onPressed();

          // Shrink sizes
          setState(() {
            _outerSize = Size(
              _outerSize.width * 0.95,
              _outerSize.height * 0.95,
            );
            _innerSize = Size(
              _innerSize.width * 0.95,
              _innerSize.height * 0.95,
            );
          });

          Future<void>.delayed(const Duration(milliseconds: 150)).then((_) {
            // Return sizes to their original values
            setState(() {
              _outerSize = Size(
                _outerSize.width * (1 / 0.95),
                _outerSize.height * (1 / 0.95),
              );
              _innerSize = Size(
                _innerSize.width * (1 / 0.95),
                _innerSize.height * (1 / 0.95),
              );
            });
          });
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: _outerSize.width,
                height: _outerSize.height,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 4.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: _innerSize.width,
                height: _innerSize.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

extension BuildContextExt on BuildContext {
  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
