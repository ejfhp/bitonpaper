import 'dart:math' as math;
import 'dart:typed_data';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;
import 'package:printing/printing.dart';
import 'package:bitonpaper/papers.dart';
import 'package:bitonpaper/wallets.dart';

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

    // await Printing.layoutPdf(
    //     onLayout: (pdf.PdfPageFormat format) async => await Printing.convertHtml(
    //           format: format,
    //           html: pdfConf.prepareHTML(),
    //         ));
  }

  Future<Uint8List> _printPDFA4() async {
    return await _printPDF(pdf.PdfPageFormat.a4);
  }

  Future<Uint8List> _printPDF(pdf.PdfPageFormat format) async {
    assert(papers != null);
    final doc = pdfw.Document();
    double maxPH = format.availableHeight;
    // int wi = 0;
    // int wl = papers.length;
    Iterator<Wallet> walletIterator = this.papers.iterator;
    double heightUsed = 0;
    List<pdfw.Widget> pageWidgets = List<pdfw.Widget>.empty(growable: true);
    while (walletIterator.moveNext()) {
      Paper paper = await this.papers.getPaper(wallet: walletIterator.current);
      double scaleW = format.availableWidth / paper.width;
      double scaleH = maxPH / paper.height;
      double scale = math.min(scaleW, scaleH) * 0.9;
      double width = paper.width * scale;
      double height = paper.height * scale;
      // print("PDFGENERATOR Scale - W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());
      // print("PDFGENERATOR Wallet size - w:" + width.toString() + " h:" + height.toString());
      pdfw.Widget w = _generateWallet(paper: paper, width: width, height: height);
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
    return await doc.save();
  }

  pdfw.Widget _generateWallet({
    Paper paper,
    double width,
    double height,
  }) {
    assert(paper != null);
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    els.add(pdfw.Image(pdfw.MemoryImage(paper.art.bytes)));
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
