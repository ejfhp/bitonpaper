import 'dart:math' as math;
import 'dart:typed_data';
import 'art.dart';
import 'wallet.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pdfw;

class PDFGenerator {
  static Future<Uint8List> toPDF({Art art, List<Wallet> wallets, int walletspp}) async {
    print("toPDF: " + DateTime.now().toUtc().toIso8601String());
    final doc = pdfw.Document();
    pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;

    double wMaxH = (ppf.availableHeight / walletspp);
    int numPages = (wallets.length / walletspp).ceil();
    // print("Page available height: " + ppf.availableHeight.toString());
    // print("Wallet per page: " + walletspp.toString());
    // print("Num pages: " + numPages.toString());
    // print("Wallet max Height: " + wMaxH.toString());
    // print("Wallets length: " + wallets.length.toString());
    int wi = 0;
    int wl = wallets.length;
    for (int p = 0; p < numPages; p++) {
      List<pdfw.Widget> wp = List<pdfw.Widget>.empty(growable: true);
      for (int pp = 0; pp < walletspp && wi < wl; pp++) {
        pdfw.Widget w = await makePDFWallet(art: art, wallet: wallets[wi++], maxWidth: ppf.availableWidth, maxHeight: wMaxH);
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
    print("doc.save: " + DateTime.now().toUtc().toIso8601String());
    return doc.save();
  }

  static Future<pdfw.Widget> makePDFWallet({
    Art art,
    Wallet wallet,
    double maxWidth,
    double maxHeight,
  }) async {
    List<pdfw.Widget> els = List<pdfw.Widget>.empty(growable: true);
    double distancing = 4;
    double scaleW = maxWidth / art.width;
    double scaleH = maxHeight / art.height;
    double scale = math.min(scaleW, scaleH) * 0.9;
    // print("Scales: W:" + scaleW.toString() + " H:" + scaleH.toString() + " S:" + scale.toString());

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
    els.add(pdfw.Image.provider(
      artImageProvider,
      height: art.height * scale,
      width: art.width * scale,
      fit: pdfw.BoxFit.fitWidth,
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
    return pdfw.Container(
        decoration: pdfw.BoxDecoration(
          border: pdfw.Border.all(width: 1, color: pdf.PdfColors.grey400),
        ),
        padding: pdfw.EdgeInsets.all(distancing),
        child: pdfw.Stack(
          children: els,
          fit: pdfw.StackFit.expand,
        ));
  }

  static pdfw.Widget getPDFWalletElement({ArtElement ael, double scale, pdfw.ImageProvider image}) {
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
