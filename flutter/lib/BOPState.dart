import 'dart:typed_data';
import 'package:bitonpaper/print.dart';
import 'package:bitonpaper/walletPainter.dart';

import 'art.dart';
import 'wallet.dart';
import 'BOP.dart';
import 'package:flutter/material.dart';

class BOPState extends State<BOP> {
  final double artWidth = 250;
  final double toolWidth = 250;
  final double paperWidth = 840;
  final double headerHeight = 108;

  final Map<String, Art> _arts = Map<String, Art>();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  final Map<String, Uint8List> _qrs = Map<String, Uint8List>();
  final TextEditingController numWalletsController = TextEditingController();
  final TextEditingController walletsPerPageController = TextEditingController();
  String _defaultArt = "Bitcoin";
  String _selected;

  BOPState() {
    this._selected = this._defaultArt;
    retrieveArts(this, "./img");
  }

  @override
  Widget build(BuildContext context) {
    return BOPUI(this);
  }

  void setSelected(String sel) {
    _selected = sel;
    refreshWallet();
  }

  Future<void> refreshWallet() async {
    Art art = this.getSelectedArt();
    if (art == null) {
      return;
    }
    this._wallets.clear();
    this._qrs.clear();
    await addWallet(1);
    setState(() {});
  }

  Future<void> addWallet(int numWallets) async {
    print("addWallet: " + numWallets.toString());
    Art art = this.getSelectedArt();
    for (int i = 0; i < numWallets; i++) {
      Wallet w = Wallet();
      w.adImg = await Rasterizer.toImg(
          text: w.publicAddress, width: art.ad.width, height: art.ad.height, fontSize: art.ad.size, fgColor: art.ad.fgcolor, bgColor: art.ad.bgcolor);
      w.pkImg = await Rasterizer.toImg(
          text: w.privateKey, width: art.pk.width, height: art.pk.height, fontSize: art.pk.size, fgColor: art.pk.fgcolor, bgColor: art.pk.bgcolor);
      w.pkQr = await Rasterizer.toQrCodeImg(text: w.privateKey, size: art.pkQr.size, fgColor: art.pkQr.fgcolor, bgColor: art.pkQr.bgcolor);
      w.adQr = await Rasterizer.toQrCodeImg(text: w.publicAddress, size: art.adQr.size, fgColor: art.adQr.fgcolor, bgColor: art.adQr.bgcolor);
      this._wallets.add(w);
    }
  }

  Future<void> printWallets() async {
    String numWTxt = numWalletsController.text;
    String wPpTxt = walletsPerPageController.text;
    if (numWTxt.isEmpty || wPpTxt.isEmpty) {
      return;
    }
    int numWallets = int.parse(numWTxt);
    int walletsPP = int.parse(wPpTxt);
    if (numWallets < 1 || numWallets > 10) {
      numWalletsController.text = "2";
      return;
    }
    if (walletsPP < 1) {
      walletsPerPageController.text = "2";
      return;
    }
    int missing = numWallets - this._wallets.length;
    await addWallet(missing);
    await PDFGenerator.toPDF(art: this.getSelectedArt(), wallets: _wallets, walletspp: walletsPP);
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

  void addArt(String name, Art art) async {
    setState(() {
      _arts.putIfAbsent(name, () => art);
    });
    if (name == _defaultArt) {
      this.refreshWallet();
    }
  }
}
