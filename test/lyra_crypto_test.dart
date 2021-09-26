import 'dart:math';

import 'package:test/test.dart';
import 'package:convert/convert.dart';

import 'package:lyra/lyra.dart';

void main() {
  test('ddd', () {
    var hex =
        '3fee93287cf21fca2900964205f9f08e5b3d5147b6ad91b4988ea3b61ea0e198';
    var pub =
        'LULBh4JZT8ybh34kCShUy1WdtbFHNkdwJ5BXZpgFsmiRggwqqjmc87Rh4wVYRegEuoddMBuYi66rpkB1a9JdEdmtmpnUmR';
    expect(LyraCrypto.isAccountIdValid(pub), true);
    var pubKey = LyraCrypto.privateKeyHexToPublicKey(hex);
    var accountId = LyraCrypto.lyraEncPub(pubKey);
    print('converted:');
    print(accountId);
    expect(accountId, pub);
  });
  test('key pair generate and verify', () {
    var pvk = '2gbESTeBHsgt8um1aNN2dC9jajEDk3CoEupwmN6TRJQckyRbHa';
    var pub =
        'LUTkgGP9tb4iAFAFXv7i83N4GreEUakWbaDrUbUFnKHpPp46n9KF1QzCtvUwZRBCQz6yqerkWvvGXtCTkz4knzeKRmqid';

    try {
      var ret = LyraCrypto.isAccountIdValid(pub);
      expect(ret, true);

      var ret2 = LyraCrypto.isPrivateKeyValid(pvk);
      expect(ret2, true);

      var pubx = LyraCrypto.prvToPub(pvk);
      expect(pubx, pub);

      var prvKey = LyraCrypto.lyraDecToBytes(pvk);
      var pubKey = LyraCrypto.privateKeyToPublicKey(prvKey);
      var accountId2 = LyraCrypto.lyraEncPub(pubKey);
      expect(accountId2, pub);

      var wallet = LyraCrypto.generateWallet();
      expect(LyraCrypto.isAccountIdValid(wallet[1]), true);
      expect(LyraCrypto.isPrivateKeyValid(wallet[0]), true);

      var msg = 'hello, world!';
      var signtr = LyraCrypto.sign(msg, pvk);
      print(signtr);
      expect(LyraCrypto.verify(msg, pub, signtr), true);
    } catch (e) {
      print(e);
      fail('not verify account id properly: ');
    }
  });
}
