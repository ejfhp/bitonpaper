import 'dart:typed_data';
import 'dart:math' as math;
import 'art.dart';
import 'wallet.dart';
import 'paperPage.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaperPageState extends State<PaperPage> {
  Map<String, Art> arts = Map<String, Art>();
  List<Wallet> wallets = List<Wallet>.empty(growable: true);
  String selected = "bitcoin";

  PaperPageState() {
    int initialWallets = 2;
    getArts(this, "./img");
    for (int i = 0; i < initialWallets; i++) {
      Wallet w = Wallet();
      wallets.add(w);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaperPageUI(this);
  }

  void setSelected(String sel) {
    setState(() {
      selected = sel;
    });
  }

  Art getSelectedArt() {
    return this.arts[this.selected];
  }

  void addArt(String name, Art art) async {
    setState(() {
      arts.putIfAbsent(name, () => art);
    });
  }

  Future<void> toPDF() async {
    try {
      print('getting PDF');
      Art selected = this.getSelectedArt();
      final doc = pw.Document();
      pdf.PdfPageFormat ppf = pdf.PdfPageFormat.a4;
      print("Avaiable Width: " + ppf.availableWidth.toString());
      print("Avaiable Height: " + ppf.availableHeight.toString());
      List<pw.Widget> parts = List<pw.Widget>.empty(growable: true);
      // for (int i = 0; i < this.wallets.length; i++) {
      pw.Widget part = await makePDFWallet(
          art: selected, wallet: this.wallets[0], maxWidth: ppf.availableWidth);
      parts.add(part);
      // parts.add(pw.Text("Wallet address: " + this.wallets[i].publicAddress));
      // }
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
      {Art art, Wallet wallet, double maxWidth}) async {
    List<pw.Widget> els = List<pw.Widget>.empty(growable: true);

    double scale = (maxWidth-0.5)/art.width;
    print("Scale: " + scale.toString());

    NetworkImage artImage = NetworkImage(art.url);
    final artImageProvider = await flutterImageProvider(artImage);

    QrPainter pkQr = QrPainter(
      data: wallet.privateKey,
      version: QrVersions.auto,
      gapless: true,
    );
    ByteData pkQrBytes = await pkQr.toImageData(art.pkQr.size);
    Uint8List pkQrUint = Uint8List.sublistView(pkQrBytes);
    ImageProvider pkQrImage = MemoryImage(pkQrUint);
    final pkQrImageProvider = await flutterImageProvider(pkQrImage);

    QrPainter adQr = QrPainter(
      data: wallet.publicAddress,
      version: QrVersions.auto,
      gapless: true,
    );
    ByteData adQrBytes = await adQr.toImageData(art.adQr.size);
    Uint8List adQrUint = Uint8List.sublistView(adQrBytes);
    ImageProvider adQrImage = MemoryImage(adQrUint);
    final adQrImageProvider = await flutterImageProvider(adQrImage);
    // print("Provider height: " + adQrImageProvider.height.toString());
    // print("Provider width: " + adQrImageProvider.width.toString());
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
    print("PK: " + art.pkQr.size.toString());
    print("AD: " + art.adQr.size.toString());
    return pw.Stack(
      children: els,
      fit: pw.StackFit.expand,
      // alignment: pw.Alignment.topLeft,
    );
    // return els.last;
  }

  pw.Widget getPDFWalletElement(
      {double top,
      double left,
      double rotation,
      pw.Widget child}) {
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
}
