import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:bitonpaper/papers.dart';
import 'package:bitonpaper/wallets.dart';
import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/menu.dart';
import 'package:bitonpaper/bottomBar.dart';
import 'package:bitonpaper/topBar.dart';

class ScreenArts extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Papers papers;
  final Arts arts;
  final Wallets wallets;

  ScreenArts({@required this.analytics, @required this.observer, @required this.arts, @required this.wallets, @required this.papers});

  @override
  Widget build(BuildContext context) {
    print("Return scaffold ");
    return Scaffold(
      appBar: TopBar.build(context),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      drawer: Menu(),
      body: buildMainArtsList(context),
    );
  }

  Widget buildMainArtsList(BuildContext context) {
    return ArtsList(analytics: this.analytics, observer: this.observer, papers: this.papers, arts: this.arts, wallets: this.wallets);
  }
}

class ArtsList extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Papers papers;
  final Arts arts;
  final Wallets wallets;
  final List<Art> selected = List<Art>.empty(growable: true);

  ArtsList({@required this.analytics, @required this.observer, @required this.papers, @required this.arts, @required this.wallets});

  @override
  ArtsListState createState() => ArtsListState(
        analytics: this.analytics,
        observer: this.observer,
        arts: this.arts,
        wallets: this.wallets,
        papers: this.papers,
      );
}

class ArtsListState extends State<ArtsList> {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  final Papers papers;
  final Arts arts;
  final Wallets wallets;

  ArtsListState({@required this.analytics, @required this.observer, @required this.arts, @required this.wallets, @required this.papers});

  setSelected(Art art) async {
    setState(() {
      this.papers.select(art);
    });
    await widget.analytics.logEvent(
      name: 'select_art',
      parameters: <String, dynamic>{'kind': art.kind, "flavour": art.flavour},
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle kindTextStyle = Theme.of(context).textTheme.headline5;
    Widget list = Container(
      child: ListView.builder(
          itemCount: arts.getLengthKinds(),
          scrollDirection: Axis.vertical,
          cacheExtent: 50,
          addAutomaticKeepAlives: true,
          itemBuilder: (context, indexK) {
            String artKind = arts.getKindName(indexK);
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      artKind.toUpperCase(),
                      style: kindTextStyle,
                    ),
                    height: 50,
                    width: 500,
                  ),
                  Container(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: arts.getLengthFlavours(artKind),
                      cacheExtent: 30,
                      addAutomaticKeepAlives: true,
                      itemBuilder: (context, indexF) {
                        String artFlavour = arts.getFlavourName(artKind, indexF);
                        return ArtBox(
                          artsListState: this,
                          kind: artKind,
                          flavour: artFlavour,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
    return list;
  }
}

class ArtBox extends StatefulWidget {
  final ArtsListState artsListState;
  final String kind;
  final String flavour;

  ArtBox({@required this.artsListState, @required this.kind, @required this.flavour});

  @override
  _ArtBoxState createState() => _ArtBoxState();
}

class _ArtBoxState extends State<ArtBox> with AutomaticKeepAliveClientMixin<ArtBox> {
  Future<Paper> paper;

  _ArtBoxState();

  @override
  void initState() {
    super.initState();
    print("Initstate: " + widget.kind + " " + widget.flavour);
    FutureOr<Art> art = widget.artsListState.arts.getArt(kind: widget.kind, flavour: widget.flavour);
    this.paper = widget.artsListState.papers.willGeneratePaper(wallet: widget.artsListState.wallets.first, futureArt: art);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    assert(this.paper != null);
    TextStyle flavTextStyle = Theme.of(context).textTheme.headline6;
    return Container(
      margin: EdgeInsets.fromLTRB(2, 2, 0, 0),
      child: FutureBuilder<Paper>(
          future: this.paper,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Art art = snapshot.data.art;
              int w = art.width;
              int h = art.height;
              double mh = 158;
              double mw = (mh / h) * w;
              Uint8List overlayBytes = snapshot.data.overlayBytes;
              return Column(
                //The column here is just to make the card shrink to its content
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      widget.artsListState.setSelected(art);
                    },
                    child: Card(
                      elevation: 10,
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: widget.artsListState.papers.isSelected(art) ? Colors.amber : Colors.blueGrey[300], width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                                  child: Center(child: Image(image: MemoryImage(art.bytes), fit: BoxFit.scaleDown)),
                                ),
                                Positioned.fill(
                                  child: Center(child: Image(image: MemoryImage(overlayBytes), fit: BoxFit.scaleDown)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                            constraints: BoxConstraints(minWidth: 200, minHeight: 30),
                            width: mw,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: widget.artsListState.papers.isSelected(art) ? Colors.amber : Colors.blueGrey[300], width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Container(padding: EdgeInsets.all(4), child: Text(art.flavour.toUpperCase(), style: flavTextStyle)),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Text("loading...");
            }
          }),
    );
  }
}
