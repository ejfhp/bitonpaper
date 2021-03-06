import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/painting.dart';
import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/wallets.dart';

class Rasterizer {
  Future<Uint8List> rasterize({Wallet wallet, Art art}) async {
    //TODO to test/check in the future
    // ui.Codec codec = await ui.instantiateImageCodec(art.bytes, targetHeight: art.height.toInt(), targetWidth: art.width.toInt(), allowUpscaling: true);
    // print("WALLETPAINTER frameCount: " + codec.frameCount.toString());
    // ui.FrameInfo frameInfo = await codec.getNextFrame();
    // ui.Image image = frameInfo.image;

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec, Rect.fromLTRB(0, 0, art.width.toDouble(), art.height.toDouble()));
    //TODO to test/check in the future
    // paintImage(canvas: canvas, image: image, rect: Rect.fromLTRB(0, 0, art.width, art.height));
    if (art.pkQr.visible) {
      _paintQr(canvas, wallet.privateKey, art.pkQr);
    }
    if (art.adQr.visible) {
      _paintQr(canvas, wallet.publicAddress, art.adQr);
    }
    if (art.pk.visible) {
      _paintText(canvas, wallet.privateKey, art.pk);
    }
    if (art.ad.visible) {
      _paintText(canvas, wallet.publicAddress, art.ad);
    }
    ui.Picture pic = rec.endRecording();
    final ui.Image im = await pic.toImage(art.width.toInt(), art.height.toInt());
    ByteData data = await im.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = data.buffer.asUint8List();
    assert(bytes != null);
    return bytes;
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
    Paint p = Paint();
    p.color = artE.bgcolor;
    double rad = (artE.rotation / 180) * math.pi;
    double margin = artE.size / 30;
    canvas.save();
    canvas.translate(artE.left.toDouble(), artE.top.toDouble());
    canvas.rotate(rad);
    canvas.drawRect(Rect.fromLTRB(0, 0, artE.width.toDouble(), artE.height.toDouble()), p);
    canvas.translate(margin, margin);
    qr.paint(canvas, Size(artE.size.toDouble() - (2 * margin), artE.size.toDouble() - (2 * margin)));

    canvas.restore();
  }

  void _paintText(Canvas canvas, String text, ArtElement artE) {
    assert(canvas != null);
    assert(text.isNotEmpty);
    assert(artE != null);
    ui.Paint p = ui.Paint();
    p.color = artE.bgcolor;
    TextSpan span = new TextSpan(style: new TextStyle(color: artE.fgcolor, fontSize: artE.size.toDouble(), fontFamily: "Roboto"), text: text);
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    double rad = (artE.rotation / 180) * math.pi;
    tp.layout();
    canvas.save();
    canvas.translate(artE.left.toDouble(), artE.top.toDouble());
    canvas.rotate(rad);
    tp.paint(canvas, new Offset(0, 0));
    canvas.restore();
  }
}
