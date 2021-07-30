import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:dartsv/dartsv.dart';

const String BASEURL = "https://unstable.bop.run";
// const String BASEURL = "http://localhost:8080";
const SECRET = "76a9142f353ff06fe8c4d558b9";

class Chain {
  Chain();

  Future<String> addressFromPaymail(String paymail) async {
    print("Chain.addressFromPaymail for $paymail ");
    Uri uri = Uri.parse(BASEURL + "/paymail/" + paymail + "/" + SECRET);
    print("Chain.addressFromPaymail uri: " + uri.toString());
    int statusCode = -1;
    try {
      http.Response respJ = await http.get(uri);
      statusCode = respJ.statusCode;
      print("Chain.addressFromPaymail status: $statusCode");
      if (statusCode == 200) {
        Map<String, dynamic> tj = (convert.jsonDecode(respJ.body) as Map).cast<String, dynamic>();
        print(tj);
        String address = tj["address"];
        print("Chain.addressFromPaymail address: $address ");
        return address;
      } else {
        print("Chain.addressFromPaymai laddress not found for paymail $paymail: status: $statusCode");
      }
    } catch (e) {
      print("Chain.addressFromPaymail response status: $statusCode, $e");
      throw Exception("lookup_failed");
    }
    return "";
  }

  Future<double> balanceOfKey(String wifKey) async {
    print("Chain.balanceOfKey for $wifKey ");
    try {
      SVPrivateKey key = SVPrivateKey.fromWIF(wifKey);
      Address add = key.toAddress(networkType: NetworkType.MAIN);
      print("Chain.balanceOfKey address: " + add.toBase58());
      String address = add.toBase58();
      Uri uri = Uri.parse(BASEURL + "/balance/" + address + "/" + SECRET);
      print("Chain.balanceOfkey uri: " + uri.toString());
      int statusCode = -1;
      http.Response respJ = await http.get(uri);
      statusCode = respJ.statusCode;
      if (statusCode == 200) {
        Map<String, dynamic> tj = (convert.jsonDecode(respJ.body) as Map).cast<String, dynamic>();
        String balance = tj["balance"];
        int satoshi = int.parse(balance);
        double bsv = satoshi / 100000000.0;
        print("Chain.balanceOfKey address: $address ");
        return bsv;
      } else {
        print("Chain.balanceOfKey balance not found for address $address: status: $statusCode");
      }
    } catch (e) {
      print("Chain.balanceOfKey cannot get balance: $e");
      throw Exception("balance_failed");
    }
    return 0;
  }

  Future<String> sweep(String wifKey, String toAddress) async {
    print("Chain.sweep to $toAddress ");
    try {
      SVPrivateKey key = SVPrivateKey.fromWIF(wifKey);
      Address add = key.toAddress(networkType: NetworkType.MAIN);
      print("Chain.sweep address: " + add.toBase58());
      String fromAddress = add.toBase58();
      Uri uri = Uri.parse(BASEURL + "/sweep/" + wifKey + "/" + fromAddress + "/" + toAddress + "/" + SECRET);
      print("Chain.sweep uri: " + uri.toString());
      int statusCode = -1;
      http.Response respJ = await http.get(uri);
      statusCode = respJ.statusCode;
      if (statusCode == 200) {
        Map<String, dynamic> tj = (convert.jsonDecode(respJ.body) as Map).cast<String, dynamic>();
        String txid = tj["txid"];
        print("Chain.sweep txid: $txid ");
        return txid;
      } else {
        print("Chain.sweep failed, statuscode: $statusCode ");
      }
    } catch (e) {
      print("Chain.sweep error while sweep : $e");
      throw Exception("sweep_failed");
    }
    return "";
  }

  bool checkAddress(String address) {
    try {
      Address add = Address.fromBase58(address);
      if (add != null) {
        print("Chain.chackAddress address is valid");
        return true;
      }
    } catch (e) {
      print("Chain.chackAddress address is invalid");
      return false;
    }
    print("Chain.chackAddress address is invalid");
    return false;
  }
}
