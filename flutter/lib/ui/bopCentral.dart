import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bop/graphic/papers.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:bop/graphic/arts.dart';
import 'package:bop/graphic/art.dart';
import 'package:bop/io/paperPrintSet.dart';
import 'package:bop/ui/artList.dart';
import 'package:bop/ui/artPrint.dart';

class BOPCentral {
  Art _selectedArt;
  Papers _papersCache;
  Wallets _wallets;
  Arts _arts;
  FirebaseAnalytics _analytics;
  FirebaseAnalyticsObserver _observer;
  ArtList artList;
  ArtPrint artPrint;

  BOPCentral({Arts arts, Wallets wallets, FirebaseAnalytics analytics, FirebaseAnalyticsObserver observer}) {
    this._arts = arts;
    this._wallets = wallets;
    this._analytics = analytics;
    this._observer = observer;
    this._selectedArt = arts.first;
  }

  Wallets get wallets => _wallets;
  Arts get arts => _arts;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseAnalyticsObserver get observer => _observer;

  void connectArtLis(ArtList artList) {
    this.artList = artList;
  }

  void connectArtPrint(ArtPrint artPrint) {
    this.artPrint = artPrint;
  }

  Future setSelectedArt(Art art) async {
    this._selectedArt = art;
    this.clearPapersCache();
    await this.logFirebaseEvent(
      name: 'artlist_select',
      parameters: <String, dynamic>{'name': art.name, "subname": art.subname},
    );
  }

  bool isSelectedArt(Art art) {
    if (art == null) return false;
    if (this._selectedArt == null) return false;
    return this._selectedArt.isEqual(art);
  }

  Future logFirebaseEvent({String name, Map<String, dynamic> parameters}) async {
    await this._analytics.logEvent(
          name: name,
          parameters: parameters,
        );
  }

  int getArtsCount() {
    return this._arts.getNamesLength();
  }

  String getArtName(int index) {
    return this._arts.getName(index);
  }

  Art getArt(String name) {
    return this._arts.getArt(name: name);
  }

  Future<Papers> getPapers() async {
    if (this._papersCache == null) {
      this._papersCache = Papers();
      await this._papersCache.initializePapers(this.wallets, this._selectedArt);
    } else if (this._papersCache.isOld(this._selectedArt.lastChange)) {
      print("BopCentral.getPapers papersCache is old");
      await this._papersCache.redrawAllWithArt(this._selectedArt);
    }
    return this._papersCache;
  }

  void clearPapersCache() {
    this._papersCache = null;
  }

  Future printWallets(BuildContext context) async {
    print("BOPCentral.printWallets");
    Papers papers = await this.getPapers();
    PaperPrintSet printSet = PaperPrintSet(papers: papers);
    await printSet.printPages();
    await this.logFirebaseEvent(
      name: 'artprint_print_paper',
      parameters: <String, dynamic>{'name': this._selectedArt.name, 'subname': this._selectedArt.subname, 'num_wallets': papers.length},
    );
  }

  Future<void> exportWalletsToPDF(BuildContext context) async {
    print("BOPCentral.exportWalletsToPDF");
    Papers papers = await this.getPapers();
    PaperPrintSet printSet = PaperPrintSet(papers: papers);
    await printSet.downloadPages();
    await this.logFirebaseEvent(
      name: 'artprint_export_paper',
      parameters: <String, dynamic>{'name': this._selectedArt.name, 'subname': this._selectedArt.subname, 'num_wallets': papers.length},
    );
  }

  Future<bool> loadArt() async {
    print("BOPCentral.loadArt");
    Uint8List bop;
    // FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["png"], withData: true);
    FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result != null) {
      PlatformFile file = result.files.first;
      print(file.name);
      print(file.size);
      if (!file.name.endsWith(".bop")) {
        await this.logFirebaseEvent(
          name: 'wrong_art_file',
        );
        return false;
      }
      bop = file.bytes;
      print("BopCentral.loadArt bytes length: " + bop.lengthInBytes.toString());
      await this.logFirebaseEvent(
        name: 'arteditor_load_art',
        parameters: <String, dynamic>{'size': file.size},
      );
    } else {
      print("BOPentral.loadArt cancelled");
    }
    print("BOPCentral.loadArt");
    Art art = await Art.createFromBOP(bop);
    art.setDemoWallet(Wallets.demoWallet);
    await art.updateDemoOverlay();
    this.arts.addArt(art);
    // this.papers.setSelectedArt(art);
    return true;
  }
}
