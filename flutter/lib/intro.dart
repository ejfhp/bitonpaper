import 'package:flutter/material.dart';

//Main StatelessWidget
class Intro extends StatelessWidget {
  Intro();

  @override
  Widget build(BuildContext context) {
    BottomAppBar bottomBar = BottomAppBar(
        color: Colors.blueGrey,
        child: Text(
          "Works only on Bitcoin (SV). Use at your own risk.",
          textAlign: TextAlign.center,
        ));
    return Scaffold(
        bottomNavigationBar: bottomBar,
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    child: buildIntro(context, constraints),
                    alignment: Alignment.topCenter,
                  )));
        }));
  }

  Widget buildIntro(BuildContext context, BoxConstraints constraints) {
    String presentationTxt =
        '''
        BitcoinOnPaper (BOP) is a web application to build Paper wallets for Bitcoin.
        Paper wallets can be used for fun (as gifts or coupons) or to store Bitcoin.
        ''';
    String runTxt =
        '''
        It runs locally on the browser and nothing is sent over the Internet nor recorded.
        For the paranoic like me: open the app and then unplug the network cable, when done close the browser and restart.
        ''';
    String riskTxt =
        '''
        Be aware that BOP is a free application without any kind of guarantee. 
        It could have malfunctioning. 
        Paper wallets can be lost or become unreadable.
        Use it at your own risk. 
        Built with dartsv: https://github.com/twostack/dartsv
        All the code is available here: https://github.com/ejfhp/bitonpaper
        ''';
    String analyticsTxt =
        '''
        This website uses cookies (Google Analytics) only to analyse our traffic. No other information is shared with any kind if third party service.
        ''';
    double pad = 20;
    double ratio = constraints.maxWidth / 600;
    if (ratio > 1) {
      ratio = 1;
    }
    double colw = 600 * ratio;
    Widget main = Column(
      children: [
        Container(
          child: Image.network(
            "./icons/bop_twol.png",
            width: 300,
            fit: BoxFit.contain,
          ),
          constraints: BoxConstraints(maxWidth: colw),
          padding: EdgeInsets.fromLTRB(10, 50, 10, 100),
        ),
        textContainer(presentationTxt, pad, colw, 14),
        textContainer(runTxt, pad, colw, 14),
        textContainer(riskTxt, pad, colw, 14),
        textContainer(analyticsTxt, pad, colw, 10),
        Container(
            child: RaisedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/wallet");
          },
          color: Colors.blueGrey,
          textColor: Colors.blueGrey[50],
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: const Text('Continue', style: TextStyle(fontSize: 20)),
        ),
        padding: EdgeInsets.fromLTRB(10, 50, 10, 50),),
      ],
    );
    return main;
  }

  Widget textContainer(String text, double pad, double colw, double fs) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "Roboto",
          fontSize: fs,
        ),
      ),
      constraints: BoxConstraints(maxWidth: colw),
      padding: EdgeInsets.all(pad),
    );
  }
}
