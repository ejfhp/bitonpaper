import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

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
    TextSpan span = new TextSpan(
        style: new TextStyle(
            color: this.fontColor,
            fontSize: this.fontSize,
            fontFamily: this.fontFamily),
        text: this.text);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter oldPainter) {
    return true;
  }
}

class Rasterizer {

  static Future<Uint8List> toQrCodeImg(
      {String text,
      double size,
      ui.Color fgColor = Colors.black,
      ui.Color bgColor = Colors.white}) async {
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
  
  static Future<Uint8List> toImg(
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
}
