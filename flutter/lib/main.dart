import 'package:flutter/material.dart';
import 'BOP.dart';
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
      '/wallet': (BuildContext context) => BOP(),
    },
    home: initialPage,
  );
  runApp(app);
}
