import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'dart:ui' as ui;
import 'BOPState.dart';

Future<void> loadArts(BOPState state, String baseUrl) async {
  var response = await http.get(baseUrl + "/arts.json");
  if (response.statusCode == 200) {
    List<dynamic> artList = (convert.jsonDecode(response.body) as List).cast<String>();
    artList.forEach((el) {
      print("Loading Art: " + el);
      Art.loadFromUrl(baseUrl: baseUrl, name: el, state: state);
    });
  } else {
    print('GetArts request failed with status: ${response.statusCode}.');
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
  String name;
  String file;
  ui.Image image;
  double height;
  double width;
  ArtElement pk;
  ArtElement pkQr;
  ArtElement ad;
  ArtElement adQr;

  static loadFromUrl({String baseUrl, String name, BOPState state}) {
    print("Art http.get");
    Art art = Art();
    http.get(baseUrl + "/" + name).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> artList = (convert.jsonDecode(response.body) as Map).cast<String, dynamic>();
        artList.forEach((k, val) {
          switch (k) {
            case "name":
              art.name = val as String;
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
        print('GetArt request failed with status: ${response.statusCode}.');
      }
      return art;
    }).then((art) {
      Completer<ImageInfo> completer = Completer();
      var img = new NetworkImage(baseUrl + "/" + art.file);
      ImageConfiguration imgConf = ImageConfiguration();
      ImageStream imgStream = img.resolve(imgConf);
      imgStream.addListener(ImageStreamListener((ImageInfo info, bool syncro) {
        completer.complete(info);
      }));
      return completer.future;
    }).then((imageInfo) {
      art.image = imageInfo.image;
      state.addArt(art);
    }).catchError((err) {
      print(err);
    });
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
