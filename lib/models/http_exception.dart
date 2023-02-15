import 'package:flutter/material.dart';

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  static Future<void> checkForError(int statusCode, String? message,
      [VoidCallback? onError]) async {
    if (statusCode >= 400) {
      throw HttpException(message ?? 'An error occurred.');
    }
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
  }

  @override
  String toString() {
    return message;
  }
}
