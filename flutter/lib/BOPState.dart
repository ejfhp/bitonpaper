import 'dart:typed_data';
import 'package:bitonpaper/print.dart';
import 'dart:convert';
import 'html_print.dart';
import 'html_export.dart';
import 'art.dart';
import 'wallet.dart';
import 'paper.dart';
import 'BOP.dart';
import 'package:flutter/material.dart';

const WIP_PRINTING = 11;
const WIP_PDF = 12;
const WIP_EXPKEYS = 13;
const WIP_IDLE = 0;

class BOPState extends State<BOP> {
  final Map<String, Art> _arts = Map<String, Art>();
  final List<Wallet> _wallets = List<Wallet>.empty(growable: true);
  final List<Paper> _papers = List<Paper>.empty(growable: true);
  final TextEditingController numWalletsController = TextEditingController.fromValue(TextEditingValue(text: "2"));
  final TextEditingController walletsPerPageController = TextEditingController.fromValue(TextEditingValue(text: "2"));
  String _defaultArt = "Bitcoin";
  Art _selectedArt;
  int wip = 0;

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
      walletsPerPageController.text = "1";
      return;
    }

    int s = DateTime.now().millisecondsSinceEpoch;
    PrintSheetHTML printSheet = PrintSheetHTML(this._papers);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => printSheet,
        ));
    await printSheet.preparePrintPreview(walletsPP);
    print("BOPSTATE print preview prepared in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    printSheet.showPrintPreview();
    Navigator.pop(context);
    this.setWIP(WIP_IDLE);
  }

  Future<void> savePapersToPDF() async {
    print("BOPSTATE savePapersToPDF");
    this.setWIP(WIP_PDF);
    //Wait just a bit before starting the printing to allow UI to refresh
    await Future.delayed(const Duration(milliseconds: 100), () {});
    String wPpTxt = walletsPerPageController.text;
    if (wPpTxt.isEmpty) {
      return;
    }
    int walletsPP = int.parse(wPpTxt);
    if (walletsPP < 1) {
      walletsPerPageController.text = "1";
      return;
    }
    int s = DateTime.now().millisecondsSinceEpoch;
    PDFGenerator pdfGen = PDFGenerator();
    Uint8List generatedPDF = await pdfGen.toPDF(papers: this._papers, walletsPerPage: walletsPP);
    print("BOPSTATE PDF generated in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    openDownloadHTML(generatedPDF, MIME_PDF, "bop_wallets.pdf");
    this.setWIP(WIP_IDLE);
  }

  Future<void> saveKeysToTXT() async {
    print("BOPSTATE savePapersToPDF");
    this.setWIP(WIP_EXPKEYS);
    String exportText = "{";
    int numWallets = this._wallets.length;
    for (int i = 0; i < numWallets; i++) {
      exportText += "\"" + this._wallets[i].publicAddress + "\": \"" + this._wallets[i].privateKey + "\"";
      if (i < numWallets - 1) {
        exportText += ",\n";
      }
    }
    exportText += "}";
    final bytes = utf8.encode(exportText);
    openDownloadHTML(bytes, MIME_JSON, "bop_keys.json");
    this.setWIP(WIP_IDLE);
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
