import 'dart:typed_data';
import 'package:bitonpaper/printer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitonpaper/papers.dart';
import 'package:bitonpaper/wallets.dart';
import 'package:bitonpaper/waiting.dart';
import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/menu.dart';
import 'package:bitonpaper/bottomBar.dart';
import 'package:bitonpaper/topBar.dart';

const double mainWidth = 860;

class ScreenPrint extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Papers papers;
  final List<Wallet> _wallets;

  ScreenPrint({@required this.analytics, @required this.observer, @required this.papers}) : this._wallets = papers.list();

  @override
  State<ScreenPrint> createState() {
    return _ScreenPrintState(0, this.papers.getPaper(wallet: this._wallets[0]));
  }
}

class _ScreenPrintState extends State<ScreenPrint> {
  int _currentPaperIndex;
  Future<Paper> _currentPaper;

  _ScreenPrintState(this._currentPaperIndex, this._currentPaper);

  moveForward() {
    if (_currentPaperIndex < widget._wallets.length - 1) {
      setState(() {
        this._currentPaperIndex++;
        this._currentPaper = widget.papers.getPaper(wallet: widget._wallets[_currentPaperIndex]);
      });
    }
  }

  moveBack() {
    if (_currentPaperIndex > 0) {
      setState(() {
        this._currentPaperIndex--;
        this._currentPaper = widget.papers.getPaper(wallet: widget._wallets[_currentPaperIndex]);
      });
    }
  }

  bool canMoveForward() {
    return this._currentPaperIndex < widget._wallets.length - 1;
  }

  bool canMoveBack() {
    return this._currentPaperIndex > 0;
  }

  Future<void> printWallets(BuildContext context) async {
    print("screenPrint print");
    Navigator.of(context).push(WaitingOverlay(AppLocalizations.of(context).message_waitingprint));
    await Future.delayed(const Duration(milliseconds: 300), () {});
    int s = DateTime.now().millisecondsSinceEpoch;
    PaperPrintSet printSet = PaperPrintSet(papers: widget.papers);
    await printSet.printPages();
    print("screenPrint PDF printed in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    Iterator<Art> selected = widget.papers.selected;
    int numWallets = widget.papers.length;
    await widget.analytics.logEvent(
      name: 'print_papers',
      parameters: <String, dynamic>{'num_wallets': numWallets},
    );
    while (selected.moveNext()) {
      await widget.analytics.logEvent(
        name: 'printed_paper',
        parameters: <String, dynamic>{'kind': selected.current.name, 'flavour': selected.current.flavour},
      );
    }
    // //Remove the alert
    Navigator.of(context).pop();
  }

  Future<void> exportWalletsToPDF(BuildContext context) async {
    print("screenPrint exportToPDF");
    Navigator.of(context).push(WaitingOverlay(AppLocalizations.of(context).message_waitingpdf));
    await Future.delayed(const Duration(milliseconds: 300), () {});
    int s = DateTime.now().millisecondsSinceEpoch;
    PaperPrintSet printSet = PaperPrintSet(papers: widget.papers);
    await printSet.downloadPages();
    print("screenPrint PDF exported in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    Iterator<Art> selected = widget.papers.selected;
    int numWallets = widget.papers.length;
    await widget.analytics.logEvent(
      name: 'export_papers',
      parameters: <String, dynamic>{'num_wallets': numWallets},
    );
    while (selected.moveNext()) {
      await widget.analytics.logEvent(
        name: 'exported_paper',
        parameters: <String, dynamic>{'kind': selected.current.name, 'flavour': selected.current.flavour},
      );
    }
    // //Remove the alert
    Navigator.of(context).pop();
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
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            toolbar,
            buildPrintPreview(context),
          ],
        ),
      ),
    );
    return list;
  }

  Widget buildToolbar(BuildContext context) {
    print("buildToolbar");
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      width: mainWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: IconButton(
              onPressed: () async {
                await exportWalletsToPDF(context);
              },
              icon: Icon(Icons.picture_as_pdf, semanticLabel: AppLocalizations.of(context).screenPrint_export),
              tooltip: AppLocalizations.of(context).screenPrint_export,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: IconButton(
                onPressed: () async {
                  await printWallets(context);
                },
                icon: Icon(Icons.print, semanticLabel: AppLocalizations.of(context).screenPrint_print),
                tooltip: AppLocalizations.of(context).screenPrint_print),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(100, 0, 3, 0),
            child: IconButton(
              onPressed: canMoveBack() ? () => moveBack() : null,
              icon: Icon(Icons.arrow_back, semanticLabel: AppLocalizations.of(context).screenPrint_previous),
              tooltip: AppLocalizations.of(context).screenPrint_previous,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: IconButton(
              onPressed: canMoveForward() ? () => moveForward() : null,
              icon: Icon(Icons.arrow_forward, semanticLabel: AppLocalizations.of(context).screenPrint_next),
              tooltip: AppLocalizations.of(context).screenPrint_next,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrintPreview(BuildContext context) {
    TextStyle flavTextStyle = Theme.of(context).textTheme.headline6;
    print("buildPrintPreview");
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
      width: mainWidth,
      child: FutureBuilder<Paper>(
          future: this._currentPaper,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              assert(snapshot.data != null);
              print("builder for " + snapshot.data.wallet.publicAddress);
              Art art = snapshot.data.art;
              Wallet wallet = snapshot.data.wallet;
              assert(art != null);
              int w = art.width;
              int h = art.height;
              double mw = 800;
              double mh = 800;
              if (w > h) {
                mh = (mw / w) * h;
              } else {
                mw = (mh / h) * w;
              }
              Uint8List overlayBytes = snapshot.data.overlayBytes;
              return Column(
                //The column here is just to make the card shrink to its content
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 10,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxHeight: mh, maxWidth: mw),
                          margin: EdgeInsets.all(4),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                // padding: EdgeInsets.all(2),
                                child: Center(child: Image(image: MemoryImage(art.bytes), fit: BoxFit.scaleDown)),
                              ),
                              Positioned.fill(
                                // padding: EdgeInsets.all(2),
                                child: Center(child: Image(image: MemoryImage(overlayBytes), fit: BoxFit.scaleDown)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                          constraints: BoxConstraints(minWidth: 200, minHeight: 40),
                          width: mw,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blueGrey[300], width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text: (this._currentPaperIndex + 1).toString() + ": ", style: flavTextStyle),
                                  TextSpan(text: art.kind.toUpperCase(), style: flavTextStyle),
                                  TextSpan(text: " [" + art.flavour.toUpperCase() + "]\n", style: flavTextStyle),
                                  TextSpan(text: AppLocalizations.of(context).screenPrint_address + ": " + wallet.publicAddress + "", style: flavTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Text("loading...");
            }
          }),
    );
  }
}
