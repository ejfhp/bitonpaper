import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bop/ui/bopScreen.dart';
import 'package:bop/ui/intro.dart';
import 'package:bop/ui/theme.dart';
import 'package:bop/conf.dart';
import 'package:bop/main.dart';

class BOPApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  final Init init;
  final bool ready;

  BOPApp(this.init, this.ready);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'en'),
        const Locale.fromSubtags(languageCode: 'it'),
      ],
      theme: themeData,
      title: APPLICATION_TITLE,
      routes: this.ready
          ? <String, WidgetBuilder>{
              '/bop': (context) => BOPScreen(
                    analytics: analytics,
                    observer: observer,
                    arts: this.init.arts,
                    wallets: this.init.wallets,
                  ),
            }
          : <String, WidgetBuilder>{},
      home: Intro(this.ready),
      navigatorObservers: <NavigatorObserver>[observer],
    );
  }
}
