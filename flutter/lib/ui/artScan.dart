import 'dart:ui';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bop/bitcoin/chain.dart';
import 'package:bop/io/external.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const double MAIN_WIDTH = 860;
const double TEXT_WIDTH = 300;
// const int SELECT_TYPE = 0;
const int ENTER_PAYMAIL = 1;
// const int ENTER_ADDRESS = 2;
const int ENTER_KEY = 3;
const int SEND_TX = 4;
const int DONE = 5;

class ArtScan extends StatefulWidget {
  ArtScan();

  @override
  State<ArtScan> createState() {
    return _ArtScanState();
  }
}

class _ArtScanState extends State<ArtScan> {
  Chain chain = Chain();
  Timer _debouncePaymail;
  int _currentStep = ENTER_PAYMAIL;
  bool _invalidAddress = true;
  double _balance = -1;
  String _txid = "";
  TextEditingController _paymailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _keyController = TextEditingController();
  FocusNode _paymailFocus = FocusNode();
  FocusNode _addressFocus = FocusNode();
  FocusNode _keyFocus = FocusNode();

  _ArtScanState();

  void _setToPaymailAddress(String address) {
    print("_setToPaymailAddress $address");
    setState(() {
      if (chain.checkAddress(address)) {
        this._addressController.text = address;
        this._invalidAddress = false;
        this._currentStep = ENTER_KEY;
        this._addressFocus.unfocus();
        this._paymailFocus.unfocus();
      } else {
        this._addressController.text = "undefined";
        this._invalidAddress = true;
        this._currentStep = ENTER_PAYMAIL;
      }
    });
  }

  void _setToAddress(String address) {
    print("_setToAddress $address");
    setState(() {
      this._addressController.text = address;
      this._paymailController.text = "";
      if (chain.checkAddress(address)) {
        this._invalidAddress = false;
        this._currentStep = ENTER_KEY;
        this._addressFocus.unfocus();
        this._paymailFocus.unfocus();
      } else {
        this._invalidAddress = true;
        this._currentStep = ENTER_PAYMAIL;
      }
    });
  }

  void _setTxID(String txid) {
    print("_setTxID $txid");
    setState(() {
      this._txid = txid;
      if (txid != "") {
        this._currentStep = DONE;
      } else {
        this._currentStep = ENTER_KEY;
      }
    });
  }

  void _setBalance(double balance) {
    print("_setBalance $balance");
    setState(() {
      this._balance = balance;
      if (this._balance > 0) {
        this._currentStep = SEND_TX;
        this._keyFocus.unfocus();
      } else {
        this._currentStep = ENTER_KEY;
      }
    });
  }

  Future<void> _getAddressOfPaymail(BuildContext context, String pm) async {
    print("_getAddressOfPaymail $pm");
    if (_debouncePaymail?.isActive ?? false) {
      //Cancel the previous debouncing, if any
      _debouncePaymail.cancel();
    }
    _debouncePaymail = Timer(const Duration(milliseconds: 1000), () async {
      try {
        String address = await chain.addressFromPaymail(pm);
        print("Address is : " + address);
        _setToPaymailAddress(address);
      } catch (e) {
        print("Address not found for paymail: $pm");
        _setToPaymailAddress("not found");
      }
    });
  }

  Future<void> _getBalanceOfKey(BuildContext context, String key) async {
    print("_getBalanceOfKey  key");
    try {
      double balance = await chain.balanceOfKey(key);
      print("Balance is : $balance");
      this._setBalance(balance);
    } catch (e) {
      _alert(context, "Failed to check balance", e);
      this._setBalance(-1);
    }
  }

  Future<void> _sweep(BuildContext context, String key, String address) async {
    try {
      this._keyController.text = key;
      bool consent = await _confirm(context, AppLocalizations.of(context).screenScan_sure, AppLocalizations.of(context).screenScan_surelong);
      if (consent) {
        String txid = await chain.sweep(key, address);
        print("TXID is : $txid");
        _setTxID(txid);
      } else {
        print("sweep ccancelled");
      }
    } catch (e) {
      _setTxID("");
      _alert(context, "Sweep failed", e);
    }
  }

  void _clean() {
    this._keyController.clear();
    this._paymailController.clear();
    this._addressController.clear();
    this._txid = "";
    this._invalidAddress = true;
    this._balance = -1;
    setState(() {
      this._currentStep = ENTER_PAYMAIL;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debouncePaymail.cancel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List<Widget>.empty(growable: true);
    switch (this._currentStep) {
      case ENTER_PAYMAIL:
        widgets.addAll(_buildEnterPaymailOrAddress(context));
        break;
      case ENTER_KEY:
        widgets.addAll(_buildEnterPaymailOrAddress(context));
        widgets.addAll(_buildEnterKey(context));
        widgets.addAll(_buildClear(context));
        break;
      case SEND_TX:
        widgets.addAll(_buildEnterPaymailOrAddress(context));
        widgets.addAll(_buildEnterKey(context));
        widgets.addAll(_buildClear(context));
        widgets.addAll(_buildSendTX(context));
        break;
      case DONE:
        widgets.addAll(_buildEnterPaymailOrAddress(context));
        widgets.addAll(_buildEnterKey(context));
        widgets.addAll(_buildDone(context));
        widgets.addAll(_buildClear(context));
        break;
      default:
        widgets.add(Text("ops"));
    }
    Widget content = Container(
      width: 400,
      alignment: Alignment.topCenter,
      margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
    return SingleChildScrollView(
      child: Center(
        child: content,
      ),
    );
  }

  List<Widget> _buildEnterPaymailOrAddress(BuildContext context) {
    print("enterPaymail");
    return [
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        // width: 400,
        // height: 100,
        child: RichText(
          text: TextSpan(
            text: AppLocalizations.of(context).screenScan_message,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
      SizedBox(
        width: TEXT_WIDTH,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).screenScan_paymail,
          ),
          controller: this._paymailController,
          focusNode: this._paymailFocus,
          enableInteractiveSelection: true,
          onChanged: (String value) async {
            await _getAddressOfPaymail(context, value);
          },
        ),
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: TEXT_WIDTH,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).screenScan_address,
                ),
                style: this._invalidAddress ? TextStyle(color: Colors.red) : null,
                controller: this._addressController,
                focusNode: this._addressFocus,
                enableInteractiveSelection: true,
                onChanged: (String value) async {
                  await _setToAddress(value);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.qr_code, semanticLabel: AppLocalizations.of(context).screenScan_scan),
              tooltip: AppLocalizations.of(context).screenScan_scan,
              onPressed: () async {
                String address = await scan();
                _addressController.text = address;
                await _setToAddress(address);
              },
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildEnterKey(BuildContext context) {
    print("enterKey");
    return [
      Container(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: TEXT_WIDTH,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).screenScan_key,
                ),
                enableInteractiveSelection: true,
                controller: this._keyController,
                focusNode: this._keyFocus,
                onChanged: (value) async {
                  await _getBalanceOfKey(context, value);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.qr_code, semanticLabel: AppLocalizations.of(context).screenScan_scan),
              tooltip: AppLocalizations.of(context).screenScan_scan,
              onPressed: () async {
                String key = await scan();
                _keyController.text = key;
                await _getBalanceOfKey(context, key);
              },
            ),
          ],
        ),
      ),
      Container(
        child: RichText(
          text: TextSpan(
            text: AppLocalizations.of(context).screenScan_balance + ": " + (this._balance >= 0 ? this._balance.toString() : " undef") + " bitcoin",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSendTX(BuildContext context) {
    print("buildSentTX");
    return [
      Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: ElevatedButton(
            child: Text(AppLocalizations.of(context).screenScan_sweep),
            onPressed: () async {
              await _sweep(context, this._keyController.text, this._addressController.text);
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDone(BuildContext context) {
    print("enterKey");
    return [
      Container(
        padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: RichText(
          text: TextSpan(
            text: AppLocalizations.of(context).screenScan_complete + ": ",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: RichText(
          text: TextSpan(
            text: "https://whatsonchain.com/tx/" + this._txid,
            style: TextStyle(color: Colors.black54, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await launch("https://whatsonchain.com/tx/" + this._txid);
              },
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildClear(BuildContext context) {
    print("enterKey");
    return [
      Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
          child: ElevatedButton(
            child: Text(AppLocalizations.of(context).screenScan_clean),
            onPressed: () {
              this._clean();
            },
          ),
        ),
      ),
    ];
  }

  Future<bool> _confirm(BuildContext context, String title, String message) async {
    bool result;
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
                child: Text("YES"),
              ),
              TextButton(
                onPressed: () {
                  result = false;
                  Navigator.of(context).pop();
                },
                child: Text("NO"),
              ),
            ],
            elevation: 24.0,
            backgroundColor: Colors.white,
          );
        });
    return result;
  }

  Future<void> _alert(BuildContext context, String title, String message) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Ok")),
            ],
            elevation: 24.0,
            backgroundColor: Colors.white,
          );
        });
  }
}
