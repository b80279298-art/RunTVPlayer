import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/stream_model.dart';

class StreamManager extends ChangeNotifier {
  static const String _key = 'streams';
  static const _uuid = Uuid();
  List<StreamModel> _streams = [];

  List<StreamModel> get streams => List.unmodifiable(_streams);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _streams = raw
        .map((e) => StreamModel.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _streams.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  Future<StreamModel> addStream({
    required String name,
    required String url,
    StreamType? type,
  }) async {
    final stream = StreamModel(
      id: _uuid.v4(),
      name: name,
      url: url,
      type: type ?? StreamTypeExtension.fromUrl(url),
    );
    _streams.insert(0, stream);
    await _save();
    notifyListeners();
    return stream;
  }

  Future<void> updateStream(StreamModel updated) async {
    final idx = _streams.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      _streams[idx] = updated;
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeStream(String id) async {
    _streams.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  StreamModel? findById(String id) {
    try {
      return _streams.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<StreamModel> quickStream({required String url, String? name}) async {
    return addStream(
      name: name ?? _generateName(url),
      url: url,
    );
  }

  String _generateName(String url) {
    try {
      final uri = Uri.parse(url);
      final parts = uri.pathSegments.where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.last.replaceAll(RegExp(r'\.\w+$'), '');
    } catch (_) {}
    return 'Stream ${_streams.length + 1}';
  }
}
