import 'city.dart';

/// Previsão de um dia. Todos os campos do serviço podem estar ausentes.
class DayForecast {
  final DateTime? date;
  final String? rawDate;
  final String? code; // sigla da condição do tempo (ex.: "pn")
  final double? min;
  final double? max;
  final double? uv;

  const DayForecast({
    this.date,
    this.rawDate,
    this.code,
    this.min,
    this.max,
    this.uv,
  });

  Map<String, dynamic> toJson() => {
        'date': date?.toIso8601String(),
        'rawDate': rawDate,
        'code': code,
        'min': min,
        'max': max,
        'uv': uv,
      };

  factory DayForecast.fromJson(Map<String, dynamic> j) => DayForecast(
        date: j['date'] == null ? null : DateTime.tryParse(j['date'] as String),
        rawDate: j['rawDate'] as String?,
        code: j['code'] as String?,
        min: (j['min'] as num?)?.toDouble(),
        max: (j['max'] as num?)?.toDouble(),
        uv: (j['uv'] as num?)?.toDouble(),
      );
}

class Forecast {
  final City city;
  final DateTime? updatedAt; // data de atualização informada pelo serviço
  final String? rawUpdatedAt;
  final List<DayForecast> days;
  final DateTime fetchedAt; // quando o app consultou/salvou (cache)

  const Forecast({
    required this.city,
    required this.days,
    required this.fetchedAt,
    this.updatedAt,
    this.rawUpdatedAt,
  });

  Map<String, dynamic> toJson() => {
        'city': city.toJson(),
        'updatedAt': updatedAt?.toIso8601String(),
        'rawUpdatedAt': rawUpdatedAt,
        'days': days.map((d) => d.toJson()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory Forecast.fromJson(Map<String, dynamic> j) => Forecast(
        city: City.fromJson(j['city'] as Map<String, dynamic>),
        updatedAt: j['updatedAt'] == null
            ? null
            : DateTime.tryParse(j['updatedAt'] as String),
        rawUpdatedAt: j['rawUpdatedAt'] as String?,
        days: (j['days'] as List)
            .map((e) => DayForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        fetchedAt: DateTime.parse(j['fetchedAt'] as String),
      );
}
