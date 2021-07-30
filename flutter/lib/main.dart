import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bop/graphic/arts.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:bop/ui/bopApp.dart';

//TODO Check null safety
//flutter packages pub outdated --mode=null-safety

void main() async {
  runApp(BOPStartingPoint(Init()));
}

class BOPStartingPoint extends StatelessWidget {
  final Init init;
  final Future _initFuture;

  BOPStartingPoint(this.init) : this._initFuture = init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Initialization',
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("Init complete");
            return BOPApp(init, true);
          } else {
            print("Init NOT YET complete");
            return BOPApp(init, false);
          }
        },
      ),
    );
  }
}

class Init {
  Arts arts;
  Wallets wallets;

  Future initialize() async {
    try {
      print("initializing...");
      await _prepareServices();
      await _prepareArts();
      print("initializing done");
    } catch (e) {
      print(e);
    }
  }

  _prepareServices() async {
    print("Init - prepareServices");
    // Required for Firebase
    // If you're running an application and need to access the binary messenger before `runApp()`
    // has been called (for example, during plugin initialization), then you need to explicitly
    // call the `WidgetsFlutterBinding.ensureInitialized()` first.
    // If you're running a test, you can call the `TestWidgetsFlutterBinding.ensureInitialized()`
    // as the first line in your test's `main()` method to initialize the binding.
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print("Init - prepareServices complete");
  }

  _prepareArts() async {
    print("Init - preparingArts");
    wallets = Wallets();
    arts = await Arts.loadArts();
    print("Init - preparingArts complete");
  }
}
