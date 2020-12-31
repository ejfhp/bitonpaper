import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'BOPState.dart';

class ToolMenuInh extends InheritedWidget {
  final BOPState state;
  ToolMenuInh({Widget child, this.state}) : super(child: child);

  @override
  bool updateShouldNotify(covariant ToolMenuInh oldWidget) {
    return oldWidget.state.getSelectedArt() != state.getSelectedArt();
  }

  static ToolMenuInh of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToolMenuInh>();
  }
}

class ToolMenu extends StatelessWidget {
  Widget build(BuildContext context) {
    BOPState state = ToolMenuInh.of(context).state;
    List<Widget> toolsList = new List<Widget>.empty(growable: true);
    DrawerHeader header = DrawerHeader(
        child: Container(
      color: Colors.blueGrey,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      alignment: Alignment.bottomRight,
      child: Text(
        "Tools",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: "Roboto",
          fontSize: 50,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    ));
    toolsList.add(header);
    toolsList.add(printBox(context: context, state: state));
    ListView commands = ListView(children: toolsList);

    return Drawer(
      child: commands,
    );
  }

  Widget printBox({BuildContext context, BOPState state}) {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          children: [
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: state.numWalletsController,
              maxLength: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "wallets (max 10)",
              ),
            ),
            TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: state.walletsPerPageController,
              maxLength: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "wallets per page",
              ),
            ),
            Container(
              child: RaisedButton(
                onPressed: () {
                  state.printWallets();
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
}
