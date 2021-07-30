import 'dart:typed_data';

Future openDownloadImpl(Uint8List data, String mime, String fileName) async {
  throw UnsupportedError('external_abstract.dart openDownloadImpl implementation not found');
}

Future<String> scanImpl() async {
  throw UnsupportedError('external_abstract.dart scanKeyImpl implementation not found');
}

int getPlatformImpl() {
  throw UnsupportedError('external_abstract.dart getPlatformImpl implementation not found');
}
