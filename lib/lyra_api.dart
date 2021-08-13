part of lyra;

/// A Calculator.
class LyraAPI {
  String network;
  String? nodeAddress;
  String prvKey;
  String? accountId;
  WebSocketChannel? ws;
  Peer? client;

  //LyraAPI(this.network, this.prvKey);
  LyraAPI(this.network, this.prvKey, this.nodeAddress);

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
      var status = await client!.sendRequest('Status', ['2.2.0.0', network]);
      print(status.toString());
    } on RpcException catch (error) {
      print('RPC error ${error.code}: ${error.message}');
    }
  }

  Future<dynamic> send(double amount, String destAddr, String token) async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp =
        await client!.sendRequest('Send', [accountId, amount, destAddr, token]);
    return balanceResp;
  }

  Future<dynamic> receive() async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp = await client!.sendRequest('Receive', [accountId]);
    return balanceResp;
  }

  Future<dynamic> balance() async {
    if (client!.isClosed) {
      await init();
    }

    var balanceResp = await client!.sendRequest('Balance', [accountId]);
    return balanceResp;
  }

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

  void close() {
    if (client!.isClosed) {
      client!.close();
      accountId = '';
      prvKey = '';
    }
  }
}
