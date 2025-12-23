import 'dart:async';

import 'package:radio_player/radio_player.dart';

class RadioClass {
  final RadioPlayer radioPlayer = RadioPlayer();
  bool isPlaying = false;

  Future<void> setChannel(dynamic item) async {
    try {
      // Don't call stop() here as it causes issues if service not initialized

      // Set the new channel
      await radioPlayer.setChannel(
        title: item['name'] ?? 'Buddhist Radio',
        url: item['streamURL'] ?? '',
      );

      print('✅ Radio channel set: ${item['name']}');
    } catch (e) {
      print('❌ Error setting radio channel: $e');
      rethrow;
    }
  }

  void play() {
    try {
      radioPlayer.play();
      print('▶️ Radio play called');
    } catch (e) {
      print('❌ Error playing radio: $e');
    }
  }

  void pause() {
    try {
      radioPlayer.pause();
      print('⏸️ Radio paused');
    } catch (e) {
      print('❌ Error pausing radio: $e');
    }
  }

  void stop() {
    try {
      radioPlayer.stop();
      print('⏹️ Radio stopped');
    } catch (e) {
      print('❌ Error stopping radio: $e');
    }
  }
}
