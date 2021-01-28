import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:ui' as ui;
import 'BOPState.dart';

const String ART_FOLDER = "arts";
const List<String> artList = [
  "art_bitcoin-gold.json",
  "art_bitcoin-lime.json",
  "art_bitcoin-blue.json",
  "art_bitcoin-fire.json",
  "art_bitcoin-viola.json",
  "art_bitcoin-bop.json",
  "art_bsvdragon.json",
  "art_intro-it.json",
  "art_intro-en.json",
  "art_kurt.json",
  "art_tipme-1.json",
  "art_hidden-T1L1.json",
  "art_hidden-T2L4.json",
  "art_hidden-T2L5.json",
  "art_hidden-T3L3.json",
  "art_hidden-T4L3.json",
  "art_hidden-T4L5.json",
  "art_hidden-T5L2.json",
  "art_pegacrick.json"
];

Future<void> loadArts(BOPState state, String baseUrl) async {
  for (int i = 0; i < artList.length; i++) {
    print("ART Loading: " + artList[i]);
    Art art = await Art.loadFromAsset(ART_FOLDER, artList[i]);
    state.addArt(art);
  }
}

class ArtElement {
  double top = 0;
  double left = 0;
  double height = 0;
  double width = 0;
  double size = 0;
  double rotation = 0;
  bool visible = true;
  ui.Color fgcolor = Colors.black;
  ui.Color bgcolor = Colors.transparent;
}

class Art {
  String name = "";
  String flavour = "";
  String file;
  Uint8List _bytes;
  double height;
  double width;
  ArtElement pk;
  ArtElement pkQr;
  ArtElement ad;
  ArtElement adQr;

  Uint8List get bytes {
    return _bytes;
  }

  static Future<Art> loadFromUrl({String baseUrl, String name}) async {
    Art art = Art();
    http.Response response = await http.get(baseUrl + "/" + name);
    if (response.statusCode == 200) {
      Map<String, dynamic> artList = (convert.jsonDecode(response.body) as Map).cast<String, dynamic>();
      artList.forEach((k, val) {
        switch (k) {
          case "name":
            art.name = val as String;
            break;
          case "flavour":
            art.flavour = val as String;
            break;
          case "file":
            art.file = val as String;
            break;
          case "height":
            art.height = val as double;
            break;
          case "width":
            art.width = val as double;
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
      print('ART GetArt request failed with status: ${response.statusCode}.');
    }
    String imageFileUrl = baseUrl + "/" + art.file;
    http.Response imgResp = await http.get(imageFileUrl);
    Uint8List bytes = imgResp.bodyBytes; //Uint8List
    assert(bytes != null);
    art._bytes = bytes;
    return art;
  }

  static Future<Art> loadFromAsset(String folder, String name) async {
    Art art = Art();
    try {
      String artJson = await rootBundle.loadString(folder + "/" + name);
      Map<String, dynamic> artList = (convert.jsonDecode(artJson) as Map).cast<String, dynamic>();
      artList.forEach((k, val) {
        switch (k) {
          case "name":
            art.name = val as String;
            break;
          case "flavour":
            art.flavour = val as String;
            break;
          case "file":
            art.file = val as String;
            break;
          case "height":
            art.height = val as double;
            break;
          case "width":
            art.width = val as double;
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
      ByteData artByte = await rootBundle.load(folder + "/" + art.file);
      Uint8List bytes = artByte.buffer.asUint8List(); //Uint8List
      assert(bytes != null);
      art._bytes = bytes;
    } catch (e) {
      print(e);
      throw Exception("Arts not found: " + name);
    }
    return art;
  }

  static ArtElement readElement(dynamic val) {
    Map<String, dynamic> element = (val as Map).cast<String, dynamic>();
    ArtElement ae = ArtElement();
    element.forEach((key, val) {
      switch (key) {
        case "top":
          ae.top = val as double;
          break;
        case "left":
          ae.left = val as double;
          break;
        case "height":
          ae.height = val as double;
          break;
        case "width":
          ae.width = val as double;
          break;
        case "size":
          ae.size = val as double;
          break;
        case "rotation":
          ae.rotation = val as double;
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
}
