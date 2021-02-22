import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'export.dart' if (dart.library.io) 'export_hw.dart' if (dart.library.js) 'export_web.dart';
import 'dart:convert';
import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/wallets.dart';
import 'package:bitonpaper/papers.dart';
import 'package:bitonpaper/menu.dart';
import 'package:bitonpaper/bottomBar.dart';
import 'package:bitonpaper/topBar.dart';

const double mainWidth = 860;

class ScreenWallets extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Arts arts;
  final Wallets wallets;
  final Papers papers;

  ScreenWallets({@required this.analytics, @required this.observer, @required this.arts, @required this.wallets, @required this.papers});

  @override
  State<ScreenWallets> createState() {
    return _ScreenWalletsState();
  }
}

class _ScreenWalletsState extends State<ScreenWallets> {
  _ScreenWalletsState();

  _addWallet() async {
    setState(() {
      Wallet w = widget.wallets.newWallet();
      Art a = widget.papers.selectedFirst;
      print("adding: " + w.publicAddress + " " + a.flavour);
      widget.papers.savePaper(wallet: w, art: a);
    });
    await widget.analytics.logEvent(
      name: 'add_wallet',
      parameters: <String, dynamic>{'num_wallets': widget.papers.length},
    );
  }

  _delete(Wallet w) async {
    setState(() {
      widget.wallets.delete(w);
      widget.papers.deletePaper(w);
    });
    await widget.analytics.logEvent(
      name: 'delete_wallet',
      parameters: <String, dynamic>{'num_wallets': widget.papers.length},
    );
  }

  bool _canDelete() {
    return widget.wallets.canDelete();
  }

  Future<void> _saveKeysToTXT() async {
    print("screenWallets saveKeysToTXT");
    String filename = "bop_keys-addr.json";
    String exportText = "";
    await widget.analytics.logEvent(name: 'save_keys_txt');
    filename = "bop_keys.txt";
    widget.wallets.iterable.forEach((element) {
      exportText += element.privateKey + " ";
    });
    final bytes = utf8.encode(exportText);
    openDownload(bytes, "text/plain", filename);
    int numWallets = widget.wallets.length;
    await widget.analytics.logEvent(
      name: 'export_keys_txt',
      parameters: <String, dynamic>{'num_wallets': numWallets},
    );
  }

  Future<void> _saveWalletsToJson() async {
    print("screenWallets saveWalletsToJson");
    String filename = "bop_keys-addr.json";
    String exportText = "";
    exportText += "{";
    for (int i = 0; i < widget.wallets.length; i++) {
      exportText += "\"" + widget.wallets.atIndex(i).publicAddress + "\": \"" + widget.wallets.atIndex(i).privateKey + "\"";
      if (i < widget.wallets.length - 1) {
        exportText += ",\n";
      }
    }
    exportText += "}";
    final bytes = utf8.encode(exportText);
    openDownload(bytes, "application/json", filename);
    int numWallets = widget.wallets.length;
    await widget.analytics.logEvent(
      name: 'export_keys_json',
      parameters: <String, dynamic>{'num_wallets': numWallets},
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Return scaffold ");
    return Scaffold(
      appBar: TopBar.build(context),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      drawer: Menu(),
      body: SingleChildScrollView(
        child: buildPage(context),
      ),
    );
  }

  Widget buildPage(BuildContext context) {
    Widget toolbar = buildToolbar(context);
    Widget list = Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          toolbar,
          buildKeysTable(context),
        ],
      ),
    );
    return list;
  }

  Widget buildToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      width: mainWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
            child: IconButton(
              onPressed: () => this._addWallet(),
              icon: Icon(Icons.add, semanticLabel: AppLocalizations.of(context).screenWallets_add),
              tooltip: AppLocalizations.of(context).screenWallets_add,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(100, 0, 3, 0),
            child: IconButton(
              onPressed: () async {
                await this._saveKeysToTXT();
              },
              icon: Icon(Icons.article, semanticLabel: AppLocalizations.of(context).screenWallets_exporttxt),
              tooltip: AppLocalizations.of(context).screenWallets_exporttxt,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: IconButton(
              onPressed: () async {
                await this._saveWalletsToJson();
              },
              icon: Icon(Icons.arrow_circle_down, semanticLabel: AppLocalizations.of(context).screenWallets_exportjson),
              tooltip: AppLocalizations.of(context).screenWallets_exportjson,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildKeysTable(BuildContext context) {
    TextStyle colNameTextStyle = Theme.of(context).textTheme.headline6;
    List<TableRow> rows = List<TableRow>.empty(growable: true);
    rows.add(
      TableRow(
        children: [
          Text(AppLocalizations.of(context).screenWallets_address, style: colNameTextStyle),
          Text(AppLocalizations.of(context).screenWallets_privateKey, style: colNameTextStyle),
          Text(""),
        ],
      ),
    );
    widget.wallets.iterable.forEach((wallet) {
      rows.add(
        TableRow(
          children: [
            SelectableText(wallet.publicAddress),
            SelectableText(wallet.privateKey),
            Container(
              margin: EdgeInsets.fromLTRB(3, 0, 3, 6),
              child: IconButton(
                onPressed: this._canDelete() ? () => this._delete(wallet) : null,
                icon: Icon(Icons.delete, semanticLabel: AppLocalizations.of(context).screenWallets_delete),
                tooltip: AppLocalizations.of(context).screenWallets_delete,
              ),
            ),
          ],
        ),
      );
    });
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
      width: mainWidth,
      child: Table(
        // border: TableBorder.all(width: 1),
        defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
        columnWidths: {
          0: FractionColumnWidth(0.45),
          1: FractionColumnWidth(0.45),
          2: FractionColumnWidth(0.1),
        },
        children: rows,
      ),
    );
  }
}
