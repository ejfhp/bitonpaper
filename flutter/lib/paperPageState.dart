import 'art.dart';
import 'wallet.dart';
import 'paperPage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaperPageState extends State<PaperPage> {
  Map<String, Art> arts = Map<String, Art>();
  List<Wallet> wallets = List<Wallet>.empty(growable: true);
  String selected = "bitcoin";

  PaperPageState() {
    int initialWallets = 2;
    getArts(this, "./img");
    for (int i = 0; i < initialWallets; i++) {
      Wallet w = Wallet();
      wallets.add(w);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PaperPageUI(this);
  }

  void setSelected(String sel) {
    setState(() {
      selected = sel;
    });
  }

  Art getSelectedArt() {
    return this.arts[this.selected];
  }

  void addArt(String name, Art art) async {
    setState(() {
      arts.putIfAbsent(name, () => art);
    });
  }

  Future<void> toPDF() async {
    try {
      print('getting PDF');
      Art selected = this.getSelectedArt();
      final pdf = pw.Document();
      List<pw.Widget> parts = List<pw.Widget>.empty(growable: true);
      this.wallets.forEach((w) async {
        pw.Widget part = await makePDFPart(selected, w);
        parts.add(part);
      });
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Stack(
              children: parts,
            );
          },
        ),
      );
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      print(e);
    }
  }

  Future<pw.Widget> makePDFPart(Art art, Wallet w) async {
    ImageProvider imageProvider = NetworkImage(art.url);
    final image = await flutterImageProvider(imageProvider);
    return pw.Stack(children: [
      pw.Image.provider(image),
      pw.Text("Prova"),
    ]);
  }
}
