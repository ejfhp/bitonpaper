import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bop/version.dart';

//Main StatelessWidget
class Intro extends StatelessWidget {
  final bool allReady;
  Intro(this.allReady);

  @override
  Widget build(BuildContext context) {
    BottomAppBar bottomBar = BottomAppBar(
        color: Colors.blueGrey,
        child: Text(
          "",
          textAlign: TextAlign.center,
        ));
    return Scaffold(
        bottomNavigationBar: bottomBar,
        backgroundColor: Colors.blueGrey[200],
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.blueGrey,
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
          child: Image.asset(
            'resources/imgs/bop_twol.png',
            width: 300,
            fit: BoxFit.contain,
          ),
          constraints: BoxConstraints(maxWidth: colw),
          padding: EdgeInsets.fromLTRB(10, 20, 10, 50),
        ),
        Container(
          width: colw,
          child: presentationText(context),
        ),
        Container(
          width: colw,
          child: Row(
            children: [
              Container(
                child: TextButton(
                  child: Image.asset(
                    'resources/imgs/google_play.png',
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () {
                    launch('https://play.google.com/store/apps/details?id=com.ejfhp.bitonpaper');
                  },
                ),
                constraints: BoxConstraints(maxWidth: 100),
                padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
              ),
              RichText(
                text: TextSpan(
                  text: "Art Maker",
                  style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch('https://am.bop.run');
                    },
                ),
              ),
            ],
          ),
        ),
        Container(
          child: ElevatedButton(
            //Avoid the back button to go back to the Intro
            // onPressed: this.allReady ? () => Navigator.pushNamedAndRemoveUntil(context, '/bop', ModalRoute.withName('/')) : null,
            onPressed: this.allReady ? () => Navigator.pushReplacementNamed(context, "/bop") : null,
            // onPressed: this.allReady ? () => Navigator.pushNamed(context, "/bop") : null,
            child: Text(
              this.allReady ? AppLocalizations.of(context).intro_continue : AppLocalizations.of(context).intro_initializing,
              style: TextStyle(fontSize: 30, color: this.allReady ? Colors.amber : Colors.blueGrey[50]),
            ),
          ),
          padding: EdgeInsets.fromLTRB(10, 30, 10, 50),
        ),
        Container(
          width: colw,
          child: Text(
            "Ver " + VERSION,
            style: TextStyle(fontSize: 10, color: Colors.white, fontFamily: "Roboto"),
          ),
        ),
      ],
    );
    return main;
  }

  Widget presentationText(context) {
    TextStyle bold20 = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
    TextStyle bold18amber = TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 18);
    TextStyle normal = TextStyle(fontSize: 12, color: Colors.white);
    TextStyle boldAmber = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber);
    TextStyle bold = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

    return SelectableText.rich(
      TextSpan(style: normal, children: <TextSpan>[
        TextSpan(children: <TextSpan>[
          TextSpan(text: 'BOP ', style: bold18amber),
          TextSpan(text: AppLocalizations.of(context).intro_a),
          TextSpan(text: ' Bitcoin (BSV)', style: boldAmber),
          TextSpan(text: '.\n'),
          TextSpan(text: '\n'),
        ]),
        // TextSpan(children: <TextSpan>[
        //   TextSpan(text: AppLocalizations.of(context).intro_b),
        //   TextSpan(text: '\n'),
        // ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: '\n'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: AppLocalizations.of(context).intro_f),
          TextSpan(text: 'BOP ', style: bold18amber),
          TextSpan(text: AppLocalizations.of(context).intro_g),
          TextSpan(text: AppLocalizations.of(context).intro_h, style: bold),
          TextSpan(text: AppLocalizations.of(context).intro_i),
          TextSpan(text: AppLocalizations.of(context).intro_j, style: bold),
          TextSpan(text: AppLocalizations.of(context).intro_k),
          TextSpan(text: AppLocalizations.of(context).intro_l + '\n', style: bold),
          TextSpan(text: '\n'),
        ]),
        // TextSpan(children: <TextSpan>[
        //   TextSpan(text: AppLocalizations.of(context).intro_m),
        //   TextSpan(
        //     text: "https://github.com/ejfhp/bitonpaper.",
        //     style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
        //     recognizer: TapGestureRecognizer()
        //       ..onTap = () {
        //         launch('https://github.com/ejfhp/bitonpaper');
        //       },
        //   ),
        // ]),
        // TextSpan(children: <TextSpan>[
        //   TextSpan(text: AppLocalizations.of(context).intro_n),
        //   TextSpan(text: 'BOP ', style: bold18amber),
        //   TextSpan(text: AppLocalizations.of(context).intro_o),
        //   TextSpan(
        //     text: "https://twitter.com/boprun",
        //     style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
        //     recognizer: TapGestureRecognizer()
        //       ..onTap = () {
        //         launch('https://twitter.com/boprun');
        //       },
        //   ),
        //   TextSpan(text: '.\n\n'),
        // ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: AppLocalizations.of(context).intro_p + '\n'),
          TextSpan(text: AppLocalizations.of(context).intro_q),
          TextSpan(
            text: "https://bop.run/bitcoin.pdf",
            style: TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch('https://bop.run/bitcoin.pdf');
              },
          ),
          TextSpan(text: '.'),
        ]),
        TextSpan(children: <TextSpan>[
          TextSpan(text: '\n\n' + AppLocalizations.of(context).intro_r + '\n'),
        ]),
      ]),
    );
  }
}
