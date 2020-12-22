import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'state.dart';
import 'wallet.dart';
import 'art.dart';
import 'dart:math' as math;

const appTitle = "BitOnPaper - Bitcoin On Paper";

void main() {
  var bitOnPaper = BitOnPaper();
  var app = MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.amber,
    ),
    home: bitOnPaper,
  );
  runApp(app);
}

class BitOnPaper extends StatefulWidget {
  @override
  BitOnPaperState createState() => BitOnPaperState();
}

class BitOnPaperUI extends StatelessWidget {
  final BitOnPaperState state;

  BitOnPaperUI(this.state);

  @override
  Widget build(BuildContext context) {
    BottomAppBar bottomBar = BottomAppBar(
      color: Colors.amber,
      child: Text("Status"),
    );
    AppBar topBar = AppBar(title: Text(appTitle));

    return Scaffold(
      appBar: topBar,
      bottomNavigationBar: bottomBar,
      drawer: Menu(child: ArtsMenu(), state: state),
      body: Sheet(child: WalletSheet(), state: state),
    );
  }
}

class Menu extends InheritedWidget {
  final BitOnPaperState state;
  Menu({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant Menu oldWidget) {
    return oldWidget.state.selected != state.selected;
  }

  static Menu of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Menu>();
  }
}

class ArtsMenu extends StatelessWidget {
  Widget build(BuildContext context) {
    BitOnPaperState appState = Menu.of(context).state;
    List<Widget> artsList = new List<Widget>.empty(growable: true);
    DrawerHeader header = DrawerHeader(
      child: Text(
        "Paper Arts",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      decoration: BoxDecoration(
        color: Colors.amber[600],
        image: const DecorationImage(
          image: NetworkImage('./icons/bop.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
      ),
    );
    artsList.add(header);
    var arts = appState.arts;
    var selected = appState.selected;
    arts.forEach((key, value) {
      Widget t;
      if (key == selected) {
        t = Text(key, style: TextStyle(fontWeight: FontWeight.bold));
      } else {
        t = Text(key);
      }
      var i = Image.network(value.url);
      ListTile tI = ListTile(
        leading: i,
        title: t,
        onTap: () {
          appState.setSelected(key);
          //Close the drawer when user selects.
          Navigator.pop(context);
        },
      );
      artsList.add(tI);
    });
    ListView list = ListView(children: artsList);
    return Drawer(
      child: list,
    );
  }
}

class Sheet extends InheritedWidget {
  final BitOnPaperState state;

  Sheet({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant Sheet oldWidget) {
    return oldWidget.state.selected != state.selected;
  }

  static Sheet of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Sheet>();
  }
}

class WalletSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BitOnPaperState appState = Sheet.of(context).state;
    var art = appState.getSelectedArt();
    var wallets = appState.wallets;
    List<Paper> papers = List<Paper>.empty(growable: true);
    if (art != null && wallets != null) {
      wallets.forEach((w) {
        Paper p = Paper(wallet: w, art: art);
        papers.add(p);
      });
    }
    return Container(
      child: Column(children: papers),
      alignment: Alignment.topCenter,
    );
  }
}

class Paper extends StatelessWidget {
  final Wallet wallet;
  final Art art;

  Paper({this.wallet, this.art});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black45),
            ),
            height: 500,
            width: 500,
            child: LayoutBuilder(builder: (context, constraint) {
              return getPaperElementList(art, wallet, constraint);
            })));
  }

  Widget getPaperElementList(
      Art art, Wallet wallet, BoxConstraints constraint) {
    List<Widget> els = List<Widget>.empty(growable: true);
    double ratio = constraint.maxWidth/art.width;
    els.add(getPaperElement(
        child: Image.network(this.art.url),
        height: art.height,
        width: art.width,
        top: 0,
        left: 0,
        scale: ratio,
        rotation: 0));
    if (art.pk.visible) {
      els.add(getPaperElement(
          child: Text(wallet.privateKey,
              style: TextStyle(fontSize: art.pk.size*ratio),
              textAlign: TextAlign.left),
          height: art.pk.height,
          width: art.pk.width,
          top: art.pk.top,
          left: art.pk.left,
          scale: ratio,
          rotation: art.pk.rotation));
    }
    if (art.pkQr.visible) {
      QrImage qr = QrImage(
        data: wallet.privateKey,
        version: QrVersions.auto,
        size: art.pkQr.size,
      );
      els.add(getPaperElement(
          child: qr,
          height: art.pkQr.height,
          width: art.pkQr.width,
          top: art.pkQr.top,
          left: art.pkQr.left,
          scale: ratio,
          rotation: art.pkQr.rotation));
    }
    if (art.ad.visible) {
      els.add(getPaperElement(
          child: Text(wallet.publicAddress,
              style: TextStyle(fontSize: art.ad.size*ratio),
              textAlign: TextAlign.left),
          height: art.ad.height,
          width: art.ad.width,
          top: art.ad.top,
          left: art.ad.left,
          scale: ratio,
          rotation: art.ad.rotation));
    }
    if (art.adQr.visible) {
      QrImage qr = QrImage(
        data: wallet.publicAddress,
        version: QrVersions.auto,
        size: art.adQr.size,
      );
      els.add(getPaperElement(
          child: qr,
          height: art.adQr.height,
          width: art.adQr.width,
          top: art.adQr.top,
          left: art.adQr.left,
          scale: ratio,
          rotation: art.adQr.rotation));
    }
    return Stack(
        fit: StackFit.expand, clipBehavior: Clip.hardEdge, children: els);
  }

  Widget getPaperElement(
      {double top,
      double left,
      double width,
      double height,
      double rotation,
      Widget child,
      double scale}) {
    double angle = (rotation / 180) * math.pi;
    return Positioned(
      child: Transform.rotate(
        origin: Offset(0, 0),
        alignment: Alignment.centerLeft,
        angle: angle,
        child: child,
      ),
      top: top*scale,
      left: left*scale,
      width: width*scale,
      height: height*scale,
    );
  }
}
