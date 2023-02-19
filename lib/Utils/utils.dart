import 'package:flutter/material.dart';

class Utils {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static showSnackBar(String? text, [bool? custom]) {
    if (text == null) return;
    final snackBar = SnackBar(content: Text(text), backgroundColor: (custom == null) ? Colors.red : Colors.green);

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
