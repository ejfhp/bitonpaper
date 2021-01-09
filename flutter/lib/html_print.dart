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
      width: 100000,
      child: Container(
        child: getSheet(papers: papers),
        alignment: Alignment.center,
      ),
    );
  }

//https://stackoverflow.com/questions/16649943/css-to-set-a4-paper-size
  showPrintPreview() {
    print("HTML_PRINT printing page: v01");
    window.resizeTo(1000, 4000);
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
        height: paper.height.toDouble(),
        width: paper.width.toDouble(),
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
