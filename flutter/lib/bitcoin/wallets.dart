import 'dart:typed_data';
import 'package:dartsv/dartsv.dart';

class Wallets {
  static final demoWallet = Wallet();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);

  Wallets() {
    Wallet w = Wallet();
    this._wallets.add(w);
  }

  Wallet addNewWallet() {
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
    String wif = "";
    String add = "";
    while (wif == "") {
      try {
        SVPrivateKey privKey = SVPrivateKey(networkType: NetworkType.MAIN);
        wif = privKey.toWIF();
        add = privKey.toAddress(networkType: NetworkType.MAIN).toBase58();
        SVPrivateKey reKey = SVPrivateKey.fromWIF(wif);
        String readd = reKey.toAddress(networkType: NetworkType.MAIN).toString();
        if (readd != add) {
          throw Exception("regenerated address ($readd) is different from original one ($add)");
        }
      } catch (e) {
        print("Wallet, generatet WIF is incorrect $wif $add");
        wif = "";
        add = "";
      }
    }
    this.privateKey = wif;
    this.publicAddress = add;
  }

  @override
  bool operator ==(other) {
    return (other is Wallet) && other.privateKey == privateKey;
  }
}
