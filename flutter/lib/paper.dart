import 'dart:ui' as ui;
import 'package:dartsv/dartsv.dart';

class Wallet {
  String privateKey;
  String publicAddress;
  ui.Image art;
  ui.Image overlay;

  Wallet() {
    SVPrivateKey privKey = SVPrivateKey(networkType: NetworkType.MAIN);
    this.privateKey = privKey.toWIF();
    this.publicAddress = privKey.toAddress().toString();
  }

  bool isReady() {
    return pkQr != null && adQr != null && pkImg != null && adImg != null;
  }
}
