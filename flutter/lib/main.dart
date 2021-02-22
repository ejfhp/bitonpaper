import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/conf.dart';
import 'package:bitonpaper/screenArts.dart';
import 'package:bitonpaper/wallets.dart';
import 'package:bitonpaper/screenWallets.dart';
import 'package:bitonpaper/screenPrint.dart';
import 'package:flutter/material.dart';
import 'package:bitonpaper/intro.dart';
import 'package:bitonpaper/theme.dart';
import 'package:bitonpaper/papers.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//TODO Check null safety
//flutter packages pub outdated --mode=null-safety

void main() async {
  runApp(BOPStartingPoint());
}

class BOPStartingPoint extends StatelessWidget {
  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Initialization',
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BOPApp(Init.arts, Init.papers, Init.wallets);
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Initializing BOP...",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          CircularProgressIndicator()
        ],
      ),
    );
  }
}

class Init {
  static Arts arts;
  static Papers papers;
  static Wallets wallets;

  static Future initialize() async {
    await _prepareServices();
    await _prepareArts();
  }

  static _prepareArts() async {
    print("Init - preparingArts");
    arts = Arts();
    wallets = Wallets();
    papers = Papers(wallets.first, await arts.getDefault());
    print("Init - preparingArts complete");
  }

  static _prepareServices() async {
    print("Init - prepareServices");
    // Required for Firebase
    // If you're running an application and need to access the binary messenger before `runApp()`
    // has been called (for example, during plugin initialization), then you need to explicitly
    // call the `WidgetsFlutterBinding.ensureInitialized()` first.
    // If you're running a test, you can call the `TestWidgetsFlutterBinding.ensureInitialized()`
    // as the first line in your test's `main()` method to initialize the binding.
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("Init - prepareServices complete");
  }
}

class BOPApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  final Wallets wallets;
  final Arts arts;
  final Papers papers;

  BOPApp(this.arts, this.papers, this.wallets);

  @override
  Widget build(BuildContext context) {
    assert(this.arts != null);
    assert(this.papers != null);
    assert(this.wallets != null);
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'en'),
        const Locale.fromSubtags(languageCode: 'it'),
        // const Locale.fromSubtags(languageCode: 'zh'), // Chinese
      ],
      theme: themeData,
      title: APPLICATION_TITLE,
      routes: <String, WidgetBuilder>{
        '/arts': (context) => ScreenArts(
              analytics: analytics,
              observer: observer,
              arts: this.arts,
              papers: this.papers,
              wallets: this.wallets,
            ),
        '/wallets': (context) => ScreenWallets(
              analytics: analytics,
              observer: observer,
              arts: this.arts,
              wallets: this.wallets,
              papers: this.papers,
            ),
        '/print': (context) => ScreenPrint(
              analytics: analytics,
              observer: observer,
              papers: this.papers,
            ),
      },
      home: Intro(),
      navigatorObservers: <NavigatorObserver>[observer],
    );
  }
}
