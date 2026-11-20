import 'dart:async';

import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/forecast.dart';
import '../utils/text_utils.dart';
import 'cptec_exception.dart';
import 'cptec_parser.dart';

/// Cliente do serviço XML do CPTEC/INPE.
/// Documentação: https://servicos.cptec.inpe.br/XML/
class CptecService {
  static const _base = 'https://servicos.cptec.inpe.br/XML';
  static const _timeout = Duration(seconds: 20);

  final http.Client _client;
  CptecService([http.Client? client]) : _client = client ?? http.Client();

  Future<String> _get(String url) async {
    try {
      final res = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode != 200) {
        throw CptecException.unavailable(res.statusCode);
      }
      return CptecParser.decode(res.bodyBytes);
    } on CptecException {
      rethrow;
    } on TimeoutException {
      throw const CptecException.timeout();
    } catch (_) {
      throw const CptecException.connection();
    }
  }

  /// Localidades que começam com [name] (sem acentos, como exige o serviço).
  Future<List<City>> searchCities(String name) async {
    final q = Uri.encodeComponent(removeAccents(name.trim().toLowerCase()));
    final body = await _get('$_base/listaCidades?city=$q');
    return CptecParser.parseCities(body);
  }

  /// Previsão de 4 dias usando o código retornado pelo próprio serviço.
  Future<Forecast> fetchForecast(City city) async {
    final body = await _get('$_base/cidade/${city.id}/previsao.xml');
    return CptecParser.parseForecast(body, city);
  }
}
