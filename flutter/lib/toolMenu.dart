import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'print.dart';


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
    DrawerHeader header = DrawerHeader(
        child: Text("Print to PDF"),
    );

    Column commands = Column(
      children: [
        header,
        FlatButton(onPressed: () {printWallets(context); }, child: Text("Export to PDF"))
      ]
    );
    return Drawer(
      child: commands,
    );
  }

  Future<void> printWallets(context) async {
    BOPState appState = ToolMenuInh.of(context).state;
    // appState.refreshWallet(3);
    await toPDF(art: appState.getSelectedArt(), wallets: appState.getWallets());
  }
}

