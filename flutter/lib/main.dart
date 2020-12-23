import 'package:flutter/material.dart';
import 'paperPage.dart';
import 'introPage.dart';

const appTitle = "BitOnPaper - Bitcoin On Paper";

void main() {
  // var initialPage = PaperPage();
  var initialPage = IntroPage();
  var app = MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    routes: <String, WidgetBuilder> {
      '/intro': (BuildContext context) => IntroPage(),
      '/wallet': (BuildContext context) => PaperPage(),
    },
    home: initialPage,
  );
  runApp(app);
}
