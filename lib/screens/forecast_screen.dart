import 'package:flutter/material.dart';

import '../data/app_storage.dart';
import '../models/city.dart';
import '../models/forecast.dart';
import '../services/cptec_exception.dart';
import '../services/cptec_service.dart';
import '../theme.dart';
import '../utils/text_utils.dart';
import '../utils/weather_conditions.dart';
import '../widgets/message_view.dart';
import 'chart_screen.dart';

/// Tela 2: previsão de 4 dias da cidade selecionada.
class ForecastScreen extends StatefulWidget {
  final City city;
  final CptecService service;
  final AppStorage storage;
  const ForecastScreen({
    super.key,
    required this.city,
    required this.service,
    required this.storage,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Forecast? _forecast;
  bool _loading = true;
  bool _fromCache = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final f = await widget.service.fetchForecast(widget.city);
      if (f.days.isNotEmpty) await widget.storage.saveForecast(f);
      if (!mounted) return;
      setState(() {
        _forecast = f;
        _fromCache = false;
      });
    } on CptecException catch (e) {
      // Falhou: tenta mostrar a última previsão salva localmente.
      final cached = await widget.storage.loadForecast(widget.city.id);
      if (!mounted) return;
      setState(() {
        if (cached != null) {
          _forecast = cached;
          _fromCache = true;
        } else {
          _error = e.message;
        }
      });
      if (cached != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _forecast;
    final hasDays = f != null && f.days.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.label),
        actions: [
          IconButton(
            tooltip: 'Gráfico de temperaturas',
            icon: const Icon(Icons.show_chart),
            onPressed: hasDays
                ? () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChartScreen(forecast: f)))
                : null,
          ),
          IconButton(
            tooltip: 'Atualizar previsão',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
        bottom: _loading && f != null
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: _buildBody(f, hasDays),
    );
  }

  Widget _buildBody(Forecast? f, bool hasDays) {
    if (_loading && f == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return MessageView(
        icon: Icons.cloud_off,
        message: _error!,
        actionLabel: 'Tentar novamente',
        onAction: _load,
      );
    }
    if (f == null || !hasDays) {
      return MessageView(
        icon: Icons.cloud_queue,
        message: 'Não há previsão disponível para esta cidade no momento.',
        actionLabel: 'Atualizar',
        onAction: _load,
      );
    }

    return RefreshIndicator(
      color: kOrange,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          _Header(forecast: f, fromCache: _fromCache),
          const SizedBox(height: 8),
          ...f.days.map((d) => _DayCard(day: d)),
          const SourceFooter(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Forecast forecast;
  final bool fromCache;
  const _Header({required this.forecast, required this.fromCache});

  @override
  Widget build(BuildContext context) {
    final updated = formatDate(forecast.updatedAt, forecast.rawUpdatedAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(forecast.city.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Atualizado pelo CPTEC/INPE em $updated',
              style: const TextStyle(color: Colors.white)),
          if (fromCache) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sem conexão • dados salvos em ${formatDate(forecast.fetchedAt, null, pattern: "dd/MM/yyyy HH:mm")}',
                style: const TextStyle(color: kDeepOrange, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DayForecast day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final cond = conditionFor(day.code);
    final theme = Theme.of(context);
    final title = day.date == null
        ? (day.rawDate ?? 'Data indisponível')
        : formatDate(day.date, null, pattern: "EEEE, dd/MM/yyyy");

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cond.color.withAlpha(36),
                shape: BoxShape.circle,
              ),
              child: Icon(cond.icon, size: 36, color: cond.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: Colors.brown.shade600)),
                  const SizedBox(height: 2),
                  Text(cond.description, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward,
                          size: 16, color: Color(0xFF1E88E5)),
                      Text(' ${formatTemp(day.min)}C   ',
                          style: theme.textTheme.titleSmall),
                      const Icon(Icons.arrow_upward,
                          size: 16, color: kDeepOrange),
                      Text(' ${formatTemp(day.max)}C',
                          style: theme.textTheme.titleSmall),
                    ],
                  ),
                  if (day.uv != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.light_mode, size: 16, color: kOrange),
                        const SizedBox(width: 4),
                        Text(
                            'IUV ${day.uv!.toStringAsFixed(day.uv! % 1 == 0 ? 0 : 1)} • ${uvLabel(day.uv!)}',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
