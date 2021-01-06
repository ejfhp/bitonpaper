import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'wallet.dart';

class Paper {
  final Wallet wallet;
  ui.Image _background;
  ui.Image _overlay;
  ByteData _backgroundData;
  ByteData _overlayData;
  int _height;
  int _width;

  Paper({this.wallet, ui.Image bgdImage, ui.Image overlayImage, ByteData bgdData, ByteData overlayData}) {
    assert(this.wallet != null);
    assert(bgdImage != null);
    assert(overlayImage != null);
    int bgH = bgdImage.height;
    int ovH = overlayImage.height;
    assert(bgH == ovH);
    int bgW = bgdImage.width;
    int ovW = overlayImage.width;
    assert(bgW == ovW);
    this._height = bgH;
    this._width = bgW;
    this._background = bgdImage.clone();
    this._overlay = overlayImage.clone();
    this._backgroundData = bgdData;
    this._overlayData = overlayData;
  }

  int get width {
    return this._width;
  }

  int get height {
    return this._height;
  }

  ui.Image get overlay {
    return this._overlay.clone();
  }

  ui.Image get background {
    return this._background.clone();
  }

  ByteData get overlayData {
    return this._overlayData;
  }

  ByteData get backgroundData {
    return this._backgroundData;
  }
}
