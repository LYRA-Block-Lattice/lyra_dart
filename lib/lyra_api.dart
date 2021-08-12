library lyra;

import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:pedantic/pedantic.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:lyra/lyra_crypto.dart';

/// A Calculator.
class LyraAPI {
  String network;
  String? nodeAddress;
  String prvKey;
  String? accountId;
  WebSocketChannel? ws;

  //LyraAPI(this.network, this.prvKey);
  LyraAPI(this.network, this.prvKey, this.nodeAddress);

  Future<void> init() async {
    // crypto

    if (!LyraCrypto.isPrivateKeyValid(prvKey)) {
      throw ("Not valid private key.");
    }
    accountId = LyraCrypto.prvToPub(prvKey);
    nodeAddress ??= "wss://$network.lyra.live/api/v1/socket";

    // websocket
    var ws = WebSocketChannel.connect(Uri.parse(nodeAddress!));
    var client = Peer(ws.cast<String>());

    // The client won't subscribe to the input stream until you call `listen`.
    // The returned Future won't complete until the connection is closed.
    unawaited(client.listen());

    client.registerMethod("Notify", (Parameters news) {
      print("Got news from Lyra: " + news['catalog'].toString());
    });

    client.registerMethod("Sign", (Parameters req) {
      print("Signing " + req.toString());
      var signature = LyraCrypto.sign(req["msg"].toString(), prvKey);
      return signature;
    });

    try {
      var status = await client.sendRequest("Status", ["2.2.0.0", network]);
      print(status.toString());
    } on RpcException catch (error) {
      print('RPC error ${error.code}: ${error.message}');
    }
  }
}
