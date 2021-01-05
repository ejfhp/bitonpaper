import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'art.dart';
import 'wallet.dart';

class WalletPainter extends CustomPainter {
  final ui.Image image;
  final Art art;

  WalletPainter({this.image, this.art}) {
    print("Art image width, height: " + this.image.width.toString() + " " + this.image.height.toString());
    print("Art width, height: " + this.art.width.toString() + " " + this.art.height.toString());
  }

  @override
  void paint(Canvas canvas, Size size) {
    print("Paint 1");
    ui.Paint p = ui.Paint();
    print("Paint DRAW IMAGE");
    canvas.save();
    print("Disposed? " + image.debugDisposed.toString());
    print("Runtime type: " + image.runtimeType.toString());
    // canvas.drawImage(image, Offset.zero, p);
    canvas.drawImageRect(image, ui.Rect.fromLTRB(0, 0, 10, 10), ui.Rect.fromLTRB(0, 0, 10, 10), p);
    // print("Paint DRAW IMAGE DONE");

    // p.color = Colors.green;
    // canvas.drawRect(ui.Rect.fromLTRB(0, 0, 10, 10), p);
    // p.color = Colors.red;
    // canvas.drawRect(ui.Rect.fromLTRB(10, 10, 20, 20), p);
    // p.color = Colors.blue;
    // canvas.drawRect(ui.Rect.fromLTRB(30, 30, 40, 40), p);
    // print("Paint DRAW RECT DONE");
    // TextSpan span = new TextSpan(style: new TextStyle(color: Colors.black, fontSize: 30, fontFamily: "Roboto"), text: "BOP!");
    // TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    // tp.layout();
    // tp.paint(canvas, new Offset(0, 0));
    image.dispose();
    print("Paint DRAW TEXT DONE");
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return true;
  }
}

class TextImage extends CustomPainter {
  String text;
  double fontSize;
  String fontFamily;
  ui.Color fontColor;
  ui.Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    ui.Paint p = ui.Paint();
    p.color = this.bgColor;
    canvas.drawRect(ui.Rect.fromLTRB(0, 0, size.width, size.height), p);
    TextSpan span = new TextSpan(style: new TextStyle(color: this.fontColor, fontSize: this.fontSize, fontFamily: this.fontFamily), text: this.text);
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return true;
  }
}

class Rasterizer {
  Future<Uint8List> toQrCodeImg({String text, double size, ui.Color fgColor = Colors.black, ui.Color bgColor = Colors.white}) async {
    QrPainter qr = QrPainter(
      data: text,
      color: fgColor,
      emptyColor: bgColor,
      version: QrVersions.auto,
      gapless: true,
    );

    ByteData qrBytes = await qr.toImageData(size);
    return Uint8List.sublistView(qrBytes);
  }

  Future<Uint8List> toImg(
      {String text,
      double width,
      double height,
      double fontSize = 20,
      String fontFamily = "Roboto",
      ui.Color fgColor = Colors.black,
      ui.Color bgColor = Colors.transparent}) async {
    TextImage txtImage = TextImage();
    txtImage.text = text;
    txtImage.fontSize = fontSize;
    txtImage.fontFamily = fontFamily;
    txtImage.fontColor = fgColor;
    txtImage.bgColor = bgColor;
    ui.ImageByteFormat format = ui.ImageByteFormat.png;
    txtImage.text = text;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    txtImage.paint(canvas, Size(width, height));
    ui.Picture picture = recorder.endRecording();
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData data = await image.toByteData(format: format);
    return Uint8List.sublistView(data);
  }

  Future<ui.Image> rasterize({Wallet wallet, Art art}) async {
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec, Rect.fromLTRB(0, 0, art.width, art.height));
    // p2..blendMode = BlendMode.src;
    // p2..imageFilter = ui.ImageFilter.blur();
    _paintQr(canvas, wallet.privateKey, art.pkQr);
    _paintQr(canvas, wallet.publicAddress, art.adQr);
    _paintText(canvas, wallet.privateKey, art.pk);
    _paintText(canvas, wallet.publicAddress, art.ad);
    ui.Picture pic = rec.endRecording();
    final ui.Image im = await pic.toImage(art.width.toInt(), art.height.toInt());
    return im;
  }

  void _paintQr(Canvas canvas, String text, ArtElement artE) {
    assert(canvas != null);
    assert(text.isNotEmpty);
    assert(artE != null);
    QrPainter qr = QrPainter(
      data: text,
      color: artE.fgcolor,
      emptyColor: artE.bgcolor,
      version: QrVersions.auto,
      gapless: true,
    );
    double rad = (artE.rotation / 180) * math.pi;
    canvas.save();
    canvas.translate(artE.left, artE.top);
    canvas.rotate(rad);
    qr.paint(canvas, Size(artE.size, artE.size));
    canvas.restore();
  }

  void _paintText(Canvas canvas, String text, ArtElement artE) {
    assert(canvas != null);
    assert(text.isNotEmpty);
    assert(artE != null);
    ui.Paint p = ui.Paint();
    p.color = artE.bgcolor;
    canvas.drawRect(ui.Rect.fromLTRB(artE.left, artE.top, artE.width, artE.height), p);
    TextSpan span = new TextSpan(style: new TextStyle(color: artE.fgcolor, fontSize: artE.size, fontFamily: "Roboto"), text: text);
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    double rad = (artE.rotation / 180) * math.pi;
    tp.layout();
    canvas.save();
    canvas.translate(artE.left, artE.top);
    canvas.rotate(rad);
    tp.paint(canvas, new Offset(0, 0));
    canvas.restore();
  }
}
