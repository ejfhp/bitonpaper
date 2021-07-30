import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:bop/graphic/arts.dart';
import 'package:bop/randomNames.dart';
import 'dart:async';
import 'dart:ui' as ui;

class Art {
  static const ART_PK = "privkey";
  static const ART_PKQR = "privkey_qr";
  static const ART_AD = "address";
  static const ART_ADQR = "address_qr";
  static const ART_NAME = "name";
  static const ART_SUBNAME = "subname";
  static const ART_HEIGHT = "height";
  static const ART_WIDTH = "width";
  String name;
  String subname;
  Wallet demoWallet;
  Uint8List template;
  Uint8List _demoOverlay;
  int height;
  int width;
  int minSize;
  int maxSize;
  Map<String, ArtElement> _elements = Map<String, ArtElement>();
  int _lastChange;

  Art({this.name, this.subname}) {
    if (this.name == null || this.name.length == 0) {
      this.name = RandomNames.randomThing();
    }
    if (this.subname == null || this.subname.length == 0) {
      this.subname = RandomNames.randomAdjective();
    }
    Art.elements.forEach((element) {
      this._elements[element] = ArtElement(element);
    });
    this._changed();
  }

  Art.fromJson(Map<String, dynamic> json) {
    _readJson(json);
    this._changed();
  }

  static Future<Art> createFromBOP(List<int> fileBOP) async {
    final archive = ZipDecoder().decodeBytes(fileBOP);
    List<int> imageData;
    String jsonData;
    for (final file in archive) {
      String lowExt = file.name.toLowerCase().split(".").last;
      if (file.isFile && lowExt == "json") {
        file.decompress();
        jsonData = String.fromCharCodes(file.content as List<int>);
      } else if (file.isFile && (lowExt == "png" || lowExt == "jpg" || lowExt == "jpeg" || lowExt == "img")) {
        imageData = file.content as List<int>;
      }
    }
    if (imageData == null || jsonData == null) {
      throw Exception("incomplete BOP file");
    }
    Map<String, dynamic> json = (convert.jsonDecode(jsonData) as Map).cast<String, dynamic>();
    Art art = Art.fromJson(json);
    await art.setImage(imageData).then((value) => null);
    return art;
  }

  List<int> exportToBOP() {
    Archive archive = Archive();
    String json = convert.jsonEncode(this);
    //Content of Archive file must be List<int>
    List<int> content = convert.utf8.encode(json);
    ArchiveFile afj = ArchiveFile("config.json", content.length, content);
    print("Compress? " + afj.compress.toString());
    archive.addFile(afj);
    ArchiveFile afi = ArchiveFile("image.img", this.template.length, this.template);
    print("Compress? " + afi.compress.toString());
    archive.addFile(afi);
    print("numfiles: " + archive.numberOfFiles().toString());
    for (final file in archive) {
      print("file: " + file.name);
      print("size: " + file.size.toString());
      print("crc: " + file.crc32.toString());
      print("compression: " + file.compressionType.toString());
    }
    return ZipEncoder().encode(archive);
  }

  Map<String, dynamic> toJson() {
    return {
      ART_PK: _elements[ART_PK].toJson(),
      ART_PKQR: _elements[ART_PKQR].toJson(),
      ART_AD: _elements[ART_AD].toJson(),
      ART_ADQR: _elements[ART_ADQR].toJson(),
      ART_NAME: name,
      ART_SUBNAME: subname,
      ART_WIDTH: width,
      ART_HEIGHT: height,
    };
  }

  void _readJson(Map<String, dynamic> json) {
    if (json[ART_NAME] != null && json[ART_SUBNAME] != null && json[ART_HEIGHT] != null && json[ART_WIDTH] != null) {
      name = json[ART_NAME];
      subname = json[ART_SUBNAME];
      height = json[ART_HEIGHT];
      width = json[ART_WIDTH];
    } else {
      throw Exception('incomplete Art json');
    }
    _elements[ART_PK] = ArtElement.fromJson(json[ART_PK]);
    _elements[ART_PKQR] = ArtElement.fromJson(json[ART_PKQR]);
    _elements[ART_AD] = ArtElement.fromJson(json[ART_AD]);
    _elements[ART_ADQR] = ArtElement.fromJson(json[ART_ADQR]);
  }

  Future setImage(Uint8List bytes) async {
    print("Art.setImage");
    ui.Codec codec = await ui.instantiateImageCodec(bytes);
    if (codec.frameCount < 1) {
      throw ("Cannot read image size");
    }
    ui.FrameInfo info = await codec.getNextFrame();
    this._setHeightWidth(info.image.height, info.image.width);
    this.template = bytes;
    this._changed();
    print("Art.setImage template set");
  }

  void _setHeightWidth(int height, int width) {
    if (height > 50000 || width > 50000) {
      throw ("art.setHeightWidth image too big");
    }
    print("art.setHeightWidth width=" + width.toString() + " height=" + height.toString());
    this.height = height;
    this.width = width;
    if (this.height > this.width) {
      this.minSize = this.width;
      this.maxSize = this.height;
    } else {
      this.minSize = this.height;
      this.maxSize = this.width;
    }
  }

  void setElement(String name, ArtElement val) async {
    this._elements[name] = val;
    this._changed();
  }

  void setDemoWallet(Wallet demo) {
    this.demoWallet = demo;
    this._changed();
  }

  Future<bool> updateDemoOverlay() async {
    if (this.demoWallet != null) {
      print("Art.updateDemoOverlay");
      Uint8List bytes = await Arts.walletPainter.rasterize(wallet: this.demoWallet, art: this);
      this._demoOverlay = bytes;
      return true;
    }
    this._changed();
    return false;
  }

  Uint8List get demoOverlay {
    return this._demoOverlay;
  }

  ArtElement getElement(String name) {
    return this._elements[name];
  }

  static Set<String> get elements {
    return {ART_PK, ART_PKQR, ART_AD, ART_ADQR};
  }

  void _changed() {
    print("Art._changed");
    this._lastChange = DateTime.now().millisecondsSinceEpoch;
  }

  int get lastChange {
    return this._lastChange;
  }

  bool isEqual(Art other) {
    if (this.name != other.name) return false;
    if (this.subname != other.subname) return false;
    if (this._lastChange != other._lastChange) return false;
    if (this.width != other.width) return false;
    if (this.subname != other.subname) return false;
    this._elements.forEach((key, value) {
      if (value != other._elements[key]) return false;
    });
    return true;
  }
}

class ArtElement {
  static const ELEMENT_TOP = 'top';
  static const ELEMENT_LEFT = 'left';
  static const ELEMENT_SIZE = 'size';
  static const ELEMENT_ROTATION = 'rotation';
  static const ELEMENT_FGC = 'fgcolor';
  static const ELEMENT_BGC = 'bgcolor';
  static const ELEMENT_VISIBLE = 'visible';

  String name;
  Map<String, int> _vals = Map<String, int>();
  ui.Color _fgcolor = Colors.black;
  ui.Color _bgcolor = Colors.white;
  bool _visible = true;

  ArtElement(this.name) {
    this.properties.forEach((element) {
      this._vals[element] = 0;
    });
  }

  bool isEqual(ArtElement other) {
    if (this.name != other.name) return false;
    this._vals.forEach((key, value) {
      if (value != other._vals[key]) return false;
    });
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      ELEMENT_TOP: _vals[ELEMENT_TOP],
      ELEMENT_LEFT: _vals[ELEMENT_LEFT],
      ELEMENT_SIZE: _vals[ELEMENT_SIZE],
      ELEMENT_ROTATION: _vals[ELEMENT_ROTATION],
      ELEMENT_FGC: _fgcolor.value.toRadixString(16),
      ELEMENT_BGC: _bgcolor.value.toRadixString(16),
      ELEMENT_VISIBLE: _visible
    };
  }

  ArtElement.fromJson(Map<String, dynamic> json) {
    if (json[ELEMENT_TOP] != null && json[ELEMENT_LEFT] != null && json[ELEMENT_SIZE] != null && json[ELEMENT_ROTATION] != null) {
      _vals[ELEMENT_TOP] = json[ELEMENT_TOP];
      _vals[ELEMENT_LEFT] = json[ELEMENT_LEFT];
      _vals[ELEMENT_SIZE] = json[ELEMENT_SIZE];
      _vals[ELEMENT_ROTATION] = json[ELEMENT_ROTATION];
      _visible = true;
      _fgcolor = Colors.black;
      _bgcolor = Colors.white;
      if (json[ELEMENT_VISIBLE] != null) {
        _visible = json[ELEMENT_VISIBLE];
      }
      if (json[ELEMENT_FGC] != null) {
        _fgcolor = Color(int.parse(json[ELEMENT_FGC], radix: 16));
      }
      if (json[ELEMENT_BGC] != null) {
        _bgcolor = Color(int.parse(json[ELEMENT_BGC], radix: 16));
      }
    } else {
      throw Exception('incomplete ArtElement json');
    }
  }

  ArtElement.fromValues({this.name, int top, int left, int size, int rotation, bool visible}) {
    this._vals[ELEMENT_TOP] = top;
    this._vals[ELEMENT_LEFT] = left;
    this._vals[ELEMENT_SIZE] = size;
    this._vals[ELEMENT_ROTATION] = rotation;
    this._visible = visible;
  }

  Set<String> get properties {
    if (name == Art.ART_ADQR || name == Art.ART_PKQR) {
      return {ELEMENT_TOP, ELEMENT_LEFT, ELEMENT_SIZE, ELEMENT_ROTATION};
    }
    return {ELEMENT_TOP, ELEMENT_LEFT, ELEMENT_SIZE, ELEMENT_ROTATION};
  }

  Set<String> get colors {
    if (name == Art.ART_ADQR || name == Art.ART_PKQR) {
      return {ELEMENT_FGC, ELEMENT_BGC};
    }
    return {ELEMENT_FGC};
  }

  int get top => this._vals[ELEMENT_TOP];
  int get left => this._vals[ELEMENT_LEFT];
  int get size => this._vals[ELEMENT_SIZE];
  int get rotation => this._vals[ELEMENT_ROTATION];
  Color get fgcolor => this._fgcolor;
  Color get bgcolor => this._bgcolor;
  bool get visible => this._visible;

  set top(int v) => this._vals[ELEMENT_TOP] = v;
  set left(int v) => this._vals[ELEMENT_LEFT] = v;
  set size(int v) => this._vals[ELEMENT_SIZE] = v;
  set rotation(int v) => this._vals[ELEMENT_ROTATION] = v;
  set fgcolor(Color c) => this._fgcolor = c;
  set bgcolor(Color c) => this._bgcolor = c;
  set visible(bool c) => this._visible = c;

  void setProperty(String name, int val) {
    this._vals[name] = val;
  }

  void setColor(String name, Color color) {
    switch (name) {
      case ArtElement.ELEMENT_FGC:
        this._fgcolor = color;
        break;
      case ArtElement.ELEMENT_BGC:
        this._bgcolor = color;
        break;
    }
  }

  int getProperty(String name) {
    return this._vals[name];
  }

  Color getColor(String name) {
    switch (name) {
      case ArtElement.ELEMENT_FGC:
        return this._fgcolor;
        break;
      case ArtElement.ELEMENT_BGC:
        return this._bgcolor;
        break;
    }
    return Colors.black;
  }
}
