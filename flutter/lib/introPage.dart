import 'package:flutter/material.dart';

//Main StatelessWidget
class IntroPage extends StatelessWidget {
  IntroPage();

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
        "BitcoinOnPaper (BOP) is a web application to build Paper wallets for Bitcoin.";
    String built4SVTxt =
        "BOP has been built for Bitcoin (BSV) and the main scope is to be able to print Bitcoin addresses and private keys on paper.";
    String paperwalletTxt =
        "Paper wallets (or Bitcoin on paper) can be given as gifts.";
    String walletTxt =
        "Paper wallets can be used to store Bitcoin but be careful because they can be lost or become unreadable.";
    String riskTxt =
        "Be aware that BOP is a free application without any kind of guarantee. It could have malfunctioning. Use it at your own risk. All the code is available here: https://github.com/ejfhp/bitonpaper";
    double pad = 20;
    double ratio = constraints.maxWidth / 400;
    if (ratio > 1) {
      ratio = 1;
    }
    double colw = 368 * ratio;
    Widget main = Column(
      children: [
        Container(
          child: Image.network(
            "./icons/bop_twol.png",
            fit: BoxFit.contain,
          ),
          constraints: BoxConstraints(maxWidth: colw),
          padding: EdgeInsets.fromLTRB(10, 50, 10, 100),
        ),
        textContainer(presentationTxt, pad, colw),
        textContainer(built4SVTxt, pad, colw),
        textContainer(paperwalletTxt, pad, colw),
        textContainer(walletTxt, pad, colw),
        textContainer(riskTxt, pad, colw),
        Container(
            child: RaisedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/wallet");
          },
          textColor: Colors.blueGrey[800],
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: const Text('Continue', style: TextStyle(fontSize: 20)),
        )),
      ],
    );
    return main;
  }

  Widget textContainer(String text, double pad, colw) {
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
      constraints: BoxConstraints(maxWidth: colw),
      padding: EdgeInsets.all(pad),
    );
  }
}
