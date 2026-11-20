import 'package:intl/intl.dart';

String removeAccents(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const to = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

String formatDate(DateTime? d, String? raw, {String pattern = 'dd/MM/yyyy'}) {
  if (d == null) return raw ?? 'Data indisponível';
  return DateFormat(pattern, 'pt_BR').format(d);
}

String formatTemp(double? t) => t == null ? '--' : '${t.round()}°';

/// Classificação do Índice Ultravioleta.
String uvLabel(double uv) {
  if (uv < 3) return 'Baixo';
  if (uv < 6) return 'Moderado';
  if (uv < 8) return 'Alto';
  if (uv < 11) return 'Muito alto';
  return 'Extremo';
}
