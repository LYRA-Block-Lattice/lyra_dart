part of lyra;

/// Help lib for pointycastle library
class NullSecureRandom extends SecureRandomBase {
  static final FactoryConfig factoryConfig =
      StaticFactoryConfig(SecureRandom, 'Null', () => NullSecureRandom());

  var _nextValue = 0;
  @override
  String get algorithmName => 'Null';
  @override
  void seed(CipherParameters params) {}
  @override
  int nextUint8() => clip8(_nextValue++);
}

/// crypto routine for Lyra wallet/blockchain.
class LyraCrypto {
  /// check if private key is valid
  static bool isPrivateKeyValid(String privateKey) {
    try {
      lyraDec(privateKey);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// check if account ID or wallet address is valid
  static bool isAccountIdValid(String accountId) {
    if (accountId.length < 10 || accountId.substring(0, 1) != 'L') return false;
    try {
      lyraDecAccountId(accountId);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// decode account ID to hex encoding of ECDSA public key
  static String lyraDecAccountId(String accountId) {
    var pubKey = accountId.substring(1);

    var decStr = lyraDec(pubKey);
    return '04' + decStr;
  }

  /// decode private key to hex encoding of ECDSA private key
  static String lyraDec(String input) {
    var buff = Base58Decode(input);
    var data = buff.sublist(0, buff.length - 4);
    var crc = checksum(data);
    Function eq = const ListEquality().equals;
    //print("buff len: " + buff.length.toString());
    //print("crc len: " + crc.length.toString());
    //print(buff.sublist(buff.length - 4, buff.length).toString());
    //print(crc.toList());
    if (eq(buff.sublist(buff.length - 4, buff.length), crc)) {
      //print("yes, equal");
      return hex.encode(data);
    } else {
      //print("no, not equal");
      throw ('Not valid lyra encode string');
    }
  }

  /// Encode with checksum
  static String lyraEnc(List<int> input) {
    var crc = checksum(input);
    return Base58Encode(input + crc);
  }

  /// sha256 digest
  static List<int> sha256(List<int> input) {
    final algo = Digest('SHA-256');
    final hash = algo.process(Uint8List.fromList(input));
    return hash;
  }

  /// crc checksum of byte array
  static List<int> checksum(List<int> input) {
    final h1 = sha256(input);
    var h2 = sha256(h1);
    return h2.sublist(0, 4);
  }

  /// encode a Lyra account ID from ECDSA public key
  static String lyraEncPub(List<int> pubKeyBytes) {
    var ret = lyraEnc(pubKeyBytes.sublist(1));
    return 'L' + ret;
  }

  /// get Account ID from a private key
  static String prvToPub(String prvkey) {
    var prvHex = lyraDec(prvkey);
    var d = BigInt.parse('+' + prvHex, radix: 16);
    var curve = ECCurve_secp256r1();
    var q = curve.G * d;
    var pubKey = ECPublicKey(q, curve);
    var pubKeyBytes = pubKey.Q!.getEncoded(false);

    return lyraEncPub(pubKeyBytes);
  }

  /// generate a Lyra wallet, return key pair
  static List<String> generateWallet() {
    final rnd = Random.secure();
    var pvkBytes = List<int>.generate(32, (i) => rnd.nextInt(256));
    var pvk = lyraEnc(pvkBytes);
    var pub = prvToPub(pvk);
    return [pvk, pub];
  }

  /// sign a message with private key
  static String sign(String msg, String prvkey) {
    var prvHex = lyraDec(prvkey);
    var d = BigInt.parse('+' + prvHex, radix: 16);

    var eccDomain = ECDomainParameters('secp256r1');
    var privParams = PrivateKeyParameter(ECPrivateKey(d, eccDomain));
    var signParams = ParametersWithRandom(privParams, NullSecureRandom());

    var sig = ECDSASigner(SHA256Digest());
    sig.init(true, signParams);
    var signatur = sig.generateSignature(Uint8List.fromList(utf8.encode(msg)));
    // convert to P1393
    var ecsgn = signatur as ECSignature;
    var rb = hex.decode(ecsgn.r.toRadixString(16));
    var sb = hex.decode(ecsgn.s.toRadixString(16));
    var lst = rb + sb;
    return Base58Encode(lst);
  }

  /// verify a message by signature and account ID
  static bool verify(String msg, String accountId, String signature) {
    var pubHex = lyraDecAccountId(accountId);
    var curve = ECCurve_secp256r1();
    var q = curve.curve.decodePoint(hex.decode(pubHex));

    var eccDomain = ECDomainParameters('secp256r1');
    var pubParams = PublicKeyParameter(ECPublicKey(q, eccDomain));

    var sig = ECDSASigner(SHA256Digest());
    sig.init(false, pubParams);

    // decode P1393
    var lst = Base58Decode(signature);
    var half = lst.length ~/ 2;
    var r = BigInt.parse('+' + hex.encode(lst.sublist(0, half)), radix: 16);
    var s = BigInt.parse('+' + hex.encode(lst.sublist(half, lst.length)),
        radix: 16);

    //print("r: " + r.toString());
    //print("s: " + s.toString());
    var ecsigntr = ECSignature(r, s);
    return sig.verifySignature(Uint8List.fromList(utf8.encode(msg)), ecsigntr);
  }
}
