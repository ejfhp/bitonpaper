import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:bop/graphic/walletPainter.dart';
import 'package:bop/graphic/art.dart';
import 'package:bop/bitcoin/wallets.dart';

WalletPainter _walletPainter = WalletPainter();

class Papers {
  Map<String, Paper> _papersMap = Map<String, Paper>();
  Set<Wallet> _walletsSet = Set<Wallet>();
  int _artLastChange;

  Papers();

  String hash() {
    String all = _artLastChange.toString();
    _walletsSet.forEach((element) {
      all = all + element.publicAddress;
    });

    return sha256.convert(all.codeUnits).toString();
  }

  int get artLastChange => this._artLastChange;

  bool isOld(int artLastChange) {
    return (artLastChange != this._artLastChange);
  }

  Future initializePapers(Wallets wallets, Art art) async {
    for (int i = 0; i < wallets.length; i++) {
      await _upsertPaper(wallets.atIndex(i), art);
    }
  }

  Future _upsertPaper(Wallet wallet, Art art) async {
    this._artLastChange = art.lastChange;
    Uint8List bytes = await _walletPainter.rasterize(wallet: wallet, art: art);
    Paper p = Paper(wallet: wallet, art: art, overlayBytes: bytes);
    this._walletsSet.add(wallet);
    this._papersMap[wallet.privateKey] = p;
  }

  void deletePaper(Wallet w) {
    this._papersMap.remove(w.privateKey);
    this._walletsSet.remove(w);
  }

  Iterator<Wallet> get walletsIterator {
    return this._walletsSet.iterator;
  }

  Future redrawAllWithArt(Art art) async {
    this._papersMap.clear();
    Iterator<Wallet> wit = this.walletsIterator;
    while (wit.moveNext()) {
      await this._upsertPaper(wit.current, art);
    }
  }

  int get length {
    return this._walletsSet.length;
  }

  Paper getPaperAt(int index) {
    print("Papers.getPaperAt $index");
    String privKey = this._walletsSet.elementAt(index).privateKey;
    print("Papers.getPaperAt $index   $privKey");
    Paper p = this._papersMap[privKey];
    print("Papers.getPaperAt $index   $privKey " + p.wallet.privateKey);
    return p;
  }
}

class Paper {
  Art art;
  Wallet wallet;
  Uint8List overlayBytes;

  Paper({@required this.wallet, @required this.art, @required this.overlayBytes});
}
