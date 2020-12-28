import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'artMenu.dart';
import 'toolMenu.dart';
import 'artSheet.dart';

//Main StatefulWidget
class BOP extends StatefulWidget {
  @override
  BOPState createState() => BOPState();
}

//Main StatelessWidget
class BOPUI extends StatelessWidget {
  final BOPState state;

  BOPUI(this.state);

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
      backgroundColor: Colors.white,
      drawer: MenuInh(child: Menu(), state: state),
      endDrawer: ToolMenuInh(child: ToolMenu(), state:state),
      body: Sheet(child: WalletSheet(), state: state),
    );
  }
}
