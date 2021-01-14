import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BOPState.dart';
import 'conf.dart';

class ToolMenuInh extends InheritedWidget {
  final BOPState state;
  ToolMenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant ToolMenuInh oldWidget) {
    return (oldWidget.state.wip != state.wip) || (oldWidget.state.exportOnlyKeys != state.exportOnlyKeys);
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
    toolsList.add(Container(
      child: numWalletsBox(context: context, state: state),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    toolsList.add(Container(
      child: printBox(context: context, state: state),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    toolsList.add(Container(
      child: pdfBox(context: context, state: state),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    toolsList.add(Container(
      child: exportBox(context: context, state: state),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    ListView commands = ListView(children: toolsList);

    return Drawer(
      elevation: 0,
      child: commands,
    );
  }

  Widget numWalletsBox({BuildContext context, BOPState state}) {
    return IntrinsicWidth(
      child: Column(
        children: [
          TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: state.numWalletsController,
            textAlign: TextAlign.right,
            maxLength: 2,
            onEditingComplete: () async {
              await state.updateWallets();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "wallets (max 10)",
            ),
          ),
          TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: state.walletsPerPageController,
            textAlign: TextAlign.right,
            maxLength: 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "wallets per page",
            ),
          ),
        ],
      ),
    );
  }

  Widget printBox({BuildContext context, BOPState state}) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: RaisedButton(
              onPressed: () async {
                await state.printPapers();
              },
              color: Colors.blueGrey,
              child: const Text('Print', style: TextStyle(fontSize: 20, color: Colors.amber)),
            ),
          ),
        ],
      ),
    );
  }

  Widget pdfBox({BuildContext context, BOPState state}) {
    return IntrinsicWidth(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: RaisedButton(
            onPressed: () async {
              FocusScope.of(context).requestFocus(new FocusNode());
              await state.savePapersToPDF();
            },
            color: Colors.blueGrey,
            child: const Text('Generate PDF', style: TextStyle(fontSize: 20, color: Colors.amber)),
          ),
        ),
        if (state.wip == WIP_PDF)
          Container(
            child: RichText(
                text: TextSpan(
              text: "Be patient, PDF generation takes a while...",
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "Roboto",
              ),
            )),
          )
      ],
    ));
  }

  Widget exportBox({BuildContext context, BOPState state}) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              children: [
                RichText(
                    text: TextSpan(
                  text: "Keys only",
                  style: TextStyle(
                    color: Colors.black54,
                    fontFamily: "Roboto",
                  ),
                )),
                Checkbox(
                    value: state.exportOnlyKeys,
                    onChanged: (val) {
                      state.exportOnlyKeys = !state.exportOnlyKeys;
                    }),
              ],
            ),
          ),
          Container(
            child: RaisedButton(
              onPressed: () async {
                await state.saveKeysToTXT();
              },
              color: Colors.blueGrey,
              child: const Text('Export keys', style: TextStyle(fontSize: 20, color: Colors.amber)),
            ),
          ),
        ],
      ),
    );
  }
}
