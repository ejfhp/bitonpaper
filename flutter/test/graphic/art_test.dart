// Import the test package and Counter class
import 'dart:convert' as convert;
import 'dart:io' as io;
import 'package:test/test.dart';
import 'package:flutter/material.dart';
import 'package:bop/graphic/art.dart';
import 'package:bop/bitcoin/wallets.dart';

void main() {
  group("ArtElement", () {
    test('Create', () {
      final artElement = ArtElement(ArtElement.ELEMENT_TOP);
      expect(artElement.name.length, greaterThan(0));
    });
    test('toJson', () {
      final artElement = ArtElement(ArtElement.ELEMENT_TOP);
      artElement.size = 300;
      artElement.left = 430;
      artElement.top = 10;
      artElement.rotation = 90;
      artElement.visible = false;
      artElement.fgcolor = Color(0xFFFF0000);
      artElement.bgcolor = Color(0xFF00FF00);
      String json = convert.jsonEncode(artElement);
      expect(json, equals('{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false}'));
    });
    test('fromJson', () {
      Map artElMap = convert.jsonDecode('{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false}');
      ArtElement artElement = ArtElement.fromJson(artElMap);
      expect(artElement.size, equals(300));
      expect(artElement.left, equals(430));
      expect(artElement.top, equals(10));
      expect(artElement.rotation, equals(90));
      expect(artElement.visible, equals(false));
      expect(artElement.fgcolor, equals(Color(0xFFFF0000)));
      expect(artElement.bgcolor, equals(Color(0xFF00FF00)));
    });
  });

  group("Art", () {
    test('Create', () {
      final art = Art();
      expect(art.name.length, greaterThan(0));
    });
    test('toJson', () {
      final art = Art();
      ArtElement ad = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_AD, rotation: -100, size: 12, visible: false);
      ArtElement adqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_ADQR, rotation: -100, size: 12, visible: false);
      ArtElement pkqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PKQR, rotation: -100, size: 12, visible: false);
      ArtElement pk = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PK, rotation: -100, size: 12, visible: false);
      art.setElement(Art.ART_AD, ad);
      art.setElement(Art.ART_ADQR, adqr);
      art.setElement(Art.ART_PK, pk);
      art.setElement(Art.ART_PKQR, pkqr);
      art.width = 800;
      art.height = 600;
      art.name = "json";
      art.subname = "encode";
      String json = convert.jsonEncode(art);
      expect(json.contains(Art.ART_PK), equals(true));
      expect(json.contains(Art.ART_PKQR), equals(true));
      expect(json.contains(Art.ART_AD), equals(true));
      expect(json.contains(Art.ART_ADQR), equals(true));
      expect(json.contains(Art.ART_HEIGHT), equals(true));
      expect(json.contains(Art.ART_WIDTH), equals(true));
      expect(json.contains(Art.ART_NAME), equals(true));
      expect(json.contains(Art.ART_SUBNAME), equals(true));
      expect(json.contains(ArtElement.ELEMENT_BGC), equals(true));
    });
    test('fromJson', () {
      Map artElMap = convert.jsonDecode(
          '{"privkey":{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false},"privkey_qr":{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false},"address":{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false},"address_qr":{"top":10,"left":430,"size":300,"rotation":90,"fgcolor":"ffff0000","bgcolor":"ff00ff00","visible":false},"name":"json","subname":"decode","width":800,"height":600}');
      Art art = Art.fromJson(artElMap);
      expect(art.name, equals("json"));
      expect(art.subname, equals("decode"));
      expect(art.width, equals(800));
      expect(art.height, equals(600));
      expect(art.getElement(Art.ART_AD).left, equals(430));
      expect(art.getElement(Art.ART_ADQR).top, equals(10));
      expect(art.getElement(Art.ART_PK).rotation, equals(90));
      expect(art.getElement(Art.ART_PKQR).visible, equals(false));
      expect(art.getElement(Art.ART_PKQR).fgcolor, equals(Color(0xFFFF0000)));
      expect(art.getElement(Art.ART_ADQR).bgcolor, equals(Color(0xFF00FF00)));
    });
    test('fromBOP', () async {
      List<int> bopBytes = await io.File('./test/testdata/test.bop').readAsBytes();
      Art art = await Art.createFromBOP(bopBytes);
      expect(art.name, equals("Bitcoin"));
      expect(art.subname, equals("Blue"));
      expect(art.width, equals(1600));
      expect(art.height, equals(860));
      expect(art.getElement(Art.ART_AD).left, equals(390));
      expect(art.getElement(Art.ART_ADQR).top, equals(80));
      expect(art.getElement(Art.ART_PK).rotation, equals(-90));
      expect(art.getElement(Art.ART_PKQR).visible, equals(true));
      expect(art.getElement(Art.ART_PKQR).fgcolor, equals(Color(0xff0067ea)));
      expect(art.getElement(Art.ART_ADQR).bgcolor, equals(Color(0xffffffff)));
      expect(art.template, isNotNull);
    });
    test('toBOP', () async {
      final art = Art();
      ArtElement ad = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_AD, rotation: -100, size: 12, visible: false);
      ArtElement adqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_ADQR, rotation: -100, size: 12, visible: false);
      ArtElement pkqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PKQR, rotation: -100, size: 12, visible: false);
      ArtElement pk = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PK, rotation: -100, size: 12, visible: false);
      art.setElement(Art.ART_AD, ad);
      art.setElement(Art.ART_ADQR, adqr);
      art.setElement(Art.ART_PK, pk);
      art.setElement(Art.ART_PKQR, pkqr);
      art.width = 800;
      art.height = 600;
      art.name = "json";
      art.subname = "encode";
      List<int> artTemplate = await io.File('./test/testdata/art.png').readAsBytes();
      await art.setImage(artTemplate);
      List<int> bop = art.exportToBOP();
      expect(bop, isNotNull);
      expect(bop.length, greaterThan(200));
    });
    test('toBOPAndback', () async {
      final source = Art();
      ArtElement ad = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_AD, rotation: -100, size: 12, visible: false);
      ArtElement adqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_ADQR, rotation: -100, size: 12, visible: false);
      ArtElement pkqr = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PKQR, rotation: -100, size: 12, visible: false);
      ArtElement pk = ArtElement.fromValues(top: 10, left: 20, name: Art.ART_PK, rotation: -100, size: 12, visible: false);
      source.setElement(Art.ART_AD, ad);
      source.setElement(Art.ART_ADQR, adqr);
      source.setElement(Art.ART_PK, pk);
      source.setElement(Art.ART_PKQR, pkqr);
      source.width = 800;
      source.height = 600;
      source.name = "FromBOP";
      source.subname = "ToBOP";
      List<int> artTemplate = await io.File('./test/testdata/art.png').readAsBytes();
      await source.setImage(artTemplate);
      List<int> bopBytes = source.exportToBOP();
      Art art = await Art.createFromBOP(bopBytes);
      expect(art.name, equals("FromBOP"));
      expect(art.subname, equals("ToBOP"));
      expect(art.width, equals(1600));
      expect(art.height, equals(860));
      expect(art.getElement(Art.ART_AD).left, equals(20));
      expect(art.getElement(Art.ART_ADQR).top, equals(10));
      expect(art.getElement(Art.ART_PK).rotation, equals(-100));
      expect(art.getElement(Art.ART_PKQR).visible, equals(false));
      expect(art.getElement(Art.ART_PKQR).fgcolor, equals(Color(0xff000000)));
      expect(art.getElement(Art.ART_ADQR).bgcolor, equals(Color(0xffffffff)));
      expect(art.template, isNotNull);
    });
  });
}
