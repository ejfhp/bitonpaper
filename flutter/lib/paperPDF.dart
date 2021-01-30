import 'dart:math' as math;
import 'dart:typed_data';
import 'paper.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;
import 'dart:convert' show base64;
import 'package:printing/printing.dart';

//A4 21x29.7
const SAFE_WIDTH = 670;
const SAFE_HEIGHT = 944;
const MARGIN = 10;

class PaperPrintSet {
  final int walletPerPage;
  final List<Paper> papers;
  PaperPrintSet({this.papers, this.walletPerPage});

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
    List<Paper> papers = this.papers;
    int walletsPerPage = this.walletPerPage;
    assert(papers != null);
    final doc = pdfw.Document();
    double maxPH = (format.availableHeight / walletsPerPage);
    int numPages = (papers.length / walletsPerPage).ceil();
    int wi = 0;
    int wl = papers.length;
    double scaleW = format.availableWidth / papers.first.width;
    double scaleH = maxPH / papers.first.height;
    double scale = math.min(scaleW, scaleH) * 0.9;
    double width = papers.first.width * scale;
    double height = papers.first.height * scale;
    print("PDFGENERATOR Scale - W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());
    print("PDFGENERATOR Wallet size - w:" + width.toString() + " h:" + height.toString());
    for (int p = 0; p < numPages; p++) {
      List<pdfw.Widget> wp = List<pdfw.Widget>.empty(growable: true);
      for (int pp = 0; pp < walletsPerPage && wi < wl; pp++) {
        pdfw.Widget w = _generateWallet(paper: papers[wi++], width: width, height: height);
        wp.add(w);
      }
      wp.add(pdfw.Container(
          height: 10,
          child: pdfw.Text(
            "Printed with bop.run ",
            style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, color: pdf.PdfColors.grey700, fontSize: 5),
          )));
      doc.addPage(
        pdfw.Page(
          pageFormat: format,
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
    }
    return await doc.save();
  }

  pdfw.Widget _generateWallet({
    Paper paper,
    double width,
    double height,
  }) {
    assert(paper != null);
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    els.add(pdfw.Image(pdfw.MemoryImage(paper.backgroundBytes)));
    els.add(pdfw.Image(pdfw.MemoryImage(paper.overlayBytes)));
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

  String _prepareHTML() {
    print("HTML_PRINT preparePrintPreview");
    int numPages = (this.papers.length / this.walletPerPage).ceil();
    int creditsHeight = 8;
    int wi = 0;
    int wl = this.papers.length;
    double maxPH = (SAFE_HEIGHT - creditsHeight) / this.walletPerPage;
    double scaleW = SAFE_WIDTH / this.papers.first.width;
    double scaleH = (maxPH - MARGIN) / this.papers.first.height;
    double scale = math.min(scaleW, scaleH);
    int width = (this.papers.first.width * scale).floor();
    int height = (this.papers.first.height * scale).floor();
    String sh = SAFE_HEIGHT.toString() + "px";
    String sw = SAFE_WIDTH.toString() + "px";
    String html = "<div style=\"position: relative;\">";
    for (int p = 0; p < numPages; p++) {
      html += "<div style=\"width: $sw; min-height: $sh; background: white; break-after: page;\">";
      for (int pp = 0; pp < this.walletPerPage && wi < wl; pp++) {
        print("Adding wi:" + wi.toString());
        html += _makePaperDiv(paper: this.papers[wi++], width: width, height: height);
      }
      html += "<p style=\"height: 8px; color: black;\">Printed with bop.run @boprun</p>";
      html += "</div>";
    }
    html += "</div>";
    return html;
  }

  String _makePaperDiv({Paper paper, int height, int width}) {
    String w = width.toString() + "px";
    String h = height.toString() + "px";
    String m = MARGIN.toString() + "px";
    String bEnc = base64.encode(paper.backgroundBytes);
    String oEnc = base64.encode(paper.overlayBytes);
    String div = "<div style=\"height: $h; width: $w; position: relative; margin-bottom:  $m;\"> " +
        "<img src=\"data:image/png;base64,$bEnc\" height=\"$h\" width=\"$w\" style=\"position: relative; top: 0px; left: 0px;\">" +
        "<img src=\"data:image/png;base64,$oEnc\" height=\"$h\" width=\"$w\" style=\"position: relative; top: 0px; left: 0px;\">" +
        "</div>";
    return div;
  }
}
