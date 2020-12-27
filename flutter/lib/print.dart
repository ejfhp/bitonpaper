import 'dart:typed_data';
import 'dart:math' as math;
import 'art.dart';
import 'wallet.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';



Future<void> toPDF(
    {Art art, Map<String, Uint8List> qrs, List<Wallet> wallets}) async {
  try {
    final doc = pw.Document();
    pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;
    print("Avaiable Width: " + ppf.availableWidth.toString());
    print("Avaiable Height: " + ppf.availableHeight.toString());
    List<pw.Widget> parts = List<pw.Widget>.empty(growable: true);
    for (int i = 0; i < wallets.length; i++) {
      Wallet w = wallets[i];
      pw.Widget part = await makePDFWallet(
          art: art,
          wallet: w,
          maxWidth: ppf.availableWidth,
          qrAd: qrs[w.publicAddress],
          qrPk: qrs[w.privateKey]);
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

Future<pw.Widget> makePDFWallet(
    {Art art,
    Wallet wallet,
    double maxWidth,
    Uint8List qrPk,
    Uint8List qrAd}) async {
  List<pw.Widget> els = List<pw.Widget>.empty(growable: true);

  double scale = (maxWidth - 0.5) / art.width;
  print("Scale: " + scale.toString());

  NetworkImage artImage = NetworkImage(art.url);
  final artImageProvider = await flutterImageProvider(artImage);

  ImageProvider pkQrImage = MemoryImage(qrPk);
  final pkQrImageProvider = await flutterImageProvider(pkQrImage);

  ImageProvider adQrImage = MemoryImage(qrAd);
  final adQrImageProvider = await flutterImageProvider(adQrImage);
  els.add(pw.Image.provider(
    artImageProvider,
    height: art.height * scale,
    width: art.width * scale,
    fit: pw.BoxFit.fitWidth,
  ));
  if (art.pk.visible) {
    els.add(getPDFWalletElement(
        child: pw.Text(wallet.privateKey,
            style: pw.TextStyle(fontSize: art.pk.size * scale),
            textAlign: pw.TextAlign.left),
        top: art.pk.top * scale,
        left: art.pk.left * scale,
        rotation: -1 * art.pk.rotation));
  }
  if (art.pkQr.visible) {
    els.add(getPDFWalletElement(
        child: pw.Image.provider(
          pkQrImageProvider,
          height: art.pkQr.height * scale,
          width: art.pkQr.width * scale,
          fit: pw.BoxFit.fitWidth,
        ),
        top: art.pkQr.top * scale,
        left: art.pkQr.left * scale,
        rotation: art.pkQr.rotation));
  }
  if (art.ad.visible) {
    els.add(getPDFWalletElement(
        child: pw.Text(
          wallet.publicAddress,
          style: pw.TextStyle(fontSize: art.ad.size * scale),
          textAlign: pw.TextAlign.left,
        ),
        top: art.ad.top * scale,
        left: art.ad.left * scale,
        rotation: -1 * art.ad.rotation));
  }
  if (art.adQr.visible) {
    els.add(getPDFWalletElement(
        child: pw.Image.provider(
          adQrImageProvider,
          height: art.adQr.height * scale,
          width: art.adQr.width * scale,
          fit: pw.BoxFit.fitWidth,
        ),
        top: art.adQr.top * scale,
        left: art.adQr.left * scale,
        rotation: art.adQr.rotation));
  }
  return pw.Stack(
    children: els,
    fit: pw.StackFit.expand,
  );
  // return els.last;
}

pw.Widget getPDFWalletElement(
    {double top, double left, double rotation, pw.Widget child}) {
  double angle = (rotation / 180) * math.pi;
  return pw.Positioned(
    child: pw.Transform.rotate(
      origin: pdf.PdfPoint(0, 0),
      alignment: pw.Alignment.centerLeft,
      angle: angle,
      child: child,
    ),
    top: top,
    left: left,
  );
}

// Future<Uint8List> createImageFromText(context) async {
//   im.Image image = im.Image.rgb(40, 100);
//   // im.fill(image, im.getColor(0, 0, 0));
//   // im.drawString(image, im.arial_14, 0, 0, 'A');
//   // im.drawLine(image, 0, 0, 320, 240, im.getColor(255, 0, 0, 255), thickness: 3);
//   im.gaussianBlur(image, 10);
//   Uint8List bytes = image.getBytes();

//   print("Bytes len: " + bytes.length.toString());
//   MemoryImage memImg = MemoryImage(bytes);
//   print("Memory Image: " + memImg.toString());
//   await precacheImage(memImg, context, onError: (o, e) {
//     print("Precache error: " + o.toString());
//     print(e);
//     print(o);
//     });
//   return bytes;
// }
