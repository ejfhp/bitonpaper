import 'package:flutter/material.dart';
import 'paperPageState.dart';
import 'paperPageMenu.dart';
import 'paperPageToolMenu.dart';
import 'paperPageSheet.dart';

//Main StatefulWidget
class PaperPage extends StatefulWidget {
  @override
  PaperPageState createState() => PaperPageState();
}

//Main StatelessWidget
class PaperPageUI extends StatelessWidget {
  final PaperPageState state;

  PaperPageUI(this.state);

  @override
  Widget build(BuildContext context) {
    BottomAppBar bottomBar = BottomAppBar(
        color: Colors.blueGrey,
        child: Text(
          "Works only on Bitcoin (SV). Use at your own risk. See the running code on Github.",
          textAlign: TextAlign.center,
        ));
    AppBar topBar = AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.network(
        "./icons/bop_long.png",
        fit: BoxFit.contain,
        height: 40,
      )
    ]));

    return Scaffold(
      appBar: topBar,
      bottomNavigationBar: bottomBar,
      drawer: MenuInh(child: Menu(), state: state),
      endDrawer: ToolMenuInh(child: ToolMenu(), state:state),
      body: Sheet(child: WalletSheet(), state: state),
    );
  }
}
