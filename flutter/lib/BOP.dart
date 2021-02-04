import 'package:flutter/material.dart';
import 'BOPState.dart';
import 'menuArt.dart';
import 'menuTool.dart';
import 'paperSheet.dart';
import 'version.dart';
import 'conf.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

//Main StatefulWidget
class BOP extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  BOP(this.analytics, this.observer);

  @override
  BOPState createState() => BOPState(this.analytics, this.observer);
}

//Main StatelessWidget
class BOPUI extends StatelessWidget {
  final BOPState state;

  BOPUI(this.state);

  @override
  Widget build(BuildContext context) {
    final bool wideScreen = MediaQuery.of(context).size.width > ART_WIDTH + TOOL_WIDTH + PAPER_WIDTH;
    final bool implyBarLeading = !wideScreen;
    BottomAppBar bottomBar = BottomAppBar(
      elevation: 0,
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Version " + VERSION,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.black54, fontFamily: "Roboto"),
          ),
        ],
      ),
    );
    PreferredSize topBar = PreferredSize(
      preferredSize: Size.fromHeight(HEADER_HEIGHT),
      child: AppBar(
          iconTheme: IconThemeData(color: Colors.amber),
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: implyBarLeading,
          elevation: 0,
          flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(HEADER_HEIGHT),
              child: Container(
                height: HEADER_HEIGHT,
                color: Colors.blueGrey,
                padding: EdgeInsets.fromLTRB(50, 20, 50, 20),
                child: Image.asset(
                  "resources/imgs/bop_long.png",
                  fit: BoxFit.contain,
                ),
              ))),
    );
    Container artMenu = Container(
      width: ART_WIDTH,
      child: ArtMenuInh(
          child: ArtMenu(
            wide: wideScreen,
          ),
          state: state),
    );
    Container toolMenu = Container(
      width: TOOL_WIDTH,
      child: ToolMenuInh(
        child: ToolMenu(wide: wideScreen),
        state: state,
      ),
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
            body: PaperSheetInh(child: PaperSheet(), papers: state.getPapers()),
          ),
        ),
        if (wideScreen) toolMenu,
      ],
    );
  }
}
