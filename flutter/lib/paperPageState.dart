import 'dart:typed_data';
import 'package:bitonpaper/walletPainter.dart';

import 'art.dart';
import 'wallet.dart';
import 'paperPage.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'walletPainter.dart';

class PaperPageState extends State<PaperPage> {
  Map<String, Art> _arts = Map<String, Art>();
  List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  Map<String, Uint8List> _qrs = Map<String, Uint8List>();
  String _defaultArt = "bitcoin";
  String _selected;

  PaperPageState() {
    this._selected = this._defaultArt;
    retrieveArts(this, "./img");
  }

  @override
  Widget build(BuildContext context) {
    return PaperPageUI(this);
  }

  void setSelected(String sel) {
    setState(() {
      _selected = sel;
    });
  }

  void refreshWallet(int numWallets) async {
    Art art = this.getSelectedArt();
    if (art == null) {
      return;
    }
    this._wallets.clear();
    this._qrs.clear();
    for (int i = 0; i < numWallets; i++) {
      Wallet w = Wallet();
      this._wallets.add(w);
      this._qrs[w.privateKey] = await _buildQrImage(w.privateKey, art.pkQr.size);
      // WalletPainter wp = WalletPainter();
      // ByteData bd = await wp.toImageData(100);
      // this._qrs[w.privateKey] = Uint8List.sublistView(bd);
      this._qrs[w.publicAddress] = await _buildQrImage(w.publicAddress, art.adQr.size);
    }
    setState(() {});
  }

  Future<Uint8List> _buildQrImage(String text, double size) async {
    QrPainter qr = QrPainter(
      data: text,
      version: QrVersions.auto,
      gapless: true,
    );
    ByteData qrBytes = await qr.toImageData(size);
    return Uint8List.sublistView(qrBytes);
  }

  Map<String, Art> getArts() {
    return this._arts;
  }

  Art getSelectedArt() {
    return this._arts[this._selected];
  }

  Wallet getWallet() {
    if (_wallets.length == 0) {
      return null;
    }
    return _wallets.first;
  }
  
  List<Wallet> getWallets() {
    return this._wallets;
  }

  Map<String, Uint8List> getQrs() {
    return this._qrs;
  }

  Uint8List getQrPk() {
    Wallet key = this.getWallet();
    if (key == null) {
      return null;
    }
    return this._qrs[key.privateKey];
  }


  Uint8List getQrAd() {
    Wallet key = this.getWallet();
    if (key == null) {
      return null;
    }
    return this._qrs[key.publicAddress];
  }

  void addArt(String name, Art art) async {
    setState(() {
      _arts.putIfAbsent(name, () => art);
    });
    if (name == _defaultArt) {
      this.refreshWallet(1);
    }
  }
}
