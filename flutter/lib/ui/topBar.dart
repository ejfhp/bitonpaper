import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bop/conf.dart';

class TopBar {
  static PreferredSize build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(HEADER_HEIGHT),
      child: AppBar(
          iconTheme: IconThemeData(color: Colors.amber),
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(HEADER_HEIGHT),
              child: Container(
                height: HEADER_HEIGHT,
                color: Colors.blueGrey,
                padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Image.asset(
                  "resources/imgs/bop_long.png",
                  fit: BoxFit.contain,
                ),
              ))),
    );
  }
}
