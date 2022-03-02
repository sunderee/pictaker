import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pictaker/utils/build_context.ext.dart';

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
    WidgetsBinding.instance?.addObserver(this);
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
    WidgetsBinding.instance?.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      child: CameraPreview(_controller!),
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
      if (mounted) setState(() {});
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
}
