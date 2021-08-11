library lyra;

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pascaldart/pascaldart.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/pointycastle.dart';

/// A Calculator.
class LyraCrypto {
  bool isPrivateKeyValid(String privateKey) {
    try {
      var decStr = lyraDec(privateKey);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  bool isAccountIdValid(String accountId) {
    if (accountId.length < 10 || accountId.substring(0, 1) != 'L') return false;
    try {
      var decStr = lyraDecAccountId(accountId);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  String lyraDecAccountId(String accountId) {
    var pubKey = accountId.substring(1);

    var decStr = lyraDec(pubKey);
    return "04" + decStr;
  }

  String lyraDec(String input) {
    var buff = Base58.decode(input);
    var data = buff.sublist(0, buff.length - 4);
    var crc = checksum(data);
    Function eq = const ListEquality().equals;
    print("buff len: " + buff.length.toString());
    print("crc len: " + crc.length.toString());
    print(buff.sublist(buff.length - 4, buff.length).toString());
    print(crc.toList());
    if (eq(buff.sublist(buff.length - 4, buff.length), crc)) {
      print("yes, equal");
      return hex.encode(data);
    } else {
      print("no, not equal");
      throw ("Not valid lyra encode string");
    }
  }

  /// Encode with checksum
  String lyraEnc(List<int> input) {
    var crc = checksum(input);
    return Base58.encode(input + crc);
  }

  List<int> sha256(List<int> input) {
    final algo = Digest("SHA-256");
    final hash = algo.process(Uint8List.fromList(input));
    return hash;
  }

  List<int> checksum(List<int> input) {
    final h1 = sha256(input);
    var h2 = sha256(h1);
    return h2.sublist(0, 4);
  }

  String lyraEncPub(List<int> pubKeyBytes) {
    var ret = lyraEnc(pubKeyBytes.sublist(1));
    return 'L' + ret;
  }

  String prvToPub(String prvkey) {
    var prvHex = lyraDec(prvkey);
    var d = BigInt.parse('+' + prvHex, radix: 16);
    var curve = ECCurve_secp256r1();
    var q = curve.G * d;
    var pubKey = ECPublicKey(q, curve);
    var pubKeyBytes = pubKey.Q.getEncoded(false);

    return lyraEncPub(pubKeyBytes);
  }

  void GenerateWallet() {
/*    final algo = Sha256();
    final ec = Ecdsa.p256(algo);
    var kp = await ec.newKeyPair(); */
  }
}
