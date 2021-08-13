import 'package:flutter_test/flutter_test.dart';

import 'package:lyra/lyra.dart';

void main() {
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

      var wallet = LyraCrypto.GenerateWallet();
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
