import 'package:bop/ui/bopInherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bop/graphic/papers.dart';
import 'package:bop/ui/waiting.dart';

const double mainWidth = 860;

class ArtPrint extends StatefulWidget {
  final Papers papers;
  ArtPrint(this.papers, Key key) : super(key: key);

  @override
  State<ArtPrint> createState() {
    return _ArtPrintState();
  }
}

class _ArtPrintState extends State<ArtPrint> {
  int _index = 0;

  _ArtPrintState();

  @override
  void initState() {
    super.initState();
  }

  Future _printWallets(BuildContext context) async {
    print("artPrint.printWallets");
    Navigator.of(context).push(WaitingOverlay(AppLocalizations.of(context).message_waitingprint));
    await Future.delayed(const Duration(milliseconds: 300), () {});
    int s = DateTime.now().millisecondsSinceEpoch;
    await BOPInherited.of(context).bopCentral.printWallets(context);
    print("artPrint.printWallets PDF printed in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    //Remove the alert
    Navigator.of(context).pop();
    //Close the menu
    Navigator.of(context).pop();
  }

  Future<void> _exportWalletsToPDF(BuildContext context) async {
    print("artPrint.exportWalletsToPDF");
    Navigator.of(context).push(WaitingOverlay(AppLocalizations.of(context).message_waitingpdf));
    await Future.delayed(const Duration(milliseconds: 300), () {});
    int s = DateTime.now().millisecondsSinceEpoch;
    await BOPInherited.of(context).bopCentral.exportWalletsToPDF(context);
    print("artPrint.exportWalletsToPDF PDF exported in (millis):" + (DateTime.now().millisecondsSinceEpoch - s).toString());
    //Remove the alert
    Navigator.of(context).pop();
    //Close the menu
    Navigator.of(context).pop();
  }

  bool canMoveForward() {
    return this._index < widget.papers.length - 1;
  }

  bool canMoveBack() {
    return this._index > 0;
  }

  @override
  Widget build(BuildContext context) {
    // Widget toolbar = buildToolbar(context);
    if (widget.papers == null) return Container(child: Text("ops..."));
    Widget list = Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // toolbar,
            _buildPrintPreview(context),
            _buildButtons(context),
          ],
        ),
      ),
    );
    return SingleChildScrollView(
      child: list,
    );
  }

  Widget _buildPrintPreview(BuildContext context) {
    Paper paper = widget.papers.getPaperAt(this._index);
    TextStyle flavTextStyle = Theme.of(context).textTheme.headline6;
    print("artPrint.buildPrintPreview");
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
      width: mainWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int w = paper.art.width;
          int h = paper.art.height;
          double mw = constraints.maxWidth;
          double mh = (mw / w) * h;
          //The column here is just to make the card shrink to its content
          return Card(
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints.expand(height: mh, width: mw),
                  margin: EdgeInsets.all(4),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(child: Image(image: MemoryImage(paper.art.template), fit: BoxFit.scaleDown)),
                      ),
                      Positioned.fill(
                        child: Center(child: Image(image: MemoryImage(paper.overlayBytes), fit: BoxFit.scaleDown)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(4, 0, 4, 4),
                  constraints: BoxConstraints(minWidth: 200, minHeight: 40),
                  width: mw,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.blueGrey[300], width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: SelectableText.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: (this._index + 1).toString() + ": ", style: flavTextStyle),
                          TextSpan(text: paper.art.name.toUpperCase(), style: flavTextStyle),
                          TextSpan(text: " " + paper.art.subname.toUpperCase() + "\n", style: flavTextStyle),
                          TextSpan(text: AppLocalizations.of(context).screenPrint_address + ": " + paper.wallet.publicAddress + "\n", style: flavTextStyle),
                          TextSpan(text: AppLocalizations.of(context).screenPrint_key + ": " + paper.wallet.privateKey + "\n\n", style: flavTextStyle),
                          TextSpan(text: AppLocalizations.of(context).screenPrint_check, style: flavTextStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.picture_as_pdf, semanticLabel: AppLocalizations.of(context).menu_exportPDF),
              tooltip: AppLocalizations.of(context).screenWallets_delete,
              onPressed: () async {
                await _exportWalletsToPDF(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.print, semanticLabel: AppLocalizations.of(context).menu_print),
              tooltip: AppLocalizations.of(context).screenWallets_delete,
              onPressed: () async {
                await _printWallets(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
