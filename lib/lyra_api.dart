part of lyra;

/// API to the Lyra blockchain.
///
/// Lyra provides standard JsonRPC api based on WebSocket from https://mainnet.lyra.live
/// This API is a wrapper of Lyra JsonRPC API.
class LyraAPI {
  String network;
  String? nodeAddress;
  String prvKey;
  String? accountId;
  WebSocketChannel? ws;
  Peer? client;

  /// [network] is 'mainnet', 'testnet', or 'devnet'
  /// [prvKey] is private key.
  /// provides null to [nodeAddress] to use the default url.
  LyraAPI(this.network, this.prvKey, this.nodeAddress);

  /// connect to JsonRPC and get service status.
  Future<void> init() async {
    // crypto

    if (!LyraCrypto.isPrivateKeyValid(prvKey)) {
      throw ('Not valid private key.');
    }
    accountId = LyraCrypto.prvToPub(prvKey);
    nodeAddress ??= 'wss://$network.lyra.live/api/v1/socket';

    // websocket
    var ws = WebSocketChannel.connect(Uri.parse(nodeAddress!));
    client = Peer(ws.cast<String>());

    // The client won't subscribe to the input stream until you call `listen`.
    // The returned Future won't complete until the connection is closed.
    unawaited(client!.listen());

    client!.registerMethod('Notify', (Parameters news) {
      print('Got news from Lyra: ' + news.asList[1].toString());
    });

    client!.registerMethod('Sign', (Parameters req) {
      print('Got signning callback.');

      print('Signing ' + req.asList[1].toString());
      try {
        var signature = LyraCrypto.sign(req.asList[1].toString(), prvKey);
        print('signature is: ' + signature);
        return ['p1393', signature];
      } catch (e) {
        return ['error', e.toString()];
      }
    });

    try {
      var status = await client!.sendRequest('Status', ['2.3.0.0', network]);
      print(status.toString());
    } on RpcException catch (error) {
      print('RPC error ${error.code}: ${error.message}');
    }
  }

  /// send token
  Future<dynamic> send(double amount, String destAddr, String token) async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp =
        await client!.sendRequest('Send', [accountId, amount, destAddr, token]);
    return balanceResp;
  }

  /// receive token
  Future<dynamic> receive() async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp = await client!.sendRequest('Receive', [accountId]);
    return balanceResp;
  }

  /// get current balance
  Future<dynamic> balance() async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp = await client!.sendRequest('Balance', [accountId]);
    return balanceResp;
  }

  /// get transaction history
  Future<dynamic> history(
      DateTime startTimeUtc, DateTime endTimeUtc, int count) async {
    if (client!.isClosed) {
      await init();
    }

    var histResult = await client!.sendRequest('History', [
      accountId,
      startTimeUtc.millisecondsSinceEpoch,
      endTimeUtc.microsecondsSinceEpoch,
      count
    ]);
    return histResult;
  }

  /// close the API, remove private key
  void close() {
    if (client!.isClosed) {
      client!.close();
      accountId = '';
      prvKey = '';
    }
  }
}
