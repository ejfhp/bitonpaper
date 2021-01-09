import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'paper.dart';
import 'dart:convert' show base64;
import 'dart:html' as html;
import 'dart:math' as math;

//A4 21x29.7
const SAFE_WIDTH = 670;
const SAFE_HEIGHT = 944;
const MARGIN = 10;

class PrintSheet extends StatelessWidget {
  final BOPState state;

  PrintSheet(this.state);

  @override
  Widget build(BuildContext context) {
    // return SizedBox(
    //   height: 4000,
    //   width: 100000,
    //   child: Container(
    //     child: getSheet(papers: papers),
    //     alignment: Alignment.center,
    //   ),
    // );
    return Container();
  }

//https://stackoverflow.com/questions/16649943/css-to-set-a4-paper-size
  preparePrintPreview(int ppp) {
    html.querySelector("#printpreview").children.clear();
    List<Paper> papers = state.getPapers();
    int numPages = (papers.length / ppp).ceil();
    int wi = 0;
    int wl = papers.length;
    double maxPH = SAFE_HEIGHT / ppp;
    double scaleW = SAFE_WIDTH / papers.first.width;
    double scaleH = maxPH / (papers.first.height + MARGIN);
    double scale = math.min(scaleW, scaleH) * 0.9;
    int width = (papers.first.width * scale).floor();
    int height = (papers.first.height * scale).floor();
    print("HTML_PRINT printing page: v02");
    html.DivElement printPreview = html.DivElement();
    printPreview.style.setProperty("overflow-y", "visible");
    printPreview.style.setProperty("overflow-x", "visible");
    for (int p = 0; p < numPages; p++) {
      html.DivElement page = html.DivElement();
      page.style.setProperty("width", SAFE_WIDTH.toString() + "px");
      page.style.setProperty("page-break-after", "always");
      page.style.setProperty("overflow-y", "visible");
      page.style.setProperty("overflow-x", "visible");
      // page.style.setProperty("min-height", SAFE_HEIGHT.toString() + "px");
      page.style.setProperty("min-height", "29.7cm");
      page.style.setProperty("background", "white");
      for (int pp = 0; pp < ppp && wi < wl; pp++) {
        print("Adding wi:" + wi.toString());
        html.DivElement pDiv = makePaperDiv(paper: papers[wi++], width: width, height: height);
        page.insertAdjacentElement("beforeEnd", pDiv);
      }
      printPreview.insertAdjacentElement("beforeEnd", page);
    }
    html.querySelector("#printpreview").children.add(printPreview);
  }

  html.DivElement makePaperDiv({Paper paper, int height, int width}) {
    html.DivElement paperDiv = html.DivElement();
    paperDiv.style.setProperty("height", height.toString() + "px");
    paperDiv.style.setProperty("width", width.toString() + "px");
    paperDiv.style.setProperty("position", "relative");
    paperDiv.style.setProperty("margin", "10px");
    String header = "data:image/png;base64,";
    String bEnc = base64.encode(paper.backgroundBytes);
    String bImage = header + bEnc;
    html.ImageElement bImg = html.ImageElement(src: bImage, height: height, width: width);
    bImg.style.setProperty("position", "relative");
    bImg.style.setProperty("top", "0");
    bImg.style.setProperty("left", "0");
    paperDiv.children.add(bImg);

    String oEnc = base64.encode(paper.overlayBytes);
    String oImage = header + oEnc;
    html.ImageElement oImg = html.ImageElement(src: oImage, height: height, width: width);
    oImg.style.setProperty("position", "absolute");
    oImg.style.setProperty("top", "0");
    oImg.style.setProperty("left", "0");
    paperDiv.children.add(oImg);
    return paperDiv;
  }

  showPrintPreview() {
    html.window.print();
    // html.querySelector("printpreview").children.clear();
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
