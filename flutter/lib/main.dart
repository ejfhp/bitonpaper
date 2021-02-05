import 'package:bitonpaper/conf.dart';
import 'package:flutter/material.dart';
import 'BOP.dart';
import 'intro.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

//TODO Check null safety
//flutter packages pub outdated --mode=null-safety

void main() async {
  // If you're running an application and need to access the binary messenger before `runApp()`
  // has been called (for example, during plugin initialization), then you need to explicitly
  // call the `WidgetsFlutterBinding.ensureInitialized()` first.
  // If you're running a test, you can call the `TestWidgetsFlutterBinding.ensureInitialized()`
  // as the first line in your test's `main()` method to initialize the binding.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BOPApp());
}

class BOPApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    var initialPage = Intro();
    return MaterialApp(
      title: APPLICATION_TITLE,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.light,
        textTheme: TextTheme(
          headline1: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 2),
          bodyText2: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 12),
          subtitle1: TextStyle(fontFamily: "Roboto", color: Colors.black54, fontSize: 16),
          headline5: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 16),
          headline6: TextStyle(fontFamily: "Roboto", color: Colors.amber, fontSize: 14),
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
        '/wallet': (BuildContext context) => BOP(analytics, observer),
      },
      navigatorObservers: <NavigatorObserver>[observer],
      initialRoute: '/',
    );
  }
}
