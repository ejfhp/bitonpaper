import 'package:flutter/material.dart';
import 'BOP.dart';
import 'intro.dart';

const appTitle = "BitOnPaper - Bitcoin On Paper";

//TODO Check null safety
//flutter packages pub outdated --mode=null-safety

void main() {
  // var initialPage = PaperPage();
  var initialPage = Intro();
  var app = MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      brightness: Brightness.light,
      textTheme: TextTheme(
        headline1: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 2),
        bodyText2: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 12),
        subtitle1: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 16),
        headline5: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 16),
        headline6: TextStyle(fontFamily: "Roboto", color: Colors.blueGrey[50], fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
        textStyle: MaterialStateProperty.all(TextStyle(
          fontFamily: "Roboto",
          color: Colors.amber,
          fontSize: 20,
        )),
        foregroundColor: MaterialStateProperty.all(Colors.amber),
      )),
      accentColor: Colors.amber,
      canvasColor: Colors.blueGrey[50],
      applyElevationOverlayColor: false,
      shadowColor: Colors.black54,
      fontFamily: "Roboto",
    ),
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => initialPage,
      '/wallet': (BuildContext context) => BOP(),
    },
    initialRoute: '/',
  );
  runApp(app);
}
