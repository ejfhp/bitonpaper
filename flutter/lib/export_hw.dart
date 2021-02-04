import 'dart:typed_data';
import 'package:printing/printing.dart';

void openDownload(Uint8List data, String mime, String fileName) async {
  //This is a trick, but the printing plugin is the best
  //to share in memory file as it does not require a
  //filesystem to share bytes on Android.
  await Printing.sharePdf(bytes: data, filename: fileName);
}
