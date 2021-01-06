import 'dart:math' as math;
import 'dart:typed_data';
import 'art.dart';
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
    // print("Page available height: " + ppf.availableHeight.toString());
    // print("Wallet per page: " + walletspp.toString());
    // print("Num pages: " + numPages.toString());
    // print("Wallet max Height: " + wMaxH.toString());
    // print("Wallets length: " + wallets.length.toString());
    int wi = 0;
    int wl = papers.length;
    print("PRINT getBackground");
    pdfw.MemoryImage background = await getMemoryImage(papers.first.backgroundBytes);
    for (int p = 0; p < numPages; p++) {
      List<pdfw.Widget> wp = List<pdfw.Widget>.empty(growable: true);
      for (int pp = 0; pp < walletsPerPage && wi < wl; pp++) {
        print("PRINT getOverlay");
        pdfw.MemoryImage overlay = await getMemoryImage(papers[wi++].overlayBytes);
        pdfw.Widget w = await makePDFWallet(background: background, overlay: overlay, maxWidth: ppf.availableWidth, maxHeight: wMaxH);
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
    pdfw.MemoryImage background,
    pdfw.MemoryImage overlay,
    double maxWidth,
    double maxHeight,
  }) async {
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    double distancing = 4;
    // double scaleW = maxWidth / paper.width;
    // double scaleH = maxHeight / paper.height;
    // double scale = math.min(scaleW, scaleH) * 0.9;
    // print("Scales: W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());

    els.add(pdfw.Image.provider(background));
    els.add(pdfw.Image.provider(overlay));
    return pdfw.Container(
        height: maxHeight,
        width: maxWidth,
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
    // print("Image: " + image.toString());
    // print("Image disposed: " + image.debugDisposed.toString());
    // ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // print("PRINT ByteData: " + data.toString());
    // Uint8List bytes = data.buffer.asUint8List();
    print("PRINT Bytes: " + bytes.length.toString());
    return pdfw.MemoryImage(bytes);
  }

  pdfw.Widget getPDFWalletElement({ArtElement ael, double scale, pdfw.ImageProvider image}) {
    double angle = (-1 * ael.rotation / 180) * math.pi;
    return pdfw.Positioned(
      child: pdfw.Transform.rotate(
        origin: pdf.PdfPoint(0, 0),
        alignment: pdfw.Alignment.centerLeft,
        angle: angle,
        child: pdfw.Image.provider(
          image,
          height: ael.height * scale,
          width: ael.width * scale,
          fit: pdfw.BoxFit.fitWidth,
        ),
      ),
      top: ael.top * scale,
      left: ael.left * scale,
    );
  }
}
