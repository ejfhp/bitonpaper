import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'package:bitonpaper/print.dart';
import 'dart:html' as html;

import 'art.dart';
import 'wallet.dart';
import 'paper.dart';
import 'BOP.dart';
import 'package:flutter/material.dart';

const WIP_PRINTING = 11;
const WIP_IDLE = 0;

class BOPState extends State<BOP> {
  final Map<String, Art> _arts = Map<String, Art>();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  final List<Paper> _papers = List<Paper>.empty(growable: true);
  final TextEditingController numWalletsController = TextEditingController.fromValue(TextEditingValue(text: "1"));
  final TextEditingController walletsPerPageController = TextEditingController();
  String _defaultArt = "Bitcoin";
  Art _selectedArt;
  int wip = 0;
  Uint8List lastGeneratedPDF;

  BOPState() {
    loadArts(this, "./img");
    updateWallets();
  }

  @override
  Widget build(BuildContext context) {
    return BOPUI(this);
  }

  Future<void> selectArt(String sel) async {
    print("BOPSTATE selectArt" + sel);
    setState(() {
      this._selectedArt = this._arts[sel];
    });
    if (this._wallets.length == 0) {
      await this.updateWallets();
    }
    await this.regeneratePapers();
  }

  Future<void> updateWallets() async {
    print("BOPSTATE updateWallets");
    String numWTxt = numWalletsController.text;
    if (numWTxt.isEmpty || (this._selectedArt == null)) {
      return;
    }
    int numWs = int.parse(numWTxt);
    if (numWs < 1 || numWs > 10) {
      numWalletsController.text = "1";
      return;
    }
    int curNumWs = this._wallets.length;
    if (curNumWs > numWs) {
      this._wallets.removeRange(numWs, curNumWs);
      this._papers.removeRange(numWs, curNumWs);
    } else if (curNumWs < numWs) {
      for (int i = curNumWs; i < numWs; i++) {
        int s = DateTime.now().millisecondsSinceEpoch;
        this._wallets.add(Wallet());
        int l = DateTime.now().millisecondsSinceEpoch - s;
        print("BOPSTATE wallet created in (millis):" + l.toString());
        this._papers.add(await Paper.generatePaper(this._wallets[i], this._selectedArt));
      }
    }
    setState(() {});
  }

  Future<void> regeneratePapers() async {
    print("BOPSTATE regenerate papers");
    this._papers.clear();
    for (int i = 0; i < this._wallets.length; i++) {
      this._papers.add(await Paper.generatePaper(this._wallets[i], this._selectedArt));
    }
    setState(() {});
  }

  Future<void> printPapers() async {
    print("BOPSTATE printPapers");
    this.setWIP(WIP_PRINTING);
    //Wait just a bit before starting the printing to allow UI to refresh
    await Future.delayed(const Duration(milliseconds: 100), () {});
    String wPpTxt = walletsPerPageController.text;
    if (wPpTxt.isEmpty) {
      return;
    }
    int walletsPP = int.parse(wPpTxt);
    if (walletsPP < 1) {
      walletsPerPageController.text = "2";
      return;
    }
    PDFGenerator pdfGen = PDFGenerator();
    this.lastGeneratedPDF = await pdfGen.toPDF(papers: this._papers, walletsPerPage: walletsPP);
    int s = DateTime.now().millisecondsSinceEpoch;
    await Printing.layoutPdf(onLayout: (format) async => this.lastGeneratedPDF);
    print("BOPSTATE PDF shown to print dialog in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    this.setWIP(WIP_IDLE);
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

  void setWIP(int task) {
    setState(() {
      print("BOPSTATE setWIP: " + task.toString());
      this.wip = task;
    });
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
