import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pictaker/ui/widgets/shutter_button.widget.dart';
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
