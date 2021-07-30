import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:bop/graphic/art.dart';
import 'package:bop/graphic/walletPainter.dart';
import 'package:bop/conf.dart';

class Arts {
  //Default arts are loaded in reverse order
  Set<String> _localArts = {
    "art_bitcoin-blue.bop",
    "art_bitcoin-bop.bop",
    "art_bitcoin-gold.bop",
    "art_bsvdragon-yellow.bop",
    "art_intro-de.bop",
    "art_intro-en.bop",
    "art_intro-it.bop",
    "art_spare-kurt.bop",
    "art_tipme-1.bop",
    "bsvbank_craig.bop",
    "bsvbank_greg.bop",
    "bsvbank_jimmy.bop",
    "bsvbank_shadders.bop",
    "deepthawtz_bananacat.bop",
    "diego_craigissatoshi.bop",
    "handcash_duro.bop",
    "inkstr_banana.bop",
    "k_banana.bop",
    "korppi_banana.bop",
    "maria_bananatime.bop",
    "slasher_banana.bop",
    "tanius_psychobananas.bop",
    "tony_bananas.bop",
    "art_hidden-T4L3.bop",
    "art_hongbao-cab.bop",
    "art_hongbao-ox.bop",
    "art_spare-pegacrick.bop"
  };
  final Map<String, Art> _artsCache = Map<String, Art>();
  final List<String> _artsname = List<String>.empty(growable: true);
  static final WalletPainter walletPainter = WalletPainter();

  Arts._();

  int getLength() {
    print("Arts.getLength");
    return _artsCache.length;
  }

  int getNamesLength() {
    return this._artsname.length;
  }

  static Future<Arts> loadArts() async {
    print("Arts.loadArts");
    Arts arts = Arts._();
    Iterator it = arts._localArts.iterator;
    while (it.moveNext()) {
      String filename = it.current;
      Art art = await arts.loadFromAsset(folder: ART_FOLDER, filename: filename);
      arts.addArt(art);
    }
    return arts;
  }

  Future addArt(Art art) async {
    assert(art != null);
    this._artsCache[art.name + " " + art.subname] = art;
    this._artsname.add(art.name + " " + art.subname);
    return;
  }

  Art get first {
    return this._artsCache.values.first;
  }

  String getName(int index) {
    return this._artsname[index];
  }

  List<String> getNames() {
    return this._artsname;
  }

  Art getArt({@required String name}) {
    return this._artsCache[name];
  }

  Future<Art> loadFromAsset({@required String folder, @required String filename}) async {
    try {
      print("Arts.loadFromAsset folder: $folder  filename:$filename");
      String assetName = folder + "/" + filename;
      ByteData artZip = await rootBundle.load(assetName);
      Art art = await Art.createFromBOP(artZip.buffer.asUint8List());
      art.setDemoWallet(Wallets.demoWallet);
      await art.updateDemoOverlay();
      return art;
    } catch (e, s) {
      print('Arts.loadFromAsset cannot load $filename: $e \n$s');
      throw e;
    }
  }
}
