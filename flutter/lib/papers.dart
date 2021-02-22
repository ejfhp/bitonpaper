import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bitonpaper/walletPainter.dart';
import 'package:bitonpaper/arts.dart';
import 'package:bitonpaper/wallets.dart';

class Papers {
  List<Art> _selectedArts = List<Art>.empty(growable: true);
  Map<Wallet, Art> _papersMap = Map<Wallet, Art>();
  Rasterizer _rasterizer = Rasterizer();

  Papers(Wallet wallet, Art art) {
    assert(art != null);
    assert(wallet != null);
    this.select(art);
    this.savePaper(wallet: wallet, art: art);
  }

  Future<Paper> willGeneratePaper({@required Wallet wallet, @required Future<Art> futureArt}) async {
    Art art = await futureArt;
    Uint8List bytes = await _rasterizer.rasterize(wallet: wallet, art: art);
    Paper p = Paper(wallet: wallet, art: art, overlayBytes: bytes);
    return p;
  }

  Future<Paper> generatePaper({@required Wallet wallet, @required Art art}) async {
    Uint8List bytes = await _rasterizer.rasterize(wallet: wallet, art: art);
    Paper p = Paper(wallet: wallet, art: art, overlayBytes: bytes);
    return p;
  }

  Future<Paper> getPaper({@required Wallet wallet}) async {
    Art art = this._papersMap[wallet];
    assert(art != null);
    Uint8List bytes = await _rasterizer.rasterize(wallet: wallet, art: art);
    Paper p = Paper(wallet: wallet, art: art, overlayBytes: bytes);
    return p;
  }

  savePaper({@required Wallet wallet, @required Art art}) {
    this._papersMap[wallet] = art;
  }

  Iterator<Wallet> get iterator {
    return this._papersMap.keys.iterator;
  }

  void select(Art art) {
    _selectedArts.clear();
    _selectedArts.add(art);
    Iterator<Wallet> ita = this.iterator;
    while (ita.moveNext()) {
      this._papersMap[ita.current] = art;
    }
  }

  bool isSelected(Art art) {
    return _selectedArts.contains(art);
  }

  Iterator<Art> get selected {
    return _selectedArts.iterator;
  }

  List<Wallet> list() {
    List<Wallet> ws = List<Wallet>.empty(growable: true);
    this._papersMap.keys.forEach((k) {
      ws.add(k);
    });
    print("papers.dart list size:" + ws.length.toString());
    return ws;
  }

  Art get selectedFirst {
    return _selectedArts.first;
  }

  int get length {
    return this._papersMap.length;
  }

  void deletePaper(Wallet w) {
    this._papersMap.remove(w);
  }
}

class Paper {
  final Art art;
  final Wallet wallet;
  final Uint8List overlayBytes;
  String artCode;
  int _height;
  int _width;

  Paper({@required this.wallet, @required this.art, @required this.overlayBytes}) {
    assert(this.wallet != null);
    assert(this.overlayBytes != null);
    assert(art != null);
    this.artCode = art.code;
    this._height = art.height;
    this._width = art.width;
  }

  int get height {
    return this._height;
  }

  int get width {
    return this._width;
  }
}
