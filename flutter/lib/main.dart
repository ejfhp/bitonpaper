import 'package:flutter/material.dart';
import 'paperPage.dart';

const appTitle = "BitOnPaper - Bitcoin On Paper";

void main() {
  var initialPage = PaperPage();
  var app = MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    home: initialPage,
  );
  runApp(app);
}
