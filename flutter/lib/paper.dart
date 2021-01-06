import 'dart:typed_data';
import 'package:flutter/material.dart';

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
}
