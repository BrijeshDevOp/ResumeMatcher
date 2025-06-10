import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

SnackBar awesomeWarningSnackbar({
  required String title,
  required String message,
}) {
  return SnackBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: ContentType.warning,
    ),
    behavior: SnackBarBehavior.floating,
  );
}