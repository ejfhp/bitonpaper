import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitonpaper/conf.dart';

class Menu extends StatelessWidget {
  Menu();

  Widget build(BuildContext context) {
    Container headerContainer = Container(
      height: HEADER_HEIGHT,
      child: DrawerHeader(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          alignment: Alignment.bottomLeft,
          child: Text(
            "todo",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
    );

    ListView list = ListView(
      children: [
        headerContainer,
        Card(
          child: ListTile(
            leading: Icon(
              Icons.photo,
              color: Colors.blueGrey,
              size: 20,
              semanticLabel: AppLocalizations.of(context).menu_arts,
            ),
            title: Text(AppLocalizations.of(context).menu_arts),
            onTap: () => Navigator.pushNamed(context, "/arts"),
          ),
        ),
        // Card(
        //   child: ListTile(
        //     leading: Icon(
        //       Icons.create,
        //       color: Colors.blueGrey,
        //       size: 20,
        //       semanticLabel: AppLocalizations.of(context).menu_custom,
        //     ),
        //     title: Text(AppLocalizations.of(context).menu_custom),
        //   ),
        // ),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.account_balance_wallet,
              color: Colors.blueGrey,
              size: 20,
              semanticLabel: AppLocalizations.of(context).menu_wallet,
            ),
            title: Text(AppLocalizations.of(context).menu_wallet),
            onTap: () => Navigator.pushNamed(context, "/wallets"),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.request_quote,
              color: Colors.blueGrey,
              size: 20,
              semanticLabel: AppLocalizations.of(context).menu_print,
            ),
            title: Text(AppLocalizations.of(context).menu_print),
            onTap: () => Navigator.pushNamed(context, "/print"),
          ),
        ),
      ],
    );
    return Drawer(
      elevation: 0,
      child: list,
    );
  }
}
