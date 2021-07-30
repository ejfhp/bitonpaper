import 'dart:math' as math;
import 'dart:typed_data';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;
import 'package:printing/printing.dart';
import 'package:bop/graphic/papers.dart';

//A4 21x29.7
const SAFE_WIDTH = 670;
const SAFE_HEIGHT = 944;
const MARGIN = 10;

class PaperPrintSet {
  final Papers papers;
  PaperPrintSet({this.papers});

  downloadPages() async {
    await Printing.sharePdf(bytes: await this._printPDFA4(), filename: 'bop_wallets.pdf');
  }

  printPages() async {
    await Printing.layoutPdf(onLayout: this._printPDF);
  }

  Future<Uint8List> _printPDFA4() async {
    return await _printPDF(pdf.PdfPageFormat.a4);
  }

  Future<Uint8List> _printPDF(pdf.PdfPageFormat format) async {
    assert(papers != null);
    try {
      final doc = pdfw.Document();
      double maxPH = format.availableHeight;
      print("PaperPrintSet._printPDF 1");
      double heightUsed = 0;
      List<pdfw.Widget> pageWidgets = List<pdfw.Widget>.empty(growable: true);
      for (int i = 0; i < this.papers.length; i++) {
        Paper paper = this.papers.getPaperAt(i);
        print("PaperPrintSet._printPDF 2 " + paper.wallet.publicAddress);
        double scaleW = format.availableWidth / paper.art.width;
        double scaleH = maxPH / paper.art.height;
        double scale = math.min(scaleW, scaleH) * 0.9;
        double width = paper.art.width * scale;
        double height = paper.art.height * scale;
        print("PaperPrintSet._printPDF 3");
        pdfw.Widget w = _generateWallet(paper: paper, width: width, height: height);
        print("PaperPrintSet._printPDF 4");
        if ((heightUsed + height) < maxPH) {
          print("adding widget heightUsed:" + heightUsed.toString() + " maxPH: " + maxPH.toString() + " height:" + height.toString());
          pageWidgets.add(w);
          heightUsed += height;
        } else {
          print("adding page to doc heightUsed:" + heightUsed.toString() + " maxPH: " + maxPH.toString() + " height:" + height.toString());
          List<pdfw.Widget> ws = List<pdfw.Widget>.from(pageWidgets);
          doc.addPage(
            pdfw.Page(
              pageFormat: format,
              build: (context) {
                return pdfw.Column(
                  children: ws,
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  mainAxisSize: pdfw.MainAxisSize.max,
                  crossAxisAlignment: pdfw.CrossAxisAlignment.center,
                );
              },
            ),
          );
          print("PaperPrintSet._printPDF 5");
          pageWidgets.clear();
          pageWidgets.add(w);
          heightUsed = height;
        }
      }
      print("adding last page to doc");
      doc.addPage(
        pdfw.Page(
          pageFormat: format,
          build: (context) {
            return pdfw.Column(
              children: pageWidgets,
              mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
              mainAxisSize: pdfw.MainAxisSize.max,
              crossAxisAlignment: pdfw.CrossAxisAlignment.center,
            );
          },
        ),
      );
      print("PaperPrintSet._printPDF 6");
      return await doc.save();
    } catch (e) {
      print("PaperPrintSet._printPDF exception $e");
    }
  }

  pdfw.Widget _generateWallet({
    Paper paper,
    double width,
    double height,
  }) {
    assert(paper != null);
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    els.add(pdfw.Image(pdfw.MemoryImage(paper.art.template)));
    els.add(pdfw.Image(pdfw.MemoryImage(paper.overlayBytes)));
    return pdfw.Container(
        height: height,
        width: width,
        alignment: pdfw.Alignment.center,
        padding: pdfw.EdgeInsets.fromLTRB(0, 3, 0, 3),
        decoration: pdfw.BoxDecoration(
          border: pdfw.Border.all(width: 1, color: pdf.PdfColors.grey400),
        ),
        child: pdfw.Stack(
          children: els,
          fit: pdfw.StackFit.expand,
        ));
  }
}
