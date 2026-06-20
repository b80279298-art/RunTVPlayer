import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stream_model.dart';

class FavoriteManager extends ChangeNotifier {
  static const String _key = 'favorites';
  List<StreamModel> _favorites = [];

  List<StreamModel> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _favorites = raw
        .map((e) => StreamModel.fromJson(json.decode(e) as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _favorites.map((e) => json.encode(e.toJson())).toList(),
    );
  }

  bool isFavorite(String id) => _favorites.any((s) => s.id == id);

  Future<void> add(StreamModel stream) async {
    if (!isFavorite(stream.id)) {
      _favorites.insert(0, stream.copyWith(isFavorite: true));
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _favorites.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggle(StreamModel stream) async {
    if (isFavorite(stream.id)) {
      await remove(stream.id);
    } else {
      await add(stream);
    }
  }

  Future<void> clear() async {
    _favorites.clear();
    await _save();
    notifyListeners();
  }
}
