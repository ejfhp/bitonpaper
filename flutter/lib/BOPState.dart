import 'dart:typed_data';
import 'package:bitonpaper/pdf_print.dart';
import 'dart:convert';
import 'html_print.dart';
import 'html_export.dart';
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
  final TextEditingController walletsPerPageController = TextEditingController.fromValue(TextEditingValue(text: "2"));
  String _defaultArt = "Bitcoin";
  bool _exportOnlyKeys = false;
  Art _selectedArt;

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
    //Back to the normal UI
    Navigator.of(context).pop();
  }

  Future<void> savePapersToPDF() async {
    print("BOPSTATE savePapersToPDF");
    _showAlert("", "Please be patient, PDF generation takes a while...");
    //PDF generation freeze the UI, better to have some time to allow the alert to be drawn.
    await Future.delayed(const Duration(milliseconds: 300), () {});
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
    DocSet pdfConf = DocSet(papers: this._papers, walletPerPage: walletsPP);
    Uint8List generatedPDF = await generatePDF(pdfConf);
    print("BOPSTATE PDF generated in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    openDownloadHTML(generatedPDF, MIME_PDF, "bop_wallets.pdf");
    //Remove the alert
    Navigator.of(context).pop();
  }

  Future<void> saveKeysToTXT() async {
    print("BOPSTATE savePapersToPDF");
    int numWallets = this._wallets.length;
    String filename = "bop_keys-addr.json";
    String exportText = "";
    if (this._exportOnlyKeys) {
      filename = "bop_keys.txt";
      for (int i = 0; i < numWallets; i++) {
        exportText += this._wallets[i].privateKey + " ";
      }
    } else {
      exportText += "{";
      for (int i = 0; i < numWallets; i++) {
        exportText += "\"" + this._wallets[i].publicAddress + "\": \"" + this._wallets[i].privateKey + "\"";
        if (i < numWallets - 1) {
          exportText += ",\n";
        }
      }
      exportText += "}";
    }
    final bytes = utf8.encode(exportText);
    openDownloadHTML(bytes, MIME_JSON, filename);
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

  set exportOnlyKeys(bool val) {
    setState(() {
      this._exportOnlyKeys = val;
    });
  }

  bool get exportOnlyKeys {
    return this._exportOnlyKeys;
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

  Future<void> _showAlert(String title, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey,
          elevation: 20,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black54, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.amber, fontFamily: "Roboto"),
          ),
          content: Container(
            height: 50,
            child: Column(
              children: <Widget>[
                Text(
                  text,
                  style: TextStyle(color: Colors.amber, fontFamily: "Roboto"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
