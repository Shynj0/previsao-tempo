// Prepara o projeto: gera as pastas de plataforma (android/ios/...),
// libera acesso à internet no Android, instala dependências e gera o ícone.
//
// Uso (na raiz do projeto):  dart tool/setup.dart
import 'dart:io';

Future<void> run(String cmd, List<String> args) async {
  stdout.writeln('\n> $cmd ${args.join(' ')}');
  final p = await Process.start(cmd, args,
      runInShell: true, mode: ProcessStartMode.inheritStdio);
  final code = await p.exitCode;
  if (code != 0) {
    stderr.writeln('\nFalhou ($code): $cmd ${args.join(' ')}');
    exit(code);
  }
}

Future<void> main() async {
  await run('flutter', [
    'create',
    '--project-name',
    'previsao_tempo',
    '--org',
    'br.fatec',
    '.'
  ]);

  // Permissão de internet (necessária para a BrasilAPI no build release).
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (manifest.existsSync()) {
    var xml = manifest.readAsStringSync();
    if (!xml.contains('android.permission.INTERNET')) {
      xml = xml.replaceFirst('<application',
          '<uses-permission android:name="android.permission.INTERNET"/>\n    <application');
    }
    xml = xml.replaceFirst('android:label="previsao_tempo"',
        'android:label="Previsão do Tempo"');
    manifest.writeAsStringSync(xml);
    stdout.writeln('AndroidManifest.xml atualizado (INTERNET + nome do app).');
  }

  await run('flutter', ['pub', 'get']);
  await run('dart', ['run', 'flutter_launcher_icons']);

  stdout.writeln('\nPronto! Execute o app com:  flutter run');
}
