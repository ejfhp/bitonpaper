import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BOPState.dart';
import 'conf.dart';

class ToolMenuInh extends InheritedWidget {
  final BOPState state;
  ToolMenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant ToolMenuInh oldWidget) {
    return (oldWidget.state.exportOnlyKeys != state.exportOnlyKeys);
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
    ThemeData theme = Theme.of(context);
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
      child: numWalletsBox(context: context, state: state, theme: theme),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    toolsList.add(Container(
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
      child: printBox(context: context, state: state, theme: theme),
    ));
    toolsList.add(Container(
      child: exportBox(context: context, state: state, theme: theme),
      padding: EdgeInsets.fromLTRB(40, 30, 40, 5),
    ));
    ListView commands = ListView(children: toolsList);

    return Drawer(
      elevation: 0,
      child: commands,
    );
  }

  Widget numWalletsBox({BuildContext context, BOPState state, ThemeData theme}) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black54, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.right,
            maxLength: 2,
            style: TextStyle(fontFamily: "Roboto", color: Colors.black54),
            controller: state.numWCtrl,
            onEditingComplete: () async {
              await state.updateWallets();
            },
            onTap: () {
              state.numWCtrl.selection = TextSelection(baseOffset: 0, extentOffset: state.numWCtrl.value.text.length);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "wallets (max 10)",
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: ElevatedButton(
              onPressed: () async {
                await state.updateWallets();
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget printBox({BuildContext context, BOPState state, ThemeData theme}) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black54, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: state.wPPageCtrl,
            onTap: () {
              state.wPPageCtrl.selection = TextSelection(baseOffset: 0, extentOffset: state.wPPageCtrl.value.text.length);
            },
            textAlign: TextAlign.right,
            maxLength: 1,
            style: TextStyle(fontFamily: "Roboto", color: Colors.black54),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "wallets per page",
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: ElevatedButton(
              onPressed: () async {
                await state.printPapers();
              },
              child: const Text('Print'),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: ElevatedButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(new FocusNode());
                await state.savePapersToPDF();
              },
              child: const Text('Generate PDF'),
            ),
          ),
        ],
      ),
    );
  }

  Widget exportBox({BuildContext context, BOPState state, ThemeData theme}) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black54, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Keys only"),
                Checkbox(
                    value: state.exportOnlyKeys,
                    onChanged: (val) {
                      state.exportOnlyKeys = !state.exportOnlyKeys;
                    }),
              ],
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () async {
                await state.saveKeysToTXT();
              },
              child: const Text('Export keys'),
            ),
          ),
        ],
      ),
    );
  }
}
