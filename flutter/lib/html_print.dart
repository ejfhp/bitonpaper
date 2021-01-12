import 'package:flutter/material.dart';
import 'paper.dart';
import 'dart:convert' show base64;
import 'dart:html' as html;
import 'dart:async';
import 'dart:math' as math;

//A4 21x29.7
const SAFE_WIDTH = 670;
const SAFE_HEIGHT = 944;
const MARGIN = 10;

class PrintSheetHTML extends StatelessWidget {
  final List<Paper> papers;

  PrintSheetHTML(this.papers);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> preparePrintPreview(int ppp) async {
    print("HTML_PRINT preparePrintPreview");
    int numPages = (papers.length / ppp).ceil();
    int creditsHeight = 8;
    int wi = 0;
    int wl = papers.length;
    double maxPH = (SAFE_HEIGHT - creditsHeight) / ppp;
    double scaleW = SAFE_WIDTH / papers.first.width;
    double scaleH = (maxPH - MARGIN) / papers.first.height;
    double scale = math.min(scaleW, scaleH);
    int width = (papers.first.width * scale).floor();
    int height = (papers.first.height * scale).floor();
    _temporarySetBodyStyleNotPositionFixed(true);
    html.DivElement printPreview = html.DivElement();
    printPreview.style.setProperty("position", "relative");
    html.querySelector("#printpreview").children.add(printPreview);
    for (int p = 0; p < numPages; p++) {
      html.DivElement page = html.DivElement();
      page.style.setProperty("width", SAFE_WIDTH.toString() + "px");
      page.style.setProperty("min-height", SAFE_HEIGHT.toString() + "px");
      page.style.setProperty("background", "white");
      page.style.setProperty("page-break-after", "always");
      printPreview.children.add(page);
      html.HtmlElement printedWith = html.ParagraphElement();
      printedWith.style.setProperty("height", creditsHeight.toString() + "px");
      printedWith.style.setProperty("color", "black");
      printedWith.style.setProperty("font-size", "8");
      printedWith.innerText = "Printed with bop.run @boprun";
      for (int pp = 0; pp < ppp && wi < wl; pp++) {
        print("Adding wi:" + wi.toString());
        html.DivElement pDiv = await _makePaperDiv(paper: papers[wi++], width: width, height: height);
        page.insertAdjacentElement("beforeEnd", pDiv);
      }
      page.insertAdjacentElement("beforeEnd", printedWith);
    }
    //Wait a little to allow chrome on android to complete the draw
    print("HTMLPRINT waiting 500 millis... ");
    await Future.delayed(const Duration(milliseconds: 500), () {});
  }

  Future<html.DivElement> _makePaperDiv({Paper paper, int height, int width}) async {
    Completer bgdComp = Completer();
    Completer ovrComp = Completer();
    html.DivElement paperDiv = html.DivElement();
    paperDiv.style.setProperty("height", height.toString() + "px");
    paperDiv.style.setProperty("width", width.toString() + "px");
    paperDiv.style.setProperty("position", "relative");
    paperDiv.style.setProperty("margin-bottom", MARGIN.toString() + "px");
    String header = "data:image/png;base64,";
    String bEnc = base64.encode(paper.backgroundBytes);
    String bImage = header + bEnc;
    html.ImageElement bImg = html.ImageElement(src: bImage, height: height, width: width);
    bImg.onLoad.listen((event) async {
      bgdComp.complete("loaded");
    });
    bImg.style.setProperty("position", "relative");
    bImg.style.setProperty("top", "0");
    bImg.style.setProperty("left", "0");
    paperDiv.children.add(bImg);

    String oEnc = base64.encode(paper.overlayBytes);
    String oImage = header + oEnc;
    html.ImageElement oImg = html.ImageElement(src: oImage, height: height, width: width);
    oImg.onLoad.listen((event) async {
      await Future.delayed(const Duration(seconds: 1), () {});
      ovrComp.complete();
    });
    oImg.style.setProperty("position", "absolute");
    oImg.style.setProperty("top", "0");
    oImg.style.setProperty("left", "0");
    paperDiv.children.add(oImg);
    await bgdComp.future;
    await ovrComp.future;
    return paperDiv;
  }

  showPrintPreview() {
    html.window.print();
    _temporarySetBodyStyleNotPositionFixed(false);
    html.querySelector("#printpreview").children.clear();
  }

  void _temporarySetBodyStyleNotPositionFixed(bool removePosition) {
    html.HtmlDocument doc = html.window.document as html.HtmlDocument;
    if (removePosition) {
      print("HTMLPRINT remove BODY style psition fixed!");
      doc.body.style.removeProperty("position");
    } else {
      print("HTMLPRINT set BODY style psition fixed!");
      doc.body.style.setProperty("position", "fixed");
    }
  }
}
