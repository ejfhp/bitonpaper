import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class WalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.grey[600]), text: 'Bitcoin SV');
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return true;
  }

  /// Returns a [ui.Picture] object containing the QR code data.
  ui.Picture toPicture(double size) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paint(canvas, Size(size, size));
    return recorder.endRecording();
  }

  /// Returns the raw QR code [ui.Image] object.
  Future<ui.Image> toImage(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    return await toPicture(size).toImage(size.toInt(), size.toInt());
  }

  /// Returns the raw QR code image byte data.
  Future<ByteData> toImageData(double size,
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    final image = await toImage(size, format: format);
    return image.toByteData(format: format);
  }
}

