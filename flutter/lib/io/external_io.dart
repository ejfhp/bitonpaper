import 'dart:typed_data';
import 'package:bop/io/external.dart';
import 'package:printing/printing.dart';
import 'package:barcode_scan/barcode_scan.dart';

void openDownloadImpl(Uint8List data, String mime, String fileName) async {
  //This is a trick, but the printing plugin is the best
  //to share in memory file as it does not require a
  //filesystem to share bytes on Android.
  await Printing.sharePdf(bytes: data, filename: fileName);
}

Future<String> scanImpl() async {
  var result = await BarcodeScanner.scan();

  print(result.type); // The result type (barcode, cancelled, failed)
  print(result.rawContent); // The barcode content
  print(result.format); // The barcode format (as enum)
  print(result.formatNote); // If a unknown format was scanned this field contains a note
  return result.rawContent;
}

int getPlatformImpl() {
  return PLATFORM_ANDROID;
}
