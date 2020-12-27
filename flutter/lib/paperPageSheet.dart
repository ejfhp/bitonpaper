import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'paperPageState.dart';
import 'wallet.dart';
import 'art.dart';
import 'dart:math' as math;

class Sheet extends InheritedWidget {
  final PaperPageState state;

  Sheet({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant Sheet oldWidget) {
    return oldWidget.state.getSelectedArt() != state.getSelectedArt();
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
    var w = appState.getWallet();
    var qrPk = appState.getQrPk();
    var qrAd = appState.getQrAd();
    if (art == null || w == null || qrPk == null || qrAd == null) {
      return Text("No DATA");
    }
    Paper p = Paper(
        wallet: w, art: appState.getSelectedArt(), pkQr: qrPk, adQr: qrAd);
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black45),
        ),
        padding: EdgeInsets.all(20),
        child: p,
        alignment: Alignment.center,
      ),
    );
  }
}

class Paper extends StatelessWidget {
  final Wallet wallet;
  final Art art;
  final Uint8List pkQr;
  final Uint8List adQr;
  Paper({this.wallet, this.art, this.adQr, this.pkQr});

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
            return getPaper(
                art: art,
                wallet: wallet,
                constraint: constraint,
                adQr: this.adQr,
                pkQr: this.pkQr);
          })),
    ]);
  }

  Widget getPaper(
      {Art art,
      Wallet wallet,
      Uint8List pkQr,
      Uint8List adQr,
      BoxConstraints constraint}) {
    List<Widget> els = List<Widget>.empty(growable: true);
    ImageProvider pkQrImage = MemoryImage(pkQr);
    ImageProvider adQrImage = MemoryImage(adQr);
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
          child: Text(wallet.publicAddress,
              style: TextStyle(
                  fontSize: art.ad.size * ratio, fontFamily: "Roboto"),
              textAlign: TextAlign.left),
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
