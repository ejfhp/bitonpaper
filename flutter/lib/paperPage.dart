import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'paperPageState.dart';
import 'wallet.dart';
import 'art.dart';
import 'dart:math' as math;

//Main StatefulWidget
class PaperPage extends StatefulWidget {
  @override
  PaperPageState createState() => PaperPageState();
}

//Main StatelessWidget
class PaperPageUI extends StatelessWidget {
  final PaperPageState state;

  PaperPageUI(this.state);

  @override
  Widget build(BuildContext context) {
    BottomAppBar bottomBar = BottomAppBar(
        color: Colors.blueGrey,
        child: Text(
          "Works only on Bitcoin (SV). Use at your own risk. See the running code on Github.",
          textAlign: TextAlign.center,
        ));
    AppBar topBar = AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.network(
        "./icons/bop_long.png",
        fit: BoxFit.contain,
        height: 40,
      )
    ]));

    return Scaffold(
      appBar: topBar,
      bottomNavigationBar: bottomBar,
      drawer: Menu(child: ArtsMenu(), state: state),
      body: Sheet(child: WalletSheet(), state: state),
    );
  }
}

class Menu extends InheritedWidget {
  final PaperPageState state;
  Menu({Widget child, this.state}) : super(child: child);

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
    PaperPageState appState = Menu.of(context).state;
    List<Widget> artsList = new List<Widget>.empty(growable: true);
    DrawerHeader header = DrawerHeader(
        child: Image.network(
      './icons/bop_twol.png',
      fit: BoxFit.contain,
      height: 40,
    ));
    artsList.add(header);
    var arts = appState.arts;
    var selected = appState.selected;
    arts.forEach((k, v) {
      Widget t;
      if (k == selected) {
        t = Text(k, style: TextStyle(fontWeight: FontWeight.bold));
      } else {
        t = Text(k);
      }
      var i = Image.network(v.url);
      ListTile tI = ListTile(
        leading: i,
        title: t,
        onTap: () {
          appState.setSelected(k);
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
  final PaperPageState state;

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
    PaperPageState appState = Sheet.of(context).state;
    var art = appState.getSelectedArt();
    var wallets = appState.wallets;
    if (art == null || wallets == null) {
      return Text("No DATA");
    }
    Wallet w = wallets.first;
    Paper p = Paper(wallet: w, art: art);
    // return LayoutBuilder(builder: (context, constraints) {
    return SingleChildScrollView(
      // child: ConstrainedBox(
      // constraints: BoxConstraints(),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black45),
        ),
        padding: EdgeInsets.all(20),
        child: p,
        alignment: Alignment.center,
      ),
      // )
    );
    // }
    // );
  }
}

class Paper extends StatelessWidget {
  final Wallet wallet;
  final Art art;

  Paper({this.wallet, this.art});

  @override
  Widget build(BuildContext context) {
    var dsize = MediaQuery.of(context).size;
    double scale = dsize.width / art.width;
    if (scale > 1) {
      scale = 1;
    }
    return Column(children: [
      Container(
          height: art.height * scale,
          width: art.width * scale,
          child: LayoutBuilder(builder: (context, constraint) {
            return getPaper(art: art, wallet: wallet, constraint: constraint);
          })),
      FlatButton(
          onPressed: () {
            Sheet.of(context).state.toPDF();
          },
          child: Text("PNG"))
    ]);
  }

  Widget getPaper({Art art, Wallet wallet, BoxConstraints constraint}) {
    List<Widget> els = List<Widget>.empty(growable: true);
    double ratio = constraint.maxWidth / art.width;
    els.add(getPaperElement(
        child: Container(
          child:
              Image.network(this.art.url, height: art.height, width: art.width),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black45),
          ),
        ),
        height: art.height,
        width: art.width,
        top: 0,
        left: 0,
        scale: ratio,
        rotation: 0));
    if (art.pk.visible) {
      els.add(getPaperElement(
          child: Text(wallet.privateKey,
              style: TextStyle(fontSize: art.pk.size * ratio),
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
        padding: EdgeInsets.all(0),
        gapless: true,
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
              style: TextStyle(fontSize: art.ad.size * ratio),
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
        padding: EdgeInsets.all(0),
        gapless: true,
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
      fit: StackFit.passthrough,
      clipBehavior: Clip.hardEdge,
      children: els,
    );
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
      top: top * scale,
      left: left * scale,
      width: width * scale,
      height: height * scale,
    );
  }
}
