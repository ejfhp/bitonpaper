import 'dart:typed_data';

import 'package:bop/ui/artScan.dart';
import 'package:bop/ui/bopCentral.dart';
import 'package:bop/ui/bopInherited.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bop/graphic/papers.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:bop/graphic/arts.dart';
import 'package:bop/ui/artList.dart';
import 'package:bop/ui/artPrint.dart';
import 'package:bop/conf.dart';
import 'package:bop/ui/topBar.dart';

const ART_LIST = 0;
// const ART_WALLET = 1;
// const ART_EDITOR = 2;
const ART_PRINT = 1;
const ART_SCAN = 2;

class BOPScreen extends StatefulWidget {
  final BOPCentral bopCentral;

  BOPScreen({@required FirebaseAnalytics analytics, @required FirebaseAnalyticsObserver observer, @required Arts arts, @required Wallets wallets})
      : bopCentral = BOPCentral(arts: arts, wallets: wallets, analytics: analytics, observer: observer);

  @override
  _BOPScreenState createState() => _BOPScreenState();
}

class _BOPScreenState extends State<BOPScreen> {
  int _currentIndex = 0;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ArtList(Key(widget.bopCentral.arts.getLength().toString())),
      // ArtWallets(),
      // ArtEditor(null, Key("null")),
      ArtPrint(null, Key("")),
      ArtScan(),
    ];
  }

  void _changePage(int index) async {
    if (index == ART_PRINT) {
      Papers p = await widget.bopCentral.getPapers();
      String hash = p.hash();
      print("Paper Hash: $hash");
      this._pages[ART_PRINT] = ArtPrint(p, Key(hash));
    }
    if (index == ART_LIST) {
      this._pages[ART_LIST] = ArtList(Key(widget.bopCentral.getArtsCount().toString()));
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadArtFromBOP() async {
    await widget.bopCentral.loadArt();
    setState(() {
      print("BOPScreenState set a new ArtEditor");
      this._pages[0] = ArtList(Key(widget.bopCentral.getArtsCount().toString()));
      _currentIndex = 0;
    });
    //Close the menu
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print("Return scaffold ");
    return Scaffold(
      appBar: TopBar.build(context),
      backgroundColor: Colors.white,
      drawer: _buildMenu(context),
      body: BOPInherited(
        widget.bopCentral,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: Colors.amber,
      unselectedItemColor: Colors.amber,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.photo,
            color: Colors.amber,
            size: 25,
            semanticLabel: AppLocalizations.of(context).navigation_list,
          ),
          backgroundColor: Colors.blueGrey,
          label: AppLocalizations.of(context).navigation_list,
          tooltip: AppLocalizations.of(context).navigation_list,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.content_paste_rounded,
            color: Colors.amber,
            size: 25,
            semanticLabel: AppLocalizations.of(context).navigation_print,
          ),
          backgroundColor: Colors.blueGrey,
          label: AppLocalizations.of(context).navigation_print,
          tooltip: AppLocalizations.of(context).navigation_print,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.qr_code,
            color: Colors.amber,
            size: 25,
            semanticLabel: AppLocalizations.of(context).navigation_print,
          ),
          backgroundColor: Colors.blueGrey,
          label: AppLocalizations.of(context).navigation_scan,
          tooltip: AppLocalizations.of(context).navigation_scan,
        ),
      ],
      onTap: (int index) {
        this._changePage(index);
      },
    );
  }

  Widget _buildMenu(BuildContext context) {
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
            "actions",
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
              Icons.upload_sharp,
              color: Colors.blueGrey,
              size: 20,
              semanticLabel: AppLocalizations.of(context).menu_loadBop,
            ),
            title: Text(AppLocalizations.of(context).menu_loadBop),
            onTap: () async => await _loadArtFromBOP(),
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
