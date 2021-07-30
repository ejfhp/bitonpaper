import 'package:test/test.dart';
import 'package:bop/bitcoin/wallets.dart';
import 'package:dartsv/dartsv.dart';

void main() {
  group("Bitcoin Wallet", () {
    test('check privkey wif', () {
      for (int i = 0; i < 1000; i++) {
        Wallet w = Wallet();
        String priv = w.privateKey;
        String add = w.publicAddress;
        SVPrivateKey reKey = SVPrivateKey.fromWIF(priv);
        String readd = reKey.toAddress().toString();
        print("$i $priv $add $readd");
      }
    });
    //   test('check native privkey wif', () {
    //     for (int i = 0; i < 100; i++) {
    //       SVPrivateKey privKey = SVPrivateKey(networkType: NetworkType.MAIN);
    //       String priv = privKey.toWIF();
    //       String add = privKey.toAddress().toString();
    //       print("$i  key: $priv    add: $add");
    //       SVPrivateKey reKey = SVPrivateKey.fromWIF(priv);
    //       String readd = reKey.toAddress().toString();
    //       print("$i  readd: $readd");
    //     }
    //   });
  });
}

// Running "flutter pub get" in flutter...                          2,606ms
// 00:03 +0: Bitcoin Wallet check privkey wif
// 0: L4oTecFy5c77FdnCSVLZ7hcYvaR7KnYXN7yiq6wJzZkdh9upQtsW
// 1: L252ydpi2MsuUqFaqgjsuV6AenU3TbereSanjJ2tMsatfzL2CaU1
// 2: KzCvGUhofqCA6LqtQ2AY5UaM95QYBifhtuADtZmiLCmH9oXTL9vg
// 3: L3hYYJMsvcTAjnRW52d4Zck9q3x1WSMeLgERLooG6GsL4ekmURvN
// 4: L2a3f6Dn8FTzh9x1krjAPkf3YJW9tKoKq2SfwxSCVWxiS9QiVco8
// 5: 2C3XKGGfLrcof44gP5aYBSS82b4NVV51WBWCNsMSqerRC1VHq5BQ
// 6: KyxbPEMjSeT8bS9bPbMF2EbLEVNEWyHLHp9teowF1ZmLS1aqpUxS
// 7: 2CAgtT1dABbiCDxU6B5QX8jYBwGYr2Uqua2XFK4uAtRLCSFa1enj
// 8: L2GMdfBM42MYHHf8uxTLHeCbtqYZkp1x3T2jHESWX7CwbTXAsG5g
// 9: L12NcMYDu3xK5QgKsNxp5x1xe4BFxzm1LrmFRqjSZyRR3snTPJEA
// 00:03 +1: All tests passed!
