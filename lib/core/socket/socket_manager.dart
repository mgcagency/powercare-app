import 'package:flutter/foundation.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../app/constants/app_constants.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  late IO.Socket socket;
  bool _isInitialized = false;

  String joinRoomEvent = "join-chat-room";

  void init(String? token) {
    if (_isInitialized) return;

    socket = IO.io(
      AppConstants.socketBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .build(),
    );
    socket.connect();
    socket.onConnect((_) {
      debugPrint('✅ Socket connected');
    });

    socket.onDisconnect((_) => print('Socket disconnected'));
    socket.onError((data) => print('Socket error: $data'));
    
    _isInitialized = true;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      init(null);
    }
  }


}
