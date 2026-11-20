/// Localidade retornada pelo serviço do CPTEC/INPE.
/// [id] é o identificador do próprio serviço, usado nas consultas de previsão.
class City {
  final int id;
  final String name;
  final String uf;

  const City({required this.id, required this.name, required this.uf});

  String get label => uf.isEmpty ? name : '$name - $uf';

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'uf': uf};

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'] as int,
        name: json['name'] as String,
        uf: (json['uf'] as String?) ?? '',
      );
}
