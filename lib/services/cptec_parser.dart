import 'dart:convert';

import 'package:xml/xml.dart';

import '../models/city.dart';
import '../models/forecast.dart';
import 'cptec_exception.dart';

/// Leitura dos XMLs do CPTEC/INPE, tolerante a campos ausentes.
class CptecParser {
  /// O serviço responde em ISO-8859-1 (a menos que o cabeçalho diga UTF-8).
  static String decode(List<int> bytes) {
    final head = latin1.decode(bytes.take(100).toList()).toLowerCase();
    return head.contains('utf-8') ? utf8.decode(bytes, allowMalformed: true) : latin1.decode(bytes);
  }

  static XmlDocument _parse(String body) {
    try {
      return XmlDocument.parse(body.trim());
    } on XmlException {
      throw const CptecException.invalid();
    }
  }

  static String? _text(XmlElement parent, String name) {
    final t = parent.getElement(name)?.innerText.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static double? _num(String? s) =>
      s == null ? null : double.tryParse(s.replaceAll(',', '.'));

  static DateTime? _date(String? s) => s == null ? null : DateTime.tryParse(s);

  static List<City> parseCities(String body) {
    final doc = _parse(body);
    if (doc.rootElement.name.local != 'cidades') {
      throw const CptecException.invalid();
    }
    final cities = <City>[];
    for (final el in doc.rootElement.findElements('cidade')) {
      final id = int.tryParse(_text(el, 'id') ?? '');
      final name = _text(el, 'nome');
      // O serviço devolve id -1 / nome "null" quando nada é encontrado.
      if (id == null || id <= 0 || name == null || name.toLowerCase() == 'null') {
        continue;
      }
      cities.add(City(id: id, name: name, uf: _text(el, 'uf') ?? ''));
    }
    return cities;
  }

  static Forecast parseForecast(String body, City city, {DateTime? now}) {
    final doc = _parse(body);
    final root = doc.rootElement;
    if (root.name.local != 'cidade') throw const CptecException.invalid();

    final days = <DayForecast>[];
    for (final el in root.findElements('previsao')) {
      final raw = _text(el, 'dia');
      days.add(DayForecast(
        rawDate: raw,
        date: _date(raw),
        code: _text(el, 'tempo')?.toLowerCase(),
        min: _num(_text(el, 'minima')),
        max: _num(_text(el, 'maxima')),
        uv: _num(_text(el, 'iuv')),
      ));
    }
    final rawUpdated = _text(root, 'atualizacao');
    return Forecast(
      city: city,
      days: days,
      rawUpdatedAt: rawUpdated,
      updatedAt: _date(rawUpdated),
      fetchedAt: now ?? DateTime.now(),
    );
  }
}
