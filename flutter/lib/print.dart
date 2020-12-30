import 'dart:typed_data';
import 'dart:math' as math;
import 'art.dart';
import 'wallet.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator {
  static Future<void> toPDF({Art art, List<Wallet> wallets}) async {
    try {
      final doc = pw.Document();
      pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;
      List<pw.Widget> parts = List<pw.Widget>.empty(growable: true);
      for (int i = 0; i < wallets.length; i++) {
        Wallet w = wallets[i];
        pw.Widget part = await makePDFWallet(art: art, wallet: w, maxWidth: ppf.availableWidth);
        parts.add(part);
      }
      doc.addPage(
        pw.Page(
          pageFormat: ppf,
          build: (context) {
            return pw.Column(children: parts);
          },
        ),
      );
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
    } catch (e) {
      print(e);
    }
  }

  Future<pw.Widget> makePDFWallet({
    Art art,
    Wallet wallet,
    double maxWidth,
  }) async {
    List<pw.Widget> els = List<pw.Widget>.empty(growable: true);

    double scale = (maxWidth - 0.5) / art.width;
    print("Scale: " + scale.toString());

    NetworkImage artImage = NetworkImage(art.url);
    final artImageProvider = await flutterImageProvider(artImage);

    ImageProvider pkQrImage = MemoryImage(wallet.pkQr);
    final pkQrImageProvider = await flutterImageProvider(pkQrImage);
    ImageProvider adQrImage = MemoryImage(wallet.adQr);
    final adQrImageProvider = await flutterImageProvider(adQrImage);
    ImageProvider pkImage = MemoryImage(wallet.pkImg);
    final pkImageProvider = await flutterImageProvider(pkImage);
    ImageProvider adImage = MemoryImage(wallet.adImg);
    final adImageProvider = await flutterImageProvider(adImage);
    els.add(pw.Image.provider(
      artImageProvider,
      height: art.height * scale,
      width: art.width * scale,
      fit: pw.BoxFit.fitWidth,
    ));
    if (art.pk.visible) {
      els.add(getPDFWalletElement(
        image: pkImageProvider,
        ael: art.pk,
        scale: scale,
      ));
    }
    if (art.pkQr.visible) {
      els.add(getPDFWalletElement(
        image: pkQrImageProvider,
        ael: art.pkQr,
        scale: scale,
      ));
    }
    if (art.ad.visible) {
      els.add(getPDFWalletElement(
        image: adImageProvider,
        ael: art.ad,
        scale: scale,
      ));
    }
    if (art.adQr.visible) {
      els.add(getPDFWalletElement(
        image: adQrImageProvider,
        ael: art.adQr,
        scale: scale,
      ));
    }
    return pw.Stack(
      children: els,
      fit: pw.StackFit.expand,
    );
    // return els.last;
  }

  pw.Widget getPDFWalletElement({ArtElement ael, double scale, pw.ImageProvider image}) {
    double angle = (-1 * ael.rotation / 180) * math.pi;
    return pw.Positioned(
      child: pw.Transform.rotate(
        origin: pdf.PdfPoint(0, 0),
        alignment: pw.Alignment.centerLeft,
        angle: angle,
        child: pw.Image.provider(
          image,
          height: ael.height * scale,
          width: ael.width * scale,
          fit: pw.BoxFit.fitWidth,
        ),
      ),
      top: ael.top * scale,
      left: ael.left * scale,
    );
  }
}
