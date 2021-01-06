import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:bitonpaper/print.dart';
import 'package:bitonpaper/walletPainter.dart';
import 'dart:html' as html;

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
    await this.regeneratePapers();
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
    print("BOPSTATE regenerateWallets numwallets: " + numWallets.toString());
    for (int i = 0; i < numWallets; i++) {
      this._wallets.add(Wallet());
    }
  }

  Future<void> regeneratePapers() async {
    print("BOPSTATE regenerate papers");
    this._papers.clear();
    for (int i = 0; i < this._wallets.length; i++) {
      Wallet w = this._wallets[i];
      Uint8List bytes = await Rasterizer().rasterize(wallet: w, art: this._selectedArt);
      Paper p = Paper(
          wallet: w,
          backgroundBytes: this._selectedArt.bytes,
          overlayBytes: bytes,
          width: this._selectedArt.width.toInt(),
          height: this._selectedArt.height.toInt());
      this._papers.add(p);
    }
    setState(() {});
  }

  Future<void> printPapers() async {
    print("BOPSTATE printPapers");
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
    this.lastGeneratedPDF = await PDFGenerator().toPDF(papers: this._papers, walletsPerPage: walletsPP);
    await Printing.layoutPdf(onLayout: (format) async => this.lastGeneratedPDF);
    this.setPrintingInProgress(false);
  }

  Future<void> savePapersToPDF() async {
    print("BOPSTATE savePapersToPDF");
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

  List<Wallet> getWallets() {
    return this._wallets;
  }

  List<Paper> getPapers() {
    return this._papers;
  }

  bool isPrinting() {
    return this._printingInProgress;
  }

  // bool areWalletsReady() {
  //   if (this._wallets.isEmpty) {
  //     return false;
  //   }
  //   for (int i = 0; i < this._wallets.length; i++) {
  //     if (this._wallets[i].isReady() == false) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

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
