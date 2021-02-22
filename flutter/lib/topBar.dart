import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitonpaper/conf.dart';

class TopBar {
  static PreferredSize build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(HEADER_HEIGHT),
      child: AppBar(
          iconTheme: IconThemeData(color: Colors.amber),
          backgroundColor: Colors.blueGrey,
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: AppLocalizations.of(context).menu_menu,
              );
            },
          ),
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
