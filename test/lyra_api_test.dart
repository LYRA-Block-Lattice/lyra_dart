import 'package:flutter_test/flutter_test.dart';

import 'package:lyra/lyra.dart';

void main() {
  test('Get Lyra API', () async {
    const pvk = '2gbESTeBHsgt8um1aNN2dC9jajEDk3CoEupwmN6TRJQckyRbHa';
    //  const pub = 'LUTkgGP9tb4iAFAFXv7i83N4GreEUakWbaDrUbUFnKHpPp46n9KF1QzCtvUwZRBCQz6yqerkWvvGXtCTkz4knzeKRmqid';

    //final api = LyraAPI('devnet', pvk, 'wss://192.168.3.77:4504/api/v1/socket');
    final api = LyraAPI('testnet', pvk, null);
    await api.init();

    var balance = await api.balance();
    print(balance);
    expect(balance, isNotNull);

    if (balance['unreceived']) {
      print('receiving...');
      var balance2 = await api.receive();
      print(balance2);
      expect(balance2, isNotNull);
    }

    // send
    var destAddr =
        'LT8din6wm6SyfnqmmJN7jSnyrQjqAaRmixe2kKtTY4xpDBRtTxBmuHkJU9iMru5yqcNyL3Q21KDvHK45rkUS4f8tkXBBS3';
    var balance3 = await api.send(5.0, destAddr, 'LYR');
    print(balance3);
    expect(balance3, isNotNull);

    api.close();
  });
}
