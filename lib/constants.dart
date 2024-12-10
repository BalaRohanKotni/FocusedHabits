import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum FocusSessionStatus { active, inactive, paused }

List<String> months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

Color kAppBackgroundColor = Colors.grey[900]!;
// kAppBackgroundColor = Colors.white;
Future<bool> hasNetwork() async {
  if (kIsWeb) {
    try {
      final result = await http.get(Uri.parse('www.google.com'));
      if (result.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  } else {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

String firebaseExceptionHandler(e, networkStatus) {
  String error;
  switch (e.code) {
    case "invalid-email":
      error = "Email address is not valid";
      break;
    case "user-disabled":
      error = "Account is disabled";
      break;
    case "user-not-found":
      error = "Account not found, check email address or create a new account";
      break;
    case "wrong-password":
      error = "Incorrect password";
      break;
    default:
      if (!networkStatus) {
        error = "No internet connection";
      } else {
        error = e.message;
      }
    // error = e.code;
  }
  return error;
}
