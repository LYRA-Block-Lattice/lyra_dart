import 'package:flutter_test/flutter_test.dart';

import 'package:lyra/lyra_api.dart';

void main() {
  test('Get Lyra API Status', () async {
    const pvk = "2gbESTeBHsgt8um1aNN2dC9jajEDk3CoEupwmN6TRJQckyRbHa";
    const pub =
        "LUTkgGP9tb4iAFAFXv7i83N4GreEUakWbaDrUbUFnKHpPp46n9KF1QzCtvUwZRBCQz6yqerkWvvGXtCTkz4knzeKRmqid";

    final api = LyraAPI("testnet", pvk, null);
    await api.init();
  });
}
