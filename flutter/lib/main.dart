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
