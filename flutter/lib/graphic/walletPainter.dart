import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:bop/graphic/painterQR.dart';
import 'package:bop/graphic/art.dart';
import 'package:bop/bitcoin/wallets.dart';

class WalletPainter {
  Future<Uint8List> rasterize({Wallet wallet, Art art}) async {
    assert(art.height != 0);
    assert(art.width != 0);
    print("walletPainter.rasterize name: " + art.name + " " + art.subname);
    try {
      //TODO to test/check in the future
      // ui.Codec codec = await ui.instantiateImageCodec(art.bytes, targetHeight: art.height.toInt(), targetWidth: art.width.toInt(), allowUpscaling: true);
      // print("WALLETPAINTER frameCount: " + codec.frameCount.toString());
      // ui.FrameInfo frameInfo = await codec.getNextFrame();
      // ui.Image image = frameInfo.image;

      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec, Rect.fromLTRB(0, 0, art.width.toDouble(), art.height.toDouble()));
      //TODO to test/check in the future
      // paintImage(canvas: canvas, image: image, rect: Rect.fromLTRB(0, 0, art.width, art.height));
      if (art.getElement(Art.ART_PKQR).visible) {
        _paintQr(canvas, wallet.privateKey, art.getElement(Art.ART_PKQR));
      }
      if (art.getElement(Art.ART_ADQR).visible) {
        _paintQr(canvas, wallet.publicAddress, art.getElement(Art.ART_ADQR));
      }
      if (art.getElement(Art.ART_PK).visible) {
        _paintText(canvas, wallet.privateKey, art.getElement(Art.ART_PK));
      }
      if (art.getElement(Art.ART_AD).visible) {
        _paintText(canvas, wallet.publicAddress, art.getElement(Art.ART_AD));
      }
      ui.Picture pic = rec.endRecording();
      ui.Image im = await pic.toImage(art.width.toInt(), art.height.toInt());
      ByteData data = await im.toByteData(format: ui.ImageByteFormat.png);
      Uint8List bytes = data.buffer.asUint8List();
      assert(bytes != null);
      return bytes;
    } catch (e) {
      print("walletPainter.rasterize failed: " + e.toString());
      return e;
    }
  }

  void _paintQr(Canvas canvas, String text, ArtElement artElement) {
    assert(canvas != null);
    assert(text.isNotEmpty);
    assert(artElement != null);

    QrPainter qr = QrPainter(
      data: text,
      color: artElement.fgcolor,
      emptyColor: artElement.bgcolor,
      version: QrVersions.auto,
      gapless: true,
    );
    Paint p = Paint();
    p.color = artElement.bgcolor;
    double rad = (artElement.rotation / 180) * math.pi;
    double margin = artElement.size / 30;
    canvas.save();
    canvas.translate(artElement.left.toDouble(), artElement.top.toDouble());
    canvas.rotate(rad);
    canvas.drawRect(Rect.fromLTRB(0, 0, artElement.size.toDouble(), artElement.size.toDouble()), p);
    canvas.translate(margin, margin);
    qr.paint(canvas, Size(artElement.size.toDouble() - (2 * margin), artElement.size.toDouble() - (2 * margin)));
    canvas.restore();
  }

  void _paintText(Canvas canvas, String text, ArtElement artElement) {
    assert(canvas != null);
    assert(text.isNotEmpty);
    assert(artElement != null);
    ui.Paint p = ui.Paint();
    p.color = artElement.bgcolor;
    TextSpan span = new TextSpan(style: new TextStyle(color: artElement.fgcolor, fontSize: artElement.size.toDouble(), fontFamily: "Roboto"), text: text);
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    double rad = (artElement.rotation / 180) * math.pi;
    tp.layout();
    canvas.save();
    canvas.translate(artElement.left.toDouble(), artElement.top.toDouble());
    canvas.rotate(rad);
    tp.paint(canvas, new Offset(0, 0));
    canvas.restore();
  }
}
