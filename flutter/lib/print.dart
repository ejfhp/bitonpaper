import 'dart:math' as math;
import 'dart:typed_data';
import 'paper.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;

class PDFGenerator {
  Future<Uint8List> toPDF({List<Paper> papers, int walletsPerPage}) async {
    assert(papers != null);
    assert(papers.length > 0);
    print("PRINT toPDF: " + DateTime.now().toUtc().toIso8601String());
    final doc = pdfw.Document();
    pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;
    double wMaxH = (ppf.availableHeight / walletsPerPage);
    int numPages = (papers.length / walletsPerPage).ceil();
    int wi = 0;
    int wl = papers.length;
    for (int p = 0; p < numPages; p++) {
      List<pdfw.Widget> wp = List<pdfw.Widget>.empty(growable: true);
      for (int pp = 0; pp < walletsPerPage && wi < wl; pp++) {
        pdfw.Widget w = await makePDFWallet(paper: papers[wi++], maxWidth: ppf.availableWidth, maxHeight: wMaxH);
        wp.add(w);
      }
      doc.addPage(
        pdfw.Page(
          pageFormat: ppf,
          build: (context) {
            return pdfw.Column(children: wp);
          },
        ),
      );
    }
    print("PRINT doc.save: " + DateTime.now().toUtc().toIso8601String());
    return doc.save();
  }

  Future<pdfw.Widget> makePDFWallet({
    Paper paper,
    double maxWidth,
    double maxHeight,
  }) async {
    assert(paper != null);
    pdfw.MemoryImage background = await getMemoryImage(paper.backgroundBytes);
    pdfw.MemoryImage overlay = await getMemoryImage(paper.overlayBytes);
    double distancing = 4;
    double scaleW = maxWidth / paper.width;
    double scaleH = maxHeight / paper.height;
    double scale = math.min(scaleW, scaleH) * 0.9;
    double w = paper.width * scale;
    double h = paper.height * scale;
    print("Scales: W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());

    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    els.add(pdfw.Image.provider(background));
    els.add(pdfw.Image.provider(overlay));
    return pdfw.Container(
        height: h,
        width: w,
        decoration: pdfw.BoxDecoration(
          border: pdfw.Border.all(width: 1, color: pdf.PdfColors.grey400),
        ),
        padding: pdfw.EdgeInsets.all(distancing),
        child: pdfw.Stack(
          children: els,
          fit: pdfw.StackFit.expand,
        ));
  }

  Future<pdfw.MemoryImage> getMemoryImage(Uint8List bytes) async {
    print("PRINT Bytes: " + bytes.length.toString());
    return pdfw.MemoryImage(bytes);
  }
}
