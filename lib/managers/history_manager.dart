import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stream_model.dart';

class HistoryManager extends ChangeNotifier {
  static const String _key = 'history';
  static const int _maxItems = 50;
  List<StreamModel> _history = [];

  List<StreamModel> get history => List.unmodifiable(_history);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _history = raw
        .map((e) => StreamModel.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _history.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  Future<void> record(StreamModel stream) async {
    _history.removeWhere((s) => s.id == stream.id);
    final updated = stream.copyWith(lastUsed: DateTime.now());
    _history.insert(0, updated);
    if (_history.length > _maxItems) {
      _history = _history.sublist(0, _maxItems);
    }
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _history.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _history.clear();
    await _save();
    notifyListeners();
  }
}
