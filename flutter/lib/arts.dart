import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:ui' as ui;
import 'conf.dart';

class Arts {
  Map<String, List<String>> _artMap = {
    "bitcoin": ["gold", "lime", "blue", "fire", "viola", "bop"],
    "bsvdragon": ["yellow"],
    "hongbao": ["cab", "ox"],
    "intro": ["en", "it", "de"],
    "spare": ["kurt", "pegacrick"],
    "tipme": ["1"],
    "hidden": ["T1L1", "T2L4", "T2L5", "T3L3", "T4L3", "T4L5", "T5L2"],
  };
  List<String> _artIndex = List<String>.empty(growable: true);
  final Map<String, Map<String, FutureOr<Art>>> _artsCache = Map<String, Map<String, FutureOr<Art>>>();
  final String defaultKind = "bitcoin";
  final String defaultFlavour = "gold";

  Arts() {
    _artMap.forEach((key, value) {
      _artIndex.add(key);
    });
  }

  int getLength() {
    int len = 0;
    for (int i = 0; i < _artMap.length; i++) {
      len += _artMap[i].length;
    }
    return len;
  }

  int getLengthKinds() {
    return _artMap.length;
  }

  int getLengthFlavours(String kind) {
    return _artMap[kind].length;
  }

  // loadArts() async {
  //   this._artMap.forEach((kind, mapFlavours) {
  //     List<String> keys = this._artMap.keys;
  //     for (int i = 0;i < keys.length; i++) {
  //       for (int j= 0; j < keys[i].length
  //       Art art = await Art.loadFromAsset(folder: ART_FOLDER, kind: keys[i], this._artMap[keys[i]].[, flavour: flavour);
  //       this._artsCache[kind][flavour] = art;
  //     },});
  //   });
  // }

  String getKindName(int index) {
    return this._artIndex[index];
  }

  String getFlavourName(String kind, int index) {
    return this._artMap[kind][index];
  }

  List<String> getAvailableFlavours(String kind) {
    return this._artsCache[kind].keys.toList(growable: false);
  }

  List<String> getAvailableKinds() {
    return this._artsCache.keys.toList(growable: false);
  }

  FutureOr<Art> getArt({@required String kind, @required String flavour}) {
    if (!this._artsCache.containsKey(kind)) {
      this._artsCache[kind] = Map<String, FutureOr<Art>>();
    }
    if (this._artsCache[kind][flavour] == null) {
      FutureOr<Art> art = Art.loadFromAsset(folder: ART_FOLDER, kind: kind, flavour: flavour);
      this._artsCache[kind][flavour] = art;
    }
    return this._artsCache[kind][flavour];
  }

  FutureOr<Art> getDefault() {
    if (!this._artsCache.containsKey(defaultKind)) {
      this._artsCache[defaultKind] = Map<String, Future<Art>>();
    }
    if (this._artsCache[defaultKind][defaultFlavour] == null) {
      Future<Art> art = Art.loadFromAsset(folder: ART_FOLDER, kind: defaultKind, flavour: defaultFlavour);
      this._artsCache[defaultKind][defaultFlavour] = art;
    }
    return this._artsCache[defaultKind][defaultFlavour];
  }
}

class Art {
  String kind;
  String flavour;
  String name = "miró";
  String subname = "cherry";
  Uint8List _template;
  int height;
  int width;
  ArtElement pk;
  ArtElement pkQr;
  ArtElement ad;
  ArtElement adQr;

  Uint8List get bytes {
    return _template;
  }

  String get code {
    return kind + "|" + flavour;
  }

  static Future<Art> loadFromUrl({@required String baseUrl, @required String kind, @required String flavour}) async {
    log("loadFromAsset " + kind + " " + flavour);
    Art art = Art();
    http.Response respJ = await http.get(baseUrl + "/" + Art._getArtBaseFileName(kind, flavour) + ".json");
    if (respJ.statusCode == 200) {
      Map<String, dynamic> artList = (convert.jsonDecode(respJ.body) as Map).cast<String, dynamic>();
      art.kind = kind;
      art.flavour = flavour;
      artList.forEach((k, val) {
        switch (k) {
          case "name":
            art.name = val as String;
            break;
          case "subname":
            art.subname = val as String;
            break;
          case "height":
            art.height = val as int;
            break;
          case "width":
            art.width = val as int;
            break;
          case "privkey_qr":
            art.pkQr = readElement(val);
            break;
          case "privkey":
            art.pk = readElement(val);
            break;
          case "address_qr":
            art.adQr = readElement(val);
            break;
          case "address":
            art.ad = readElement(val);
            break;
          default:
        }
      });
    } else {
      log('Arts ' + kind + ' ' + flavour + ' request failed with status: ' + respJ.statusCode.toString());
      // throw Exception('Arts json request for ' + name +' failed with status: ' + respJ.statusCode.toString());
      return null;
    }
    art._template = await loadImageFromURL(baseUrl + "/" + Art._getArtBaseFileName(kind, flavour) + ".png");
    return art;
  }

  static Future<Uint8List> loadImageFromURL(String url) async {
    http.Response respP = await http.get(url);
    if (respP.statusCode == 200) {
      Uint8List bytes = respP.bodyBytes; //Uint8List
      return bytes;
    } else {
      log('Arts image from url ' + url + ' request failed with status: ' + respP.statusCode.toString());
      // throw Exception('Arts png request for ' + name +' failed with status: ' + respP.statusCode.toString());
      return null;
    }
  }

  static Future<Art> loadFromAsset({@required String folder, @required String kind, @required flavour}) async {
    log("loadFromAsset " + kind + " " + flavour);
    Art art = Art();
    try {
      String artJson = await rootBundle.loadString(folder + "/" + Art._getArtBaseFileName(kind, flavour) + ".json");
      Map<String, dynamic> artList = (convert.jsonDecode(artJson) as Map).cast<String, dynamic>();
      art.kind = kind;
      art.flavour = flavour;
      artList.forEach((k, val) {
        switch (k) {
          case "name":
            art.name = val as String;
            break;
          case "flavour":
            art.flavour = val as String;
            break;
          case "height":
            art.height = val as int;
            break;
          case "width":
            art.width = val as int;
            break;
          case "privkey_qr":
            art.pkQr = readElement(val);
            break;
          case "privkey":
            art.pk = readElement(val);
            break;
          case "address_qr":
            art.adQr = readElement(val);
            break;
          case "address":
            art.ad = readElement(val);
            break;
          default:
        }
      });
      art._template = await loadImageFromBundle(folder + "/" + Art._getArtBaseFileName(kind, flavour) + ".png");
    } catch (e) {
      log('Arts ' + kind + ' ' + flavour + 'not found ' + e);
      // throw Exception('Arts ' + name + 'not found ' + e);
      return null;
    }
    return art;
  }

  static Future<Uint8List> loadImageFromBundle(String key) async {
    try {
      ByteData artByte = await rootBundle.load(key);
      Uint8List bytes = artByte.buffer.asUint8List(); //Uint8List
      return bytes;
    } catch (e) {
      log('Arts image from bundle ' + key + ' request failed');
      // throw Exception('Arts ' + name + 'not found ' + e);
      return null;
    }
  }

  static ArtElement readElement(dynamic val) {
    Map<String, dynamic> element = (val as Map).cast<String, dynamic>();
    ArtElement ae = ArtElement();
    element.forEach((key, val) {
      switch (key) {
        case "top":
          ae.top = val as int;
          break;
        case "left":
          ae.left = val as int;
          break;
        case "height":
          ae.height = val as int;
          break;
        case "width":
          ae.width = val as int;
          break;
        case "size":
          ae.size = val as int;
          break;
        case "rotation":
          ae.rotation = val as int;
          break;
        case "visible":
          ae.visible = val as bool;
          break;
        case "fgcolor":
          ae.fgcolor = ui.Color(int.parse("0x" + val));
          break;
        case "bgcolor":
          ae.bgcolor = ui.Color(int.parse("0x" + val));
          break;
        default:
      }
    });
    return ae;
  }

  static String _getArtBaseFileName(String kind, String flavour) {
    return "art_" + kind + "-" + flavour;
  }
}

class ArtElement {
  int top = 0;
  int left = 0;
  int height = 0;
  int width = 0;
  int size = 0;
  int rotation = 0;
  bool visible = true;
  ui.Color fgcolor = Colors.black;
  ui.Color bgcolor = Colors.transparent;
}
