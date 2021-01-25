import 'dart:typed_data';
import 'dart:html' as html;

void openDownload(Uint8List data, String mime, String fileName) {
  final blob = html.Blob([data], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body.children.add(anchor);
  anchor.click();
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
