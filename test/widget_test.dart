import 'package:flutter_test/flutter_test.dart';
import 'package:previsao_tempo/models/city.dart';
import 'package:previsao_tempo/services/cptec_exception.dart';
import 'package:previsao_tempo/services/cptec_parser.dart';
import 'package:previsao_tempo/utils/text_utils.dart';
import 'package:previsao_tempo/utils/weather_conditions.dart';

void main() {
  const city = City(id: 244, name: 'São Paulo', uf: 'SP');

  test('lista de cidades', () {
    const xml = '<?xml version="1.0" encoding="ISO-8859-1"?>'
        '<cidades><cidade><nome>São Paulo</nome><uf>SP</uf><id>244</id></cidade>'
        '<cidade><nome>São Paulo de Olivença</nome><uf>AM</uf><id>4780</id></cidade></cidades>';
    final cities = CptecParser.parseCities(xml);
    expect(cities.length, 2);
    expect(cities.first.id, 244);
    expect(cities.first.uf, 'SP');
  });

  test('nenhuma cidade encontrada', () {
    const xml =
        '<cidades><cidade><nome>null</nome><uf></uf><id>-1</id></cidade></cidades>';
    expect(CptecParser.parseCities(xml), isEmpty);
  });

  test('previsão de 4 dias com campos ausentes', () {
    const xml = '<cidade><nome>São Paulo</nome><uf>SP</uf>'
        '<atualizacao>2026-11-19</atualizacao>'
        '<previsao><dia>2026-11-19</dia><tempo>pn</tempo><maxima>30</maxima><minima>19</minima><iuv>12.0</iuv></previsao>'
        '<previsao><dia>2026-11-20</dia><tempo>c</tempo></previsao>'
        '<previsao><dia>2026-11-21</dia></previsao>'
        '<previsao><dia>2026-11-22</dia><tempo>xx</tempo><maxima>abc</maxima></previsao>'
        '</cidade>';
    final f = CptecParser.parseForecast(xml, city);
    expect(f.days.length, 4);
    expect(f.updatedAt, DateTime(2026, 11, 19));
    expect(f.days[0].max, 30);
    expect(f.days[0].uv, 12.0);
    expect(f.days[1].min, isNull);
    expect(f.days[3].max, isNull);
    expect(conditionFor(f.days[3].code).description, 'Condição não informada');
  });

  test('resposta inválida', () {
    expect(() => CptecParser.parseForecast('<html>', city),
        throwsA(isA<CptecException>()));
    expect(() => CptecParser.parseCities('não é xml'),
        throwsA(isA<CptecException>()));
  });

  test('siglas e UV', () {
    expect(conditionCount, 40);
    expect(conditionFor('pn').description, 'Parcialmente Nublado');
    expect(conditionFor('PS').description, 'Predomínio de Sol');
    expect(uvLabel(2), 'Baixo');
    expect(uvLabel(12), 'Extremo');
    expect(removeAccents('São Paulo'), 'Sao Paulo');
  });
}
