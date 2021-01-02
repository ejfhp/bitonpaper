import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'artMenu.dart';
import 'toolMenu.dart';
import 'paperSheet.dart';

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
    final bool wideScreen = MediaQuery.of(context).size.width > this.state.artWidth + this.state.toolWidth + this.state.paperWidth;
    final bool implyBarLeading = !wideScreen;
    BottomAppBar bottomBar = BottomAppBar(
        elevation: 0,
        color: Colors.blueGrey,
        child: Text(
          "Use at your own risk.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: Colors.blueGrey[200], fontFamily: "Roboto"),
        ));
    PreferredSize topBar = PreferredSize(
      preferredSize: Size.fromHeight(this.state.headerHeight),
      child: AppBar(
          iconTheme: IconThemeData(color: Colors.amber),
          backgroundColor: Colors.red,
          automaticallyImplyLeading: implyBarLeading,
          elevation: 0,
          flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(this.state.headerHeight),
              child: Container(
                height: this.state.headerHeight,
                color: Colors.blueGrey,
                padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Image.network(
                  "./icons/bop_long.png",
                  fit: BoxFit.contain,
                ),
              ))),
    );
    Container artMenu = Container(
      width: this.state.artWidth,
      child: ArtMenuInh(child: ArtMenu(), state: state),
    );
    Container toolMenu = Container(
      width: this.state.toolWidth,
      child: ToolMenuInh(child: ToolMenu(), state: state),
    );

    return Row(
      children: [
        if (wideScreen) artMenu,
        Expanded(
          child: Scaffold(
            appBar: topBar,
            bottomNavigationBar: bottomBar,
            backgroundColor: Colors.white,
            drawer: !wideScreen ? artMenu : null,
            endDrawer: !wideScreen ? toolMenu : null,
            body: PaperSheetInh(child: PaperSheet(), state: state),
          ),
        ),
        if (wideScreen) toolMenu,
      ],
    );
  }
}
