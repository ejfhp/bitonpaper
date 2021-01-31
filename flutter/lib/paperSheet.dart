import 'package:flutter/material.dart';
import 'paper.dart';

class PaperSheetInh extends InheritedWidget {
  final List<Paper> papers;

  PaperSheetInh({Widget child, this.papers}) : super(child: child);

  @override
  bool updateShouldNotify(covariant PaperSheetInh oldWidget) {
    return oldWidget.papers != papers;
  }

  static PaperSheetInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PaperSheetInh>();
  }
}

class PaperSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Paper> papers = PaperSheetInh.of(context).papers;
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
        child: p,
        alignment: Alignment.topCenter,
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
        margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: prepareArt(paper: paper, constraint: constraint),
      ));
    });
    return Column(
      children: ww,
    );
  }

  Widget prepareArt({Paper paper, BoxConstraints constraint}) {
    assert(paper.backgroundBytes != null);
    assert(paper.overlayBytes != null);
    ImageProvider bip = MemoryImage(paper.backgroundBytes);
    ImageProvider oip = MemoryImage(paper.overlayBytes);
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
