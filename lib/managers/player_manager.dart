import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../models/stream_model.dart';
import '../managers/volume_manager.dart';

class PlayerState {
  final bool isPlaying;
  final bool isBuffering;
  final bool hasError;
  final String? errorMessage;
  final Duration position;
  final Duration duration;

  const PlayerState({
    this.isPlaying = false,
    this.isBuffering = true,
    this.hasError = false,
    this.errorMessage,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    bool? hasError,
    String? errorMessage,
    Duration? position,
    Duration? duration,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class ManagedPlayer {
  final String slotId;
  final Player player;
  StreamModel? currentStream;
  PlayerState state;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  ManagedPlayer({required this.slotId, required this.player})
      : state = const PlayerState();

  void dispose() {
    _reconnectTimer?.cancel();
    player.dispose();
  }
}

class PlayerManager extends ChangeNotifier {
  final VolumeManager _volumeManager;
  final Map<String, ManagedPlayer> _players = {};
  bool _autoReconnect = true;

  PlayerManager(this._volumeManager);

  bool get autoReconnect => _autoReconnect;
  set autoReconnect(bool v) {
    _autoReconnect = v;
    notifyListeners();
  }

  Player? getPlayer(String slotId) => _players[slotId]?.player;
  PlayerState? getState(String slotId) => _players[slotId]?.state;
  StreamModel? getStream(String slotId) => _players[slotId]?.currentStream;

  Future<void> initSlot(String slotId, {double? initialVolume}) async {
    if (_players.containsKey(slotId)) return;

    final player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,
        logLevel: MPVLogLevel.warn,
      ),
    );

    final managed = ManagedPlayer(slotId: slotId, player: player);
    _players[slotId] = managed;
    _volumeManager.initStream(slotId, initialVolume: initialVolume);

    player.stream.playing.listen((playing) {
      managed.state = managed.state.copyWith(isPlaying: playing, isBuffering: false);
      notifyListeners();
    });

    player.stream.buffering.listen((buffering) {
      managed.state = managed.state.copyWith(isBuffering: buffering);
      notifyListeners();
    });

    player.stream.position.listen((pos) {
      managed.state = managed.state.copyWith(position: pos);
      notifyListeners();
    });

    player.stream.duration.listen((dur) {
      managed.state = managed.state.copyWith(duration: dur);
      notifyListeners();
    });

    player.stream.error.listen((error) {
      managed.state = managed.state.copyWith(hasError: true, errorMessage: error);
      notifyListeners();
      if (_autoReconnect && managed.currentStream != null) {
        _scheduleReconnect(slotId);
      }
    });

    await _applyBufferSettings(player);
    notifyListeners();
  }

  Future<void> _applyBufferSettings(Player player) async {
    try {
      await player.setProperty('cache', 'yes');
      await player.setProperty('demuxer-thread', 'yes');
      await player.setProperty('demuxer-max-bytes', '2GiB');
      await player.setProperty('demuxer-max-back-bytes', '500MiB');
      await player.setProperty('demuxer-readahead-secs', '300');
      await player.setProperty('cache-pause', 'yes');
      await player.setProperty('cache-pause-wait', '30');
      await player.setProperty('network-timeout', '90');
      await player.setProperty('stream-lavf-o', 'reconnect=1');
    } catch (_) {}
  }

  Future<void> loadStream(String slotId, StreamModel stream) async {
    final managed = _players[slotId];
    if (managed == null) {
      await initSlot(slotId);
    }
    final m = _players[slotId]!;
    m._reconnectTimer?.cancel();
    m._reconnectAttempts = 0;
    m.currentStream = stream;
    m.state = const PlayerState(isBuffering: true);
    notifyListeners();
    try {
      await m.player.open(Media(stream.url));
      final vol = _volumeManager.getVolume(slotId);
      await m.player.setVolume(vol * 100);
    } catch (e) {
      m.state = m.state.copyWith(hasError: true, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<void> updateUrl(String slotId, StreamModel newStream) async {
    final managed = _players[slotId];
    if (managed == null) {
      await loadStream(slotId, newStream);
      return;
    }
    managed._reconnectTimer?.cancel();
    managed._reconnectAttempts = 0;
    managed.currentStream = newStream;
    managed.state = const PlayerState(isBuffering: true);
    notifyListeners();
    try {
      await managed.player.open(Media(newStream.url));
      final vol = _volumeManager.getVolume(slotId);
      await managed.player.setVolume(vol * 100);
    } catch (e) {
      managed.state = managed.state.copyWith(hasError: true, errorMessage: e.toString());
      notifyListeners();
    }
  }

  void _scheduleReconnect(String slotId) {
    final managed = _players[slotId];
    if (managed == null) return;
    if (managed._reconnectAttempts >= ManagedPlayer._maxReconnectAttempts) return;
    managed._reconnectTimer?.cancel();
    final delay = Duration(seconds: 2 + managed._reconnectAttempts * 3);
    managed._reconnectTimer = Timer(delay, () async {
      if (managed.currentStream != null && _autoReconnect) {
        managed._reconnectAttempts++;
        try {
          await managed.player.open(Media(managed.currentStream!.url));
          managed._reconnectAttempts = 0;
          managed.state = managed.state.copyWith(hasError: false, errorMessage: null, isBuffering: true);
          notifyListeners();
        } catch (_) {
          _scheduleReconnect(slotId);
        }
      }
    });
  }

  Future<void> setVolume(String slotId, double volume) async {
    _volumeManager.setVolume(slotId, volume);
    final managed = _players[slotId];
    if (managed != null) {
      await managed.player.setVolume(volume * 100);
    }
  }

  Future<void> play(String slotId) async {
    await _players[slotId]?.player.play();
  }

  Future<void> pause(String slotId) async {
    await _players[slotId]?.player.pause();
  }

  Future<void> togglePlayPause(String slotId) async {
    final managed = _players[slotId];
    if (managed == null) return;
    await managed.player.playOrPause();
  }

  Future<void> removeSlot(String slotId) async {
    final managed = _players.remove(slotId);
    managed?.dispose();
    _volumeManager.removeStream(slotId);
    notifyListeners();
  }

  Future<void> swapStreams(String slotIdA, String slotIdB) async {
    final a = _players[slotIdA];
    final b = _players[slotIdB];
    if (a == null || b == null) return;
    final streamA = a.currentStream;
    final streamB = b.currentStream;
    final volA = _volumeManager.getVolume(slotIdA);
    final volB = _volumeManager.getVolume(slotIdB);
    if (streamA != null) {
      await loadStream(slotIdB, streamA);
      await setVolume(slotIdB, volA);
    } else {
      await removeSlot(slotIdB);
    }
    if (streamB != null) {
      await loadStream(slotIdA, streamB);
      await setVolume(slotIdA, volB);
    } else {
      await removeSlot(slotIdA);
    }
  }

  List<String> get activeSlots => _players.keys.toList();

  @override
  void dispose() {
    for (final mp in _players.values) {
      mp.dispose();
    }
    _players.clear();
    super.dispose();
  }
}
