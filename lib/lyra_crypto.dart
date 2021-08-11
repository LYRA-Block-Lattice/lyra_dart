library lyra;

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pascaldart/pascaldart.dart';
import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';

/// A Calculator.
class LyraCrypto {
  /// Verify a key pair
  Future<bool> isAccountIdValid(String accountId) async {
    if (accountId.length < 10 || accountId.substring(0, 1) != 'L') return false;
    try {
      var decStr = await lyraDecAccountId(accountId);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<String> lyraDecAccountId(String accountId) async {
    var pubKey = accountId.substring(1);

    var decStr = await lyraDec(pubKey);
    return "04" + decStr;
  }

  Future<String> lyraDec(String input) async {
    var buff = Base58.decode(input);
    var data = buff.sublist(0, buff.length - 4);
    var crc = await checksum(data);
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
  Future<String> lyraEnc(String input) async {
    final buff = hex.decode(input);
    var crc = await checksum(buff);
    return Base58.encode(buff + crc);
  }

  Future<List<int>> sha256(List<int> input) async {
    final algo = Sha256();
    final hash = await algo.hash(input);
    return hash.bytes;
  }

  Future<List<int>> checksum(List<int> input) async {
    final h1 = await sha256(input);
    var h2 = await sha256(h1);
    return h2.sublist(0, 4);
  }
}
