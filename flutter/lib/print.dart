import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import 'paper.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;

class PDFGenerator {
  Future<Uint8List> toPDF({List<Paper> papers, int walletsPerPage}) async {
    assert(papers != null);
    assert(papers.length > 0);
    final doc = pdfw.Document();
    pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;
    double maxPH = (ppf.availableHeight / walletsPerPage);
    int numPages = (papers.length / walletsPerPage).ceil();
    int wi = 0;
    int wl = papers.length;
    double scaleW = ppf.availableWidth / papers.first.width;
    double scaleH = maxPH / papers.first.height;
    double scale = math.min(scaleW, scaleH) * 0.9;
    double width = papers.first.width * scale;
    double height = papers.first.height * scale;
    print("PDFGENERATOR Scale - W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());
    print("PDFGENERATOR Wallet size - w:" + width.toString() + " h:" + height.toString());
    for (int p = 0; p < numPages; p++) {
      List<pdfw.Widget> wp = List<pdfw.Widget>.empty(growable: true);
      for (int pp = 0; pp < walletsPerPage && wi < wl; pp++) {
        int s = DateTime.now().millisecondsSinceEpoch;
        pdfw.Widget w = await makePDFWallet(paper: papers[wi++], width: width, height: height);
        print("PRINT PDF wallet done in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
        wp.add(w);
      }
      wp.add(pdfw.Container(
          height: 10,
          child: pdfw.Text(
            "Printed with bop.run ",
            style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, color: pdf.PdfColors.grey700, fontSize: 5),
          )));
      int s = DateTime.now().millisecondsSinceEpoch;
      doc.addPage(
        pdfw.Page(
          pageFormat: ppf,
          build: (context) {
            return pdfw.Column(
              children: wp,
              mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
              mainAxisSize: pdfw.MainAxisSize.max,
              crossAxisAlignment: pdfw.CrossAxisAlignment.center,
            );
          },
        ),
      );
      print("PRINT PDF page added in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    }
    int s = DateTime.now().millisecondsSinceEpoch;
    Uint8List pdfBytes = doc.save();
    print("PRINT PDF saved to bytes in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    return pdfBytes;
  }

  Future<pdfw.Widget> makePDFWallet({
    Paper paper,
    double width,
    double height,
  }) async {
    assert(paper != null);
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    els.add(pdfw.Image.provider(pdfw.MemoryImage(paper.backgroundBytes)));
    els.add(pdfw.Image.provider(pdfw.MemoryImage(paper.overlayBytes)));
    return pdfw.Container(
        height: height,
        width: width,
        decoration: pdfw.BoxDecoration(
          border: pdfw.Border.all(width: 1, color: pdf.PdfColors.grey400),
        ),
        child: pdfw.Stack(
          children: els,
          fit: pdfw.StackFit.expand,
        ));
  }
}
