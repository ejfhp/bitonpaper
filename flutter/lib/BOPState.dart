import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:bitonpaper/print.dart';
import 'package:bitonpaper/walletPainter.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'art.dart';
import 'wallet.dart';
import 'BOP.dart';
import 'package:flutter/material.dart';

class BOPState extends State<BOP> {
  final Map<String, Art> _arts = Map<String, Art>();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  final List<Paper> _papers = Map<String, ui.Image>();
  final TextEditingController numWalletsController = TextEditingController.fromValue(TextEditingValue(text: "2"));
  final TextEditingController walletsPerPageController = TextEditingController();
  String _defaultArt = "Bitcoin";
  Art _selectedArt;
  bool _printingInProgress = false;
  Uint8List lastGeneratedPDF;

  BOPState() {
    loadArts(this, "./img");
    this.regenerateWallets();
  }

  @override
  Widget build(BuildContext context) {
    return BOPUI(this);
  }

  Future<void> selectArt(String sel) async {
    print("selectArt" + sel);
    this._selectedArt = this._arts[sel];
    // await regenerateWalletsImg();
    await this.generatePapers();
    setState(() {});
  }

  void setPrintingInProgress(bool printing) {
    setState(() {
      this._printingInProgress = printing;
    });
  }

  Future<void> regenerateWallets() async {
    print("regenerateWallets");
    String numWTxt = numWalletsController.text;
    if (numWTxt.isEmpty) {
      return;
    }
    int numWallets = int.parse(numWTxt);
    if (numWallets < 1 || numWallets > 10) {
      numWalletsController.text = "2";
      return;
    }
    this._wallets.clear();
    for (int i = 0; i < numWallets; i++) {
      this._wallets.add(Wallet());
    }
  }

  Future<void> regenerateWalletsImg() async {
    print("regenerateWalletsImg");
    Art art = this.getSelectedArt();
    if (art == null) {
      return;
    }
    for (int i = 0; i < this._wallets.length; i++) {
      Wallet w = this._wallets[i];
      w.adImg = await Rasterizer()
          .toImg(text: w.publicAddress, width: art.ad.width, height: art.ad.height, fontSize: art.ad.size, fgColor: art.ad.fgcolor, bgColor: art.ad.bgcolor);
      w.pkImg = await Rasterizer()
          .toImg(text: w.privateKey, width: art.pk.width, height: art.pk.height, fontSize: art.pk.size, fgColor: art.pk.fgcolor, bgColor: art.pk.bgcolor);
      w.pkQr = await Rasterizer().toQrCodeImg(text: w.privateKey, size: art.pkQr.size, fgColor: art.pkQr.fgcolor, bgColor: art.pkQr.bgcolor);
      w.adQr = await Rasterizer().toQrCodeImg(text: w.publicAddress, size: art.adQr.size, fgColor: art.adQr.fgcolor, bgColor: art.adQr.bgcolor);
    }
    setState(() {});
  }

  Future<void> generatePapers() async {
    print("gnerating papers");
    for (int i = 0; i < this._wallets.length; i++) {
      Wallet w = this._wallets[i];
      print("gnerating paper for: " + w.privateKey);
      ui.Image wp = await Rasterizer().rasterize(wallet: w, art: this._selectedArt);
      print("done gnerating paper for: " + w.privateKey);
      this._papers.putIfAbsent(w.privateKey, () => wp);
      print("added paper for: " + w.privateKey);
    }
    setState(() {});
  }

  Future<void> printWallets() async {
    this.setPrintingInProgress(true);
    String wPpTxt = walletsPerPageController.text;
    if (wPpTxt.isEmpty) {
      return;
    }
    int walletsPP = int.parse(wPpTxt);
    if (walletsPP < 1) {
      walletsPerPageController.text = "2";
      return;
    }
    this.lastGeneratedPDF = await PDFGenerator.toPDF(art: this.getSelectedArt(), wallets: _wallets, walletspp: walletsPP);

    await Printing.layoutPdf(onLayout: (format) async => this.lastGeneratedPDF);
    this.setPrintingInProgress(false);
  }

  Future<void> savePDF() async {
    final blob = html.Blob([this.lastGeneratedPDF], "application/pdf");
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'wallets.pdf';
    html.document.body.children.add(anchor);
    anchor.click();
    html.document.body.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Map<String, Art> getArts() {
    return this._arts;
  }

  int numArts() {
    this._arts.length;
  }

  Art getSelectedArt() {
    return this._selectedArt;
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

  Map<String, ui.Image> getPapers() {
    return this._papers;
  }

  bool isPrinting() {
    return this._printingInProgress;
  }

  bool areWalletsReady() {
    if (this._wallets.isEmpty) {
      return false;
    }
    for (int i = 0; i < this._wallets.length; i++) {
      if (this._wallets[i].isReady() == false) {
        return false;
      }
    }
    return true;
  }

  void addArt(Art art) async {
    setState(() {
      _arts.putIfAbsent(art.name, () => art);
    });
    print("addArt: " + art.name);
    if (art.name == _defaultArt) {
      this.selectArt(art.name);
    }
  }
}
