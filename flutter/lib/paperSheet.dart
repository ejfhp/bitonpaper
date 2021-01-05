import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'BOPState.dart';
// import 'wallet.dart';
// import 'art.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
// import 'walletPainter.dart';

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
    Map<String, ui.Image> papers = appState.getPapers();
    print("Papers Lenght: " + papers.length.toString());
    if (papers.length < 1) {
      return Container(
        alignment: Alignment.center,
        child: Text("Loading..."),
      );
    }
    var pageSize = MediaQuery.of(context).size;
    Paper p = Paper(
      papers: papers,
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
  final Map<String, ui.Image> papers;
  final double maxWidth;

  Paper({this.papers, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    // double scale = this.maxWidth / art.width;
    // if (scale > 1) {
    //   scale = 1;
    // }
    return Container(
      child: LayoutBuilder(builder: (context, constraint) {
        return getSheet(papers: papers, constraint: constraint);
      }),
    );
  }

  Widget getSheet({Map<String, ui.Image> papers, BoxConstraints constraint}) {
    List<Widget> ww = List<Widget>.empty(growable: true);
    papers.forEach((privKey, paper) {
      ww.add(Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: prepareArt(paper: paper, constraint: constraint),
      ));
    });
    return Column(
      children: ww,
    );
  }

  Widget prepareArt({ui.Image paper, BoxConstraints constraint}) {
    print("Art Max Width: " + constraint.maxWidth.toString());
    // double ratio = constraint.maxWidth / art.width;
    return Container(
      child: RawImage(image: paper),
    );
  }

  // Widget prepareArt({Art art, Wallet wallet, BoxConstraints constraint}) {
  //   print("Art Max Width: " + constraint.maxWidth.toString());
  //   List<Widget> els = List<Widget>.empty(growable: true);
  //   ImageProvider pkQrImage = MemoryImage(wallet.pkQr);
  //   ImageProvider adQrImage = MemoryImage(wallet.adQr);
  //   ImageProvider pkImage = MemoryImage(wallet.pkImg);
  //   ImageProvider adImage = MemoryImage(wallet.adImg);
  //   double ratio = constraint.maxWidth / art.width;
  //   els.add(getPaperElement(
  //       child: Container(
  //         child: RawImage(image: this.art.image, height: art.height, width: art.width),
  //       ),
  //       height: art.height,
  //       width: art.width,
  //       top: 0,
  //       left: 0,
  //       scale: ratio,
  //       rotation: 0));
  //   if (art.pk.visible) {
  //     els.add(getPaperElement(
  //         child: Image(image: pkImage),
  //         height: art.pk.height,
  //         width: art.pk.width,
  //         top: art.pk.top,
  //         left: art.pk.left,
  //         scale: ratio,
  //         rotation: art.pk.rotation));
  //   }
  //   if (art.pkQr.visible) {
  //     els.add(getPaperElement(
  //         child: Image(image: pkQrImage),
  //         height: art.pkQr.height,
  //         width: art.pkQr.width,
  //         top: art.pkQr.top,
  //         left: art.pkQr.left,
  //         scale: ratio,
  //         rotation: art.pkQr.rotation));
  //   }
  //   if (art.ad.visible) {
  //     els.add(getPaperElement(
  //         child: Image(image: adImage),
  //         height: art.ad.height,
  //         width: art.ad.width,
  //         top: art.ad.top,
  //         left: art.ad.left,
  //         scale: ratio,
  //         rotation: art.ad.rotation));
  //   }
  //   if (art.adQr.visible) {
  //     els.add(getPaperElement(
  //         child: Image(image: adQrImage),
  //         height: art.adQr.height,
  //         width: art.adQr.width,
  //         top: art.adQr.top,
  //         left: art.adQr.left,
  //         scale: ratio,
  //         rotation: art.adQr.rotation));
  //   }
  //   return Container(
  //     child: Stack(
  //       fit: StackFit.passthrough,
  //       clipBehavior: Clip.hardEdge,
  //       children: els,
  //     ),
  //     height: art.height * ratio,
  //     width: art.width * ratio,
  //   );
  // }

  // Widget getPaperElement({double top, double left, double width, double height, double rotation, Widget child, double scale}) {
  //   double angle = (rotation / 180) * math.pi;
  //   return Positioned(
  //     child: Transform.rotate(
  //       origin: Offset(0, 0),
  //       alignment: Alignment.centerLeft,
  //       angle: angle,
  //       child: child,
  //     ),
  //     top: top * scale,
  //     left: left * scale,
  //     width: width * scale,
  //     height: height * scale,
  //   );
  // }
}
