import 'dart:html';

import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'paper.dart';

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
    List<Paper> papers = appState.getPapers();
    print("PAPERSHEET Papers Lenght: " + papers.length.toString());
    if (papers.length < 1) {
      return Container(
        alignment: Alignment.center,
        child: Text("Loading..."),
      );
    }
    var pageSize = MediaQuery.of(context).size;
    PaperView p = PaperView(
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

class PaperView extends StatelessWidget {
  final List<Paper> papers;
  final double maxWidth;

  PaperView({this.papers, this.maxWidth});

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

  Widget getSheet({List<Paper> papers, BoxConstraints constraint}) {
    List<Widget> ww = List<Widget>.empty(growable: true);
    papers.forEach((paper) {
      ww.add(Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: prepareArt(paper: paper, constraint: constraint),
      ));
    });
    return Column(
      children: ww,
    );
  }

  Widget prepareArt({Paper paper, BoxConstraints constraint}) {
    print("PAPERSHEET Art Max Width: " + constraint.maxWidth.toString());
    ImageProvider bip = MemoryImage(paper.backgroundData.buffer);
    ImageProvider oip = MemoryImage(paper.overlayData.buffer.asUint8List());
    // double ratio = constraint.maxWidth / art.width;
    return Container(
        child: Stack(
      children: [
        Positioned(
          child: Image(image: bip),
        ),
        Positioned(
          child: Image(image: oip),
        )
      ],
    ));
  }
}
