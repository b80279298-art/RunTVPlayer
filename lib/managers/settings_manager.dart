import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stream_model.dart';

class SettingsManager extends ChangeNotifier {
  static const String _keyPipSize = 'pipSize';
  static const String _keyCustomPipFraction = 'customPipFraction';
  static const String _keyDefaultLayout = 'defaultLayout';
  static const String _keyDefaultVolume = 'defaultVolume';
  static const String _keyAnimationsEnabled = 'animationsEnabled';
  static const String _keyTapToSwitch = 'tapToSwitch';
  static const String _keyBufferSettings = 'bufferSettings';
  static const String _keyAutoReconnect = 'autoReconnect';

  PipSize _pipSize = PipSize.medium;
  double _customPipFraction = 0.30;
  LayoutMode _defaultLayout = LayoutMode.single;
  double _defaultVolume = 1.0;
  bool _animationsEnabled = true;
  bool _tapToSwitch = true;
  bool _autoReconnect = true;

  PipSize get pipSize => _pipSize;
  double get customPipFraction => _customPipFraction;
  LayoutMode get defaultLayout => _defaultLayout;
  double get defaultVolume => _defaultVolume;
  bool get animationsEnabled => _animationsEnabled;
  bool get tapToSwitch => _tapToSwitch;
  bool get autoReconnect => _autoReconnect;

  double get effectivePipFraction {
    if (_pipSize == PipSize.custom) return _customPipFraction;
    return _pipSize.fraction;
  }

  Map<String, dynamic> get bufferSettings => {
    'cache': 'yes',
    'demuxer-thread': 'yes',
    'demuxer-max-bytes': '2GiB',
    'demuxer-max-back-bytes': '500MiB',
    'demuxer-readahead-secs': '300',
    'cache-pause': 'yes',
    'cache-pause-wait': '30',
    'network-timeout': '90',
    'stream-lavf-o': 'reconnect=1',
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _pipSize = PipSize.values[prefs.getInt(_keyPipSize) ?? PipSize.medium.index];
    _customPipFraction = prefs.getDouble(_keyCustomPipFraction) ?? 0.30;
    _defaultLayout = LayoutMode.values[prefs.getInt(_keyDefaultLayout) ?? LayoutMode.single.index];
    _defaultVolume = prefs.getDouble(_keyDefaultVolume) ?? 1.0;
    _animationsEnabled = prefs.getBool(_keyAnimationsEnabled) ?? true;
    _tapToSwitch = prefs.getBool(_keyTapToSwitch) ?? true;
    _autoReconnect = prefs.getBool(_keyAutoReconnect) ?? true;
    notifyListeners();
  }

  Future<void> setPipSize(PipSize size) async {
    _pipSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPipSize, size.index);
    notifyListeners();
  }

  Future<void> setCustomPipFraction(double fraction) async {
    _customPipFraction = fraction.clamp(0.15, 0.45);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyCustomPipFraction, _customPipFraction);
    notifyListeners();
  }

  Future<void> setDefaultLayout(LayoutMode layout) async {
    _defaultLayout = layout;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDefaultLayout, layout.index);
    notifyListeners();
  }

  Future<void> setDefaultVolume(double volume) async {
    _defaultVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDefaultVolume, _defaultVolume);
    notifyListeners();
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAnimationsEnabled, enabled);
    notifyListeners();
  }

  Future<void> setTapToSwitch(bool enabled) async {
    _tapToSwitch = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTapToSwitch, enabled);
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool enabled) async {
    _autoReconnect = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoReconnect, enabled);
    notifyListeners();
  }
}
