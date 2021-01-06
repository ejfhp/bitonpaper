import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:bitonpaper/print.dart';
import 'package:bitonpaper/walletPainter.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'art.dart';
import 'wallet.dart';
import 'paper.dart';
import 'BOP.dart';
import 'package:flutter/material.dart';

class BOPState extends State<BOP> {
  final Map<String, Art> _arts = Map<String, Art>();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  final List<Paper> _papers = List<Paper>.empty(growable: true);
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
    print("BOPSTATE selectArt" + sel);
    this._selectedArt = this._arts[sel];
    print("BOPSTATE selectArt art image disposed? " + this._selectedArt.image.debugDisposed.toString());
    await this.regeneratePapers();
    print("BOPSTATE selectArt after art image disposed? " + this._selectedArt.image.debugDisposed.toString());
    setState(() {});
  }

  void setPrintingInProgress(bool printing) {
    setState(() {
      this._printingInProgress = printing;
    });
  }

  Future<void> regenerateWallets() async {
    print("BOPSTATE regenerateWallets");
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

  Future<void> regeneratePapers() async {
    print("BOPSTATE regenerate papers");
    this._papers.clear();
    for (int i = 0; i < this._wallets.length; i++) {
      Wallet w = this._wallets[i];
      print("BOPSTATE gnerating paper for: " + w.privateKey);
      ui.Image wp = await Rasterizer().rasterize(wallet: w, art: this._selectedArt);
      ByteData data = await wp.toByteData(format: ui.ImageByteFormat.png);
      print("BOPSTATE done gnerating paper for: " + w.privateKey);
      print("BOPSTATE regenatePapers art image disposed? " + this._selectedArt.image.debugDisposed.toString());
      Paper p = Paper(wallet: w, bgdImage: this._selectedArt.image, overlayImage: wp, bgdData: this._selectedArt.byteData, overlayData: data);
      this._papers.add(p);
      print("BOPSTATE added paper for: " + w.privateKey);
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
    print("BOPSTATE printwallets art image disposed? " + this._selectedArt.image.debugDisposed.toString());
    this.lastGeneratedPDF = await PDFGenerator().toPDF(papers: this._papers, walletsPerPage: walletsPP);

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
    return this._arts.length;
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

  List<Paper> getPapers() {
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
    print("BOPSTATE addArt: " + art.name);
    if (art.name == _defaultArt) {
      this.selectArt(art.name);
    }
  }
}
