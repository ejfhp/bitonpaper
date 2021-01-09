import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BOPState.dart';
import 'conf.dart';
import 'html_print.dart';

class ToolMenuInh extends InheritedWidget {
  final BOPState state;
  ToolMenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant ToolMenuInh oldWidget) {
    return oldWidget.state.wip != state.wip;
  }

  static ToolMenuInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToolMenuInh>();
  }
}

class ToolMenu extends StatelessWidget {
  final bool wide;
  ToolMenu({@required this.wide});

  Widget build(BuildContext context) {
    BOPState state = ToolMenuInh.of(context).state;
    List<Widget> toolsList = new List<Widget>.empty(growable: true);
    Container containerHeader = Container(
      height: HEADER_HEIGHT,
      padding: EdgeInsets.all(0),
      child: DrawerHeader(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: Container(
            color: Colors.blueGrey,
            padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
            alignment: Alignment.bottomRight,
            child: Text(
              "Tools",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.amber,
                fontFamily: "Roboto",
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          )),
    );
    toolsList.add(containerHeader);
    toolsList.add(numWalletsBox(context: context, state: state));
    toolsList.add(printBox(context: context, state: state));
    toolsList.add(pdfBox(context: context, state: state));
    ListView commands = ListView(children: toolsList);

    return Drawer(
      elevation: 0,
      child: commands,
    );
  }

  Widget numWalletsBox({BuildContext context, BOPState state}) {
    return Container(
        padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
        child: Column(
          children: [
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: state.numWalletsController,
              maxLength: 2,
              onEditingComplete: () async {
                await state.updateWallets();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "wallets (max 10)",
              ),
            ),
          ],
        ));
  }

  Widget printBox({BuildContext context, BOPState state}) {
    return Container(
        padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
        child: Column(
          children: [
            Container(
              child: RaisedButton(
                onPressed: () async {
                  PrintSheet print = PrintSheet(state);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => print,
                      ));
                  print.preparePrintPreview(3);
                  await Future.delayed(const Duration(seconds: 5), () {});
                  print.showPrintPreview();
                  await Future.delayed(const Duration(seconds: 1), () {});
                  Navigator.pop(context);
                },
                color: Colors.blueGrey,
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: const Text('Print', style: TextStyle(fontSize: 20, color: Colors.amber)),
              ),
              padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
            ),
          ],
        ));
  }

  Widget pdfBox({BuildContext context, BOPState state}) {
    return Container(
        padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
        child: Column(
          children: [
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: state.walletsPerPageController,
              maxLength: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "wallets per page",
              ),
            ),
            if (state.wip == WIP_PRINTING)
              RichText(
                  text: TextSpan(
                text: "Be patient, PDF generation takes a while...",
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "Roboto",
                ),
              )),
            Container(
              child: RaisedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  state.printPapers();
                },
                color: Colors.blueGrey,
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: const Text('Generate', style: TextStyle(fontSize: 20, color: Colors.amber)),
              ),
              padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
            ),
          ],
        ));
  }
}
