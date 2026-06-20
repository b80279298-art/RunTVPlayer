import 'package:flutter/material.dart';

class VolumeManager extends ChangeNotifier {
  final Map<String, double> _volumes = {};
  static const double _defaultVolume = 1.0;

  double getVolume(String streamId) => _volumes[streamId] ?? _defaultVolume;

  void setVolume(String streamId, double volume) {
    _volumes[streamId] = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void removeStream(String streamId) {
    _volumes.remove(streamId);
    notifyListeners();
  }

  void initStream(String streamId, {double? initialVolume}) {
    if (!_volumes.containsKey(streamId)) {
      _volumes[streamId] = initialVolume ?? _defaultVolume;
    }
  }

  void setAllVolumes(double volume) {
    for (final key in _volumes.keys.toList()) {
      _volumes[key] = volume.clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  Map<String, double> get allVolumes => Map.unmodifiable(_volumes);

  void clear() {
    _volumes.clear();
    notifyListeners();
  }
}
