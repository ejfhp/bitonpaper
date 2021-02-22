import 'dart:typed_data';
import 'package:dartsv/dartsv.dart';

class Wallets {
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);

  Wallets() {
    Wallet w = Wallet();
    this._wallets.add(w);
  }

  Wallet newWallet() {
    Wallet w = Wallet();
    this._wallets.add(w);
    return w;
  }

  delete(Wallet w) {
    if (this.canDelete()) {
      this._wallets.remove(w);
    }
  }

  bool canDelete() {
    return this._wallets.length > 1;
  }

  Wallet get first {
    return this._wallets.first;
  }

  Iterable<Wallet> get iterable {
    return this._wallets;
  }

  int get length {
    return this._wallets.length;
  }

  Wallet atIndex(int i) {
    if (i < this._wallets.length) {
      return this._wallets[i];
    }
    return null;
  }
}

class Wallet {
  String privateKey;
  String publicAddress;
  Uint8List pkQr;
  Uint8List adQr;

  Wallet() {
    SVPrivateKey privKey = SVPrivateKey(networkType: NetworkType.MAIN);
    this.privateKey = privKey.toWIF();
    this.publicAddress = privKey.toAddress().toString();
  }
}
