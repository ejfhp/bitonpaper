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
      brightness: Brightness.light,
      accentColor: Colors.cyan[600],
      canvasColor: Colors.blueGrey[50],
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
