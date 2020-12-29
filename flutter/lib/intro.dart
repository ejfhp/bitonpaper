import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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
    double width = 400;
    double ratio = constraints.maxWidth / width;
    if (ratio > 1) {
      ratio = 1;
    }
    double colw = width * ratio;
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
        Container(
          width: colw,
          child: presentationText(context),
        ),
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
          padding: EdgeInsets.fromLTRB(10, 50, 10, 50),
        ),
      ],
    );
    return main;
  }

  Widget presentationText(context) {
    return RichText(
      text: TextSpan(style: TextStyle(fontSize: 12, fontFamily: "Roboto", color: Colors.black87), children: <TextSpan>[
        TextSpan(children: <TextSpan>[
          TextSpan(text: 'BOP ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18)),
          TextSpan(text: 'let you build Paper Wallets for '),
          TextSpan(text: 'Bitcoin (BSV)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
          TextSpan(text: '.\n'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: 'Everything runs locally in your browser and nothing is sent over the Internet.\n'),
          TextSpan(text: '\n'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: '1 - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(text: 'Click Continue ath the bottom of this page.\n'),
          TextSpan(text: '2 - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(text: 'Unplug the network. '),
          TextSpan(text: '\u20F0\n', style: TextStyle(color: Colors.red)),
          TextSpan(text: '3 - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(text: 'Select an art from the right menu.\n'),
          TextSpan(text: '4 - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(text: 'Export as many wallet as you want from the right menu.\n'),
          TextSpan(text: '5 - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextSpan(text: 'When done close the browser and restart your computer. '),
          TextSpan(text: '\u20F0\n', style: TextStyle(color: Colors.red)),
          TextSpan(
              text: ' \u20F0 for the paranoid about security\n',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.red)),
          TextSpan(text: '\n'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: 'Be aware that '),
          TextSpan(text: 'BOP ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18)),
          TextSpan(text: 'is a free application '),
          TextSpan(text: 'without ', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: 'any kind of '),
          TextSpan(text: 'guarantee', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '. It could have malfunctioning. Paper wallets can be lost or become unreadable. '),
          TextSpan(text: 'Use it at your own risk.\n', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '\n'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: 'All the code is available here: '),
          TextSpan(
            text: "https://github.com/ejfhp/bitonpaper.",
            style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch('https://github.com/ejfhp/bitonpaper');
                print('https://github.com/ejfhp/bitonpaper');
              },
          ),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(
              text:
                  '\n\nThis website uses only Google Analytics cookies. No information is shared with any other third party service.\n'),
          TextSpan(text: '\n'),
        ]),
      ]),
    );
  }
}
