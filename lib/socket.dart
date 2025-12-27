import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'cast_channel/cast_channel.pb.dart';

class CastSocketMessage {
  final String namespace;
  final Map<String, dynamic> payload;

  const CastSocketMessage(this.namespace, this.payload);
}

class CastSocket {
  Stream<CastSocketMessage> get stream => _controller.stream;
  bool isClosed = false;

  final SecureSocket _socket;
  int _requestId = 0;
  int get requestId => _requestId;
  final _controller = StreamController<CastSocketMessage>.broadcast();
  final List<int> _buffer = [];

  CastSocket._(this._socket);

  static Future<CastSocket> connect(String host, int port,
      [Duration? timeout]) async {
    timeout ??= Duration(seconds: 10);

    final _socket = await SecureSocket.connect(
      host,
      port,
      onBadCertificate: (X509Certificate certificate) =>
          true, // chromecast use self-signed certificate
      timeout: timeout,
    );

    final socket = CastSocket._(_socket);
    socket._startListening();

    return socket;
  }

  void _startListening() {
    _socket.listen((event) {
      if (_controller.isClosed) {
        return;
      }

      _buffer.addAll(event);
      _processBuffer();
    }, onError: (error) {
      _controller.addError(error);
    }, onDone: () {
      _controller.close();
    }, cancelOnError: false);
  }

  void _processBuffer() {
    // Process all complete messages in the buffer
    while (_buffer.length >= 4) {
      // Read message length from first 4 bytes (big-endian)
      final messageLength = _readUInt32BE(_buffer, 0);

      // Check if we have the complete message
      if (_buffer.length < 4 + messageLength) {
        // Wait for more data
        return;
      }

      // Extract the message bytes
      final messageBytes = _buffer.sublist(4, 4 + messageLength);
      _buffer.removeRange(0, 4 + messageLength);

      try {
        final message = CastMessage.fromBuffer(messageBytes);
        final payload = jsonDecode(message.payloadUtf8) as Map<String, dynamic>;
        _controller.add(CastSocketMessage(message.namespace, payload));
      } catch (e) {
        print('CastSocket: Error parsing message: $e');
      }
    }
  }

  static int _readUInt32BE(List<int> buffer, int offset) {
    return (buffer[offset] << 24) |
        (buffer[offset + 1] << 16) |
        (buffer[offset + 2] << 8) |
        buffer[offset + 3];
  }

  Future<dynamic> close() {
    isClosed = true;
    return _socket.close();
  }

  void sendMessage(String namespace, String sourceId, String destinationId,
      Map<String, dynamic> payload) {
    if (payload['requestId'] == null) {
      payload['requestId'] = _requestId;
      _requestId += 1;
    }

    CastMessage castMessage = CastMessage();
    castMessage.protocolVersion = CastMessage_ProtocolVersion.CASTV2_1_0;
    castMessage.sourceId = sourceId;
    castMessage.destinationId = destinationId;
    castMessage.namespace = namespace;
    castMessage.payloadType = CastMessage_PayloadType.STRING;
    castMessage.payloadUtf8 = jsonEncode(payload);

    Uint8List bytes = castMessage.writeToBuffer();
    Uint32List headers = Uint32List.fromList(
        _writeUInt32BE(List<int>.filled(4, 0), bytes.lengthInBytes));
    Uint32List data =
        Uint32List.fromList(headers.toList()..addAll(bytes.toList()));

    _socket.add(data);
  }

  Future<dynamic> flush() {
    return _socket.flush();
  }

  static final Function _writeUInt32BE = (target, value) {
    target[0] = ((value & 0xffffffff) >> 24);
    target[1] = ((value & 0xffffffff) >> 16);
    target[2] = ((value & 0xffffffff) >> 8);
    target[3] = ((value & 0xffffffff) & 0xff);
    return target;
  };
}
