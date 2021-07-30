import 'dart:typed_data';
import 'package:bop/io/external_abstract.dart' if (dart.library.io) 'package:bop/io/external_io.dart' if (dart.library.js) 'package:bop/io/external_web.dart';

const PLATFORM_WEB = 1;
const PLATFORM_ANDROID = 2;

Future openDownload(Uint8List data, String mime, String fileName) async {
  await openDownloadImpl(data, mime, fileName);
}

Future<String> scan() async {
  return await scanImpl();
}

int getPlatform() {
  return getPlatformImpl();
}
