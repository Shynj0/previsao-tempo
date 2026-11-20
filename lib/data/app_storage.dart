import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';
import '../models/forecast.dart';

/// Persistência local com shared_preferences (JSON):
/// - última cidade selecionada;
/// - histórico das cidades recentes (máx. 8);
/// - cache da última previsão de cada cidade (uso offline).
class AppStorage {
  static const _lastKey = 'last_city';
  static const _recentsKey = 'recent_cities';
  static const _maxRecents = 8;
  static String _forecastKey(int id) => 'forecast_$id';

  Future<City?> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastKey);
    if (raw == null) return null;
    try {
      return City.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<City>> loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentsKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSelectedCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastKey, jsonEncode(city.toJson()));
    final recents = await loadRecents();
    recents.removeWhere((c) => c.id == city.id);
    recents.insert(0, city);
    final trimmed = recents.take(_maxRecents).toList();
    await prefs.setString(
        _recentsKey, jsonEncode(trimmed.map((c) => c.toJson()).toList()));
  }

  Future<void> clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentsKey);
    await prefs.remove(_lastKey);
  }

  Future<void> saveForecast(Forecast f) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_forecastKey(f.city.id), jsonEncode(f.toJson()));
  }

  Future<Forecast?> loadForecast(int cityId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_forecastKey(cityId));
    if (raw == null) return null;
    try {
      return Forecast.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
