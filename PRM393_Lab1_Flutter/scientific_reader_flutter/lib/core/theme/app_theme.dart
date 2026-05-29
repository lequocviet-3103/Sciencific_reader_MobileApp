import 'package:flutter/material.dart';

class AppTheme {

  static ThemeData lightTheme =
      ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor:
        Colors.white,
  );

  static ThemeData darkTheme =
      ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor:
        Colors.black,
  );
}