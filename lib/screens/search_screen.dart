import 'package:flutter/material.dart';

import '../data/app_storage.dart';
import '../models/city.dart';
import '../services/cptec_exception.dart';
import '../services/cptec_service.dart';
import '../theme.dart';
import '../widgets/message_view.dart';
import 'forecast_screen.dart';

/// Tela 1: pesquisa de cidades no CPTEC/INPE.
class SearchScreen extends StatefulWidget {
  final CptecService service;
  final AppStorage storage;
  const SearchScreen({super.key, required this.service, required this.storage});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  bool _loading = false;
  String? _error;
  List<City>? _results;
  String _lastQuery = '';
  List<City> _recents = [];
  City? _lastCity;

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocal() async {
    final recents = await widget.storage.loadRecents();
    final last = await widget.storage.loadLastCity();
    if (!mounted) return;
    setState(() {
      _recents = recents;
      _lastCity = last;
    });
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    FocusScope.of(context).unfocus();
    if (q.length < 2) {
      setState(() {
        _error = 'Digite pelo menos 2 letras do nome da cidade.';
        _results = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _lastQuery = q;
    });
    try {
      final cities = await widget.service.searchCities(q);
      if (!mounted) return;
      setState(() => _results = cities);
    } on CptecException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _results = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(City city) async {
    await widget.storage.saveSelectedCity(city);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ForecastScreen(
          city: city, service: widget.service, storage: widget.storage),
    ));
    _loadLocal();
  }

  Widget _cityTile(City c, {IconData icon = Icons.location_city}) => Card(
        child: ListTile(
          leading: Icon(icon, color: kOrange),
          title: Text(c.name),
          subtitle: Text(c.uf.isEmpty ? 'UF não informada' : c.uf),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(c),
        ),
      );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return MessageView(
        icon: Icons.error_outline,
        message: _error!,
        actionLabel: _lastQuery.isEmpty ? null : 'Tentar novamente',
        onAction: _lastQuery.isEmpty ? null : _search,
      );
    }

    final results = _results;
    if (results != null) {
      if (results.isEmpty) {
        return MessageView(
          icon: Icons.search_off,
          message: 'Nenhuma cidade encontrada para “$_lastQuery”.',
        );
      }
      return ListView(
        padding: const EdgeInsets.all(12),
        children: results.map(_cityTile).toList(),
      );
    }

    // Estado inicial: última cidade e histórico (persistência local).
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (_lastCity != null) ...[
          const _SectionTitle('Última cidade consultada'),
          _cityTile(_lastCity!, icon: Icons.history),
        ],
        if (_recents.isNotEmpty) ...[
          Row(
            children: [
              const Expanded(child: _SectionTitle('Cidades recentes')),
              TextButton(
                onPressed: () async {
                  await widget.storage.clearRecents();
                  _loadLocal();
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
          ..._recents.map(_cityTile),
        ],
        if (_lastCity == null && _recents.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: MessageView(
              icon: Icons.wb_sunny,
              message:
                  'Pesquise uma cidade para ver a previsão do tempo dos próximos dias.',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: kHeaderGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.white, size: 30),
                        SizedBox(width: 10),
                        Text('Previsão do Tempo',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'Digite o nome da cidade',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Pesquisar',
                          icon: const Icon(Icons.arrow_forward, color: kDeepOrange),
                          onPressed: _search,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _body()),
          const SourceFooter(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: kDeepOrange, fontWeight: FontWeight.bold)),
      );
}
