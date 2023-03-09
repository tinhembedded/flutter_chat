import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class SocketService with ChangeNotifier {
  late IO.Socket _socket;
  List<String> groups = [];

  void initSocket() {
    _socket = IO.io('http://localhost:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());
    connect();
  }

  void connect() {
    if (!_socket.connected) {
      _socket.onConnect((_) {});
    }
  }

  IO.Socket get socket {
    if (_socket == null) {
      initSocket();
    }
    return _socket;
  }

  void disconnect() {
    if (_socket != null) {
      _socket.disconnect();
    }
  }

  void on(String eventName, [dynamic callback]) {
    _socket.on(eventName, callback);
  }

  void emit(String eventName, [dynamic args]) {
    _socket.emit(eventName, args);
  }

  void off(String eventName, [dynamic callback]) {
    _socket.off(eventName, callback);
  }
}
