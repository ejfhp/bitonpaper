import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'paper.dart';
import 'dart:html';

class PrintSheet extends StatelessWidget {
  final BOPState state;

  PrintSheet(this.state);

  @override
  Widget build(BuildContext context) {
    List<Paper> papers = state.getPapers();
    var pageSize = MediaQuery.of(context).size;
    return SizedBox(
      height: 4000,
      width: 1000,
      child: Container(
        child: getSheet(papers: papers),
        alignment: Alignment.center,
      ),
    );
  }

  showPrintPreview() {
    print("HTML_PRINT printing page");
    window.print();
  }

  Widget getSheet({List<Paper> papers}) {
    List<Widget> ww = List<Widget>.empty(growable: true);
    papers.forEach((paper) {
      ww.add(Container(
        margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: prepareArt(
          paper: paper,
        ),
      ));
    });
    return Column(
      children: ww,
    );
  }

  Widget prepareArt({Paper paper}) {
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
