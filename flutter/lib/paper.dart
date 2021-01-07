import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bitonpaper/walletPainter.dart';
import 'package:bitonpaper/art.dart';

import 'wallet.dart';

class Paper {
  final Wallet wallet;
  final Uint8List backgroundBytes;
  final Uint8List overlayBytes;
  final int height;
  final int width;

  Paper({@required this.wallet, @required this.backgroundBytes, @required this.overlayBytes, @required this.height, @required this.width}) {
    assert(this.wallet != null);
    assert(this.backgroundBytes != null);
    assert(this.overlayBytes != null);
  }

  static Future<Paper> generatePaper(Wallet w, Art art) async {
    int s = DateTime.now().millisecondsSinceEpoch;
    Uint8List bytes = await Rasterizer().rasterize(wallet: w, art: art);
    int l = DateTime.now().millisecondsSinceEpoch - s;
    print("PAPER wallet rasterized in (millis):" + l.toString());
    Paper p = Paper(wallet: w, backgroundBytes: art.bytes, overlayBytes: bytes, width: art.width.toInt(), height: art.height.toInt());
    return p;
  }
}
