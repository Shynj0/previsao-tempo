import 'package:flutter/material.dart';

enum _Cat { sol, parcial, nublado, encoberto, possivel, chuva, tempestade, nevoeiro, frio, indef }

class WeatherCondition {
  final String description;
  final IconData icon;
  final Color color;
  const WeatherCondition(this.description, this.icon, this.color);
}

const _icons = <_Cat, (IconData, Color)>{
  _Cat.sol: (Icons.wb_sunny, Color(0xFFFFA000)),
  _Cat.parcial: (Icons.wb_cloudy, Color(0xFFF57C00)),
  _Cat.nublado: (Icons.cloud_queue, Color(0xFF78909C)),
  _Cat.encoberto: (Icons.cloud, Color(0xFF607D8B)),
  _Cat.possivel: (Icons.umbrella, Color(0xFF5C9CE6)),
  _Cat.chuva: (Icons.water_drop, Color(0xFF1E88E5)),
  _Cat.tempestade: (Icons.thunderstorm, Color(0xFF5E35B1)),
  _Cat.nevoeiro: (Icons.foggy, Color(0xFF90A4AE)),
  _Cat.frio: (Icons.ac_unit, Color(0xFF26C6DA)),
  _Cat.indef: (Icons.help_outline, Color(0xFF9E9E9E)),
};

/// Siglas das condições do tempo (tabela oficial do CPTEC/INPE).
const _table = <String, (String, _Cat)>{
  'ec': ('Encoberto com Chuvas Isoladas', _Cat.chuva),
  'ci': ('Chuvas Isoladas', _Cat.chuva),
  'c': ('Chuva', _Cat.chuva),
  'in': ('Instável', _Cat.possivel),
  'pp': ('Possibilidade de Pancadas de Chuva', _Cat.possivel),
  'cm': ('Chuva pela Manhã', _Cat.chuva),
  'cn': ('Chuva à Noite', _Cat.chuva),
  'pt': ('Pancadas de Chuva à Tarde', _Cat.chuva),
  'pm': ('Pancadas de Chuva pela Manhã', _Cat.chuva),
  'np': ('Nublado e Pancadas de Chuva', _Cat.chuva),
  'pc': ('Pancadas de Chuva', _Cat.chuva),
  'pn': ('Parcialmente Nublado', _Cat.parcial),
  'cv': ('Chuvisco', _Cat.chuva),
  'ch': ('Chuvoso', _Cat.chuva),
  't': ('Tempestade', _Cat.tempestade),
  'ps': ('Predomínio de Sol', _Cat.sol),
  'e': ('Encoberto', _Cat.encoberto),
  'n': ('Nublado', _Cat.nublado),
  'cl': ('Céu Claro', _Cat.sol),
  'nv': ('Nevoeiro', _Cat.nevoeiro),
  'g': ('Geada', _Cat.frio),
  'ne': ('Neve', _Cat.frio),
  'nd': ('Não Definido', _Cat.indef),
  'pnt': ('Pancadas de Chuva à Noite', _Cat.chuva),
  'psc': ('Possibilidade de Chuva', _Cat.possivel),
  'pcm': ('Possibilidade de Chuva pela Manhã', _Cat.possivel),
  'pct': ('Possibilidade de Chuva à Tarde', _Cat.possivel),
  'pcn': ('Possibilidade de Chuva à Noite', _Cat.possivel),
  'npt': ('Nublado com Pancadas à Tarde', _Cat.chuva),
  'npn': ('Nublado com Pancadas à Noite', _Cat.chuva),
  'ncn': ('Nublado com Possibilidade de Chuva à Noite', _Cat.possivel),
  'nct': ('Nublado com Possibilidade de Chuva à Tarde', _Cat.possivel),
  'ncm': ('Nublado com Possibilidade de Chuva pela Manhã', _Cat.possivel),
  'npm': ('Nublado com Pancadas pela Manhã', _Cat.chuva),
  'npp': ('Nublado com Possibilidade de Chuva', _Cat.possivel),
  'vn': ('Variação de Nebulosidade', _Cat.parcial),
  'ct': ('Chuva à Tarde', _Cat.chuva),
  'ppn': ('Possibilidade de Pancadas de Chuva à Noite', _Cat.possivel),
  'ppt': ('Possibilidade de Pancadas de Chuva à Tarde', _Cat.possivel),
  'ppm': ('Possibilidade de Pancadas de Chuva pela Manhã', _Cat.possivel),
};

WeatherCondition conditionFor(String? code) {
  final entry = code == null ? null : _table[code.trim().toLowerCase()];
  if (entry == null) {
    final (icon, color) = _icons[_Cat.indef]!;
    return WeatherCondition('Condição não informada', icon, color);
  }
  final (icon, color) = _icons[entry.$2]!;
  return WeatherCondition(entry.$1, icon, color);
}

int get conditionCount => _table.length;
