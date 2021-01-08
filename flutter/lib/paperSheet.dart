import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'paper.dart';

class PaperSheetInh extends InheritedWidget {
  final BOPState state;

  PaperSheetInh({Key key, Widget child, this.state}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant PaperSheetInh oldWidget) {
    return oldWidget.state.getSelectedArt() != state.getSelectedArt() || oldWidget.state.getPapers().length != state.getPapers().length;
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
        alignment: Alignment.center,
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
