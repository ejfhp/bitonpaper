import 'dart:typed_data';
import 'package:dartsv/dartsv.dart';

class Wallet {
  String privateKey;
  String publicAddress;
  Uint8List pkImg;
  Uint8List adImg;
  Uint8List pkQr;
  Uint8List adQr;

  Wallet() {
    SVPrivateKey privKey = SVPrivateKey(networkType: NetworkType.MAIN);
    this.privateKey = privKey.toWIF();
    this.publicAddress = privKey.toAddress().toString();
  }

  bool isReady() {
    return pkQr != null && adQr != null && pkImg != null && adImg != null;
  }
}
