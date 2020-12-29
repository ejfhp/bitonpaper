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
          "Use at your own risk.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.blueGrey[200], fontFamily: "Roboto"),
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
      endDrawer: ToolMenuInh(child: ToolMenu(), state: state),
      body: Sheet(child: WalletSheet(), state: state),
    );
  }
}
