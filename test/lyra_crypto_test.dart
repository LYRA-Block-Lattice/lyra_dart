import 'package:flutter_test/flutter_test.dart';

import 'package:lyra/lyra_crypto.dart';

void main() {
  test('key pair generate and verify', () async {
    String pvk = "2gbESTeBHsgt8um1aNN2dC9jajEDk3CoEupwmN6TRJQckyRbHa";
    String pub =
        "LUTkgGP9tb4iAFAFXv7i83N4GreEUakWbaDrUbUFnKHpPp46n9KF1QzCtvUwZRBCQz6yqerkWvvGXtCTkz4knzeKRmqid";

    final lyraCrypto = LyraCrypto();
    try {
      var ret = await lyraCrypto.isAccountIdValid(pub);
      expect(ret, true);
    } catch (e) {
      print(e);
      fail("not verify account id properly: ");
    }
  });
}
