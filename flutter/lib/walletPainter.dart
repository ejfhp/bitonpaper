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
    // canvas.drawRect(ui.Rect.fromLTRB(artE.left, artE.top, artE.width, artE.height), p);
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
