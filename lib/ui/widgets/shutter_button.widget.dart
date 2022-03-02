import 'package:flutter/material.dart';

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
