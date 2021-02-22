import 'package:flutter/material.dart';

ThemeData themeData = ThemeData(
  primarySwatch: Colors.blueGrey,
  brightness: Brightness.light,
  textTheme: TextTheme(
    headline1: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 2),
    bodyText2: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 12),
    subtitle1: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 16),
    headline5: TextStyle(fontFamily: "Roboto", color: Colors.blueGrey, fontSize: 16), //KIND iN screenArts
    headline6: TextStyle(fontFamily: "Roboto", color: Colors.blueGrey, fontSize: 14), //FLAVOUR in screenArts, Column in wallets
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontFamily: "Roboto",
          color: Colors.amber,
          fontSize: 20,
        ),
      ),
      foregroundColor: MaterialStateProperty.all(Colors.amber),
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.blueGrey,
    size: 20,
  ),
  accentColor: Colors.amber,
  canvasColor: Colors.blueGrey[50],
  disabledColor: Colors.grey[350],
  applyElevationOverlayColor: false,
  shadowColor: Colors.black54,
  fontFamily: "Roboto",
);
