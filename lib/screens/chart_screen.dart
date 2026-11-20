import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/forecast.dart';
import '../theme.dart';
import '../utils/text_utils.dart';
import '../widgets/message_view.dart';

/// Tela 3: gráfico das temperaturas mínima e máxima.
class ChartScreen extends StatelessWidget {
  final Forecast forecast;
  const ChartScreen({super.key, required this.forecast});

  static const _minColor = Color(0xFF1E88E5);
  static const _maxColor = kDeepOrange;

  @override
  Widget build(BuildContext context) {
    final days = forecast.days;
    final labels = days
        .map((d) => d.date == null
            ? (d.rawDate ?? '?')
            : formatDate(d.date, null, pattern: 'dd/MM'))
        .toList();

    List<FlSpot> spots(double? Function(DayForecast) pick) => [
          for (var i = 0; i < days.length; i++)
            if (pick(days[i]) != null) FlSpot(i.toDouble(), pick(days[i])!),
        ];

    final minSpots = spots((d) => d.min);
    final maxSpots = spots((d) => d.max);
    final all = [...minSpots, ...maxSpots];

    return Scaffold(
      appBar: AppBar(title: Text('Temperaturas • ${forecast.city.label}')),
      body: all.isEmpty
          ? const MessageView(
              icon: Icons.show_chart,
              message: 'Não há dados de temperatura para exibir.')
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Temperatura mínima e máxima (°C)',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _Legend(color: _minColor, text: 'Mínima'),
                      SizedBox(width: 16),
                      _Legend(color: _maxColor, text: 'Máxima'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: LineChart(_data(labels, minSpots, maxSpots, all, days.length)),
                  ),
                  const Spacer(),
                  const SourceFooter(),
                ],
              ),
            ),
    );
  }

  LineChartData _data(List<String> labels, List<FlSpot> minSpots,
      List<FlSpot> maxSpots, List<FlSpot> all, int n) {
    final ys = all.map((s) => s.y);
    final minY = ys.reduce(math.min).floorToDouble() - 2;
    final maxY = ys.reduce(math.max).ceilToDouble() + 2;

    LineChartBarData line(List<FlSpot> s, Color c) => LineChartBarData(
          spots: s,
          isCurved: true,
          color: c,
          barWidth: 4,
          dotData: const FlDotData(show: true),
        );

    return LineChartData(
      minX: 0,
      maxX: math.max(1, n - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [line(minSpots, _minColor), line(maxSpots, _maxColor)],
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (v, meta) => Text('${v.round()}°',
                style: const TextStyle(fontSize: 11)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (v != i.toDouble() || i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(labels[i], style: const TextStyle(fontSize: 11)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touched) => touched
              .map((s) => LineTooltipItem(
                    '${labels[s.x.toInt()]}\n${s.y.toStringAsFixed(0)}°C',
                    const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(text),
        ],
      );
}
