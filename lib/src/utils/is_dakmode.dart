import 'package:flutter/material.dart';

bool inDarkMode(BuildContext context) {
  // return false;
  var brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.dark;
}
