import 'package:flutter/material.dart';
import 'BOP.dart';
import 'intro.dart';

const appTitle = "BitOnPaper - Bitcoin On Paper";

void main() {
  // var initialPage = PaperPage();
  var initialPage = Intro();
  var app = MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
      accentColor: Colors.cyanAccent,
      canvasColor: Colors.blueGrey[100],
    ),
    routes: <String, WidgetBuilder> {
      '/intro': (BuildContext context) => initialPage,
      '/wallet': (BuildContext context) => BOP(),
    },
    home: initialPage,
  );
  runApp(app);
}
