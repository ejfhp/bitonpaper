import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'state.dart';

class Art {
  String name;
  String file;
  String baseUrl;
  double height;
  double width;
  ArtElement pkQr;
  ArtElement pk;
  ArtElement adQr;
  ArtElement ad;

  String get url {
    return baseUrl + "/" + file;
  }
}

class ArtElement {
  double top;
  double left;
  double height;
  double width;
  double size;
  double rotation;
  bool visible;
}

Future<void> getArts(BitOnPaperState state, String baseUrl) async {
  var response = await http.get(baseUrl + "/arts.json");
  if (response.statusCode == 200) {
    List<dynamic> artList =
        (convert.jsonDecode(response.body) as List).cast<String>();
    artList.forEach((el) {
      print("Getting Art: " + el);
      getArt(state, baseUrl, el);
    });
  } else {
    print('GetArts request failed with status: ${response.statusCode}.');
  }
}

Future<void> getArt(BitOnPaperState state, String baseUrl,  String confFile) async {
  var response = await http.get(baseUrl + "/" + confFile);
  if (response.statusCode == 200) {
    Map<String, dynamic> artList =
        (convert.jsonDecode(response.body) as Map).cast<String, dynamic>();
    Art art = Art();
    art.baseUrl = baseUrl;
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
    state.addArt(art.name, art);
  } else {
    print('GetArt request failed with status: ${response.statusCode}.');
  }
}

ArtElement readElement(dynamic val) {
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
      default:
    }
  });
  return ae;
}
