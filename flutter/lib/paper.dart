import 'dart:typed_data';
import 'wallet.dart';

class Paper {
  final Wallet wallet;
  final Uint8List backgroundBytes;
  final Uint8List overlayBytes;
  final int height;
  final int width;

  Paper({this.wallet, this.backgroundBytes, this.overlayBytes, this.height, this.width}) {
    assert(this.wallet != null);
    assert(this.backgroundBytes != null);
    assert(this.overlayBytes != null);
  }
}
