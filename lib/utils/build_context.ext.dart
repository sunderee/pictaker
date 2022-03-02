import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
