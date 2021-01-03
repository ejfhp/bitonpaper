import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'wallet.dart';
import 'art.dart';
import 'dart:math' as math;

class PaperSheetInh extends InheritedWidget {
  final BOPState state;

  PaperSheetInh({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant PaperSheetInh oldWidget) {
    return oldWidget.state.getSelectedArt() != state.getSelectedArt();
  }

  static PaperSheetInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaperSheetInh>();
  }
}

class PaperSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BOPState appState = PaperSheetInh.of(context).state;
    var art = appState.getSelectedArt();
    if (art == null || !appState.areWalletsReady()) {
      return Container(
        alignment: Alignment.center,
        child: Text("Loading..."),
      );
    }
    var ws = appState.getWallets();
    var pageSize = MediaQuery.of(context).size;
    Paper p = Paper(
      wallets: ws,
      art: appState.getSelectedArt(),
      maxWidth: pageSize.width,
    );
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: Colors.black45),
        ),
        padding: EdgeInsets.all(20),
        child: p,
        alignment: Alignment.center,
        // height: pageSize.height - 68, //- (header + bottom bar)
        height: 5000, //- (header + bottom bar)
      ),
    );
  }
}

class Paper extends StatelessWidget {
  final List<Wallet> wallets;
  final Art art;
  final double maxWidth;

  Paper({this.wallets, this.art, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    double scale = this.maxWidth / art.width;
    if (scale > 1) {
      scale = 1;
    }
    return Container(
      child: LayoutBuilder(builder: (context, constraint) {
        return getSheet(art: art, wallets: wallets, constraint: constraint);
      }),
    );
  }

  Widget getSheet({Art art, List<Wallet> wallets, BoxConstraints constraint}) {
    List<Widget> ww = List<Widget>.empty(growable: true);
    for (int i = 0; i < wallets.length; i++) {
      ww.add(Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: prepareArt(art: art, wallet: wallets[i], constraint: constraint),
      ));
    }
    return Column(
      children: ww,
    );
  }

  Widget prepareArt({Art art, Wallet wallet, BoxConstraints constraint}) {
    print("Art Max Width: " + constraint.maxWidth.toString());
    List<Widget> els = List<Widget>.empty(growable: true);
    ImageProvider pkQrImage = MemoryImage(wallet.pkQr);
    ImageProvider adQrImage = MemoryImage(wallet.adQr);
    ImageProvider pkImage = MemoryImage(wallet.pkImg);
    ImageProvider adImage = MemoryImage(wallet.adImg);
    double ratio = constraint.maxWidth / art.width;
    els.add(getPaperElement(
        child: Container(
          child: Image.network(this.art.url, height: art.height, width: art.width),
        ),
        height: art.height,
        width: art.width,
        top: 0,
        left: 0,
        scale: ratio,
        rotation: 0));
    if (art.pk.visible) {
      els.add(getPaperElement(
          child: Image(image: pkImage),
          height: art.pk.height,
          width: art.pk.width,
          top: art.pk.top,
          left: art.pk.left,
          scale: ratio,
          rotation: art.pk.rotation));
    }
    if (art.pkQr.visible) {
      els.add(getPaperElement(
          child: Image(image: pkQrImage),
          height: art.pkQr.height,
          width: art.pkQr.width,
          top: art.pkQr.top,
          left: art.pkQr.left,
          scale: ratio,
          rotation: art.pkQr.rotation));
    }
    if (art.ad.visible) {
      els.add(getPaperElement(
          child: Image(image: adImage),
          height: art.ad.height,
          width: art.ad.width,
          top: art.ad.top,
          left: art.ad.left,
          scale: ratio,
          rotation: art.ad.rotation));
    }
    if (art.adQr.visible) {
      els.add(getPaperElement(
          child: Image(image: adQrImage),
          height: art.adQr.height,
          width: art.adQr.width,
          top: art.adQr.top,
          left: art.adQr.left,
          scale: ratio,
          rotation: art.adQr.rotation));
    }
    return Container(
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.hardEdge,
        children: els,
      ),
      height: art.height * ratio,
      width: art.width * ratio,
    );
  }

  Widget getPaperElement({double top, double left, double width, double height, double rotation, Widget child, double scale}) {
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
