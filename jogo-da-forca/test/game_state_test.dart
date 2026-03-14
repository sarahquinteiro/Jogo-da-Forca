import 'package:test/test.dart';
import '../lib/game_state.dart';

void main() {
  group('GameState — inicialização', () {
    test('começa com 6 vidas', () {
      final g = GameState();
      expect(g.vidas, equals(6));
    });

    test('começa sem erros', () {
      final g = GameState();
      expect(g.erros, isEmpty);
    });

    test('palavra secreta não é vazia', () {
      final g = GameState();
      expect(g.palavraSecreta, isNotEmpty);
    });

    test('todas as letras começam ocultas', () {
      final g = GameState();
      expect(g.reveladas.every((r) => r == false), isTrue);
    });

    test('resultado inicial é emAndamento', () {
      final g = GameState();
      expect(g.resultado, equals(ResultadoJogo.emAndamento));
    });
  });

  group('GameState — tentarLetra()', () {
    test('rejeita entrada vazia', () {
      final g = GameState();
      final r = g.tentarLetra('');
      expect(r.valida, isFalse);
      expect(r.tipo, equals('erro'));
    });

    test('rejeita mais de uma letra', () {
      final g = GameState();
      final r = g.tentarLetra('AB');
      expect(r.valida, isFalse);
    });

    test('rejeita número', () {
      final g = GameState();
      final r = g.tentarLetra('3');
      expect(r.valida, isFalse);
    });

    test('é case insensitive', () {
      final g = GameState();
      final primeiraLetra = g.palavraSecreta[0];
      final r = g.tentarLetra(primeiraLetra.toLowerCase());
      expect(r.valida, isTrue);
      expect(r.tipo, equals('ok'));
    });

    test('letra correta revela posições e não desconta vida', () {
      final g = GameState();
      final letra = g.palavraSecreta[0];
      final vidasAntes = g.vidas;
      g.tentarLetra(letra);
      expect(g.vidas, equals(vidasAntes));
      expect(g.reveladas[0], isTrue);
    });

    test('letra errada desconta uma vida e adiciona aos erros', () {
      final g = GameState();
      // Garante uma letra que não está na palavra
      const candidatas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final letraErrada = candidatas.split('').firstWhere(
        (c) => !g.palavraSecreta.contains(c),
      );
      final vidasAntes = g.vidas;
      g.tentarLetra(letraErrada);
      expect(g.vidas, equals(vidasAntes - 1));
      expect(g.erros, contains(letraErrada));
    });

    test('não desconta vida ao repetir letra errada', () {
      final g = GameState();
      const candidatas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final letraErrada = candidatas.split('').firstWhere(
        (c) => !g.palavraSecreta.contains(c),
      );
      g.tentarLetra(letraErrada);
      final vidasApos1 = g.vidas;
      final r = g.tentarLetra(letraErrada); // repetição
      expect(r.valida, isFalse);
      expect(g.vidas, equals(vidasApos1)); // sem desconto
    });

    test('não aceita letra já revelada novamente', () {
      final g = GameState();
      final letra = g.palavraSecreta[0];
      g.tentarLetra(letra);
      final r = g.tentarLetra(letra);
      expect(r.valida, isFalse);
    });
  });

  group('GameState — chutar()', () {
    test('chute correto revela todas as letras', () {
      final g = GameState();
      g.chutar(g.palavraSecreta);
      expect(g.reveladas.every((r) => r), isTrue);
    });

    test('chute correto leva à vitória', () {
      final g = GameState();
      g.chutar(g.palavraSecreta);
      expect(g.resultado, equals(ResultadoJogo.vitoria));
    });

    test('chute errado desconta 2 vidas', () {
      final g = GameState();
      final vidasAntes = g.vidas;
      g.chutar('XXXXXXXXXXX');
      expect(g.vidas, equals(vidasAntes - 2));
    });

    test('chute vazio é rejeitado', () {
      final g = GameState();
      final r = g.chutar('');
      expect(r.valida, isFalse);
    });

    test('chute é case insensitive', () {
      final g = GameState();
      final r = g.chutar(g.palavraSecreta.toLowerCase());
      expect(r.valida, isTrue);
      expect(g.resultado, equals(ResultadoJogo.vitoria));
    });
  });

  group('GameState — condições de fim', () {
    test('derrota quando vidas chegam a 0', () {
      final g = GameState();
      const candidatas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final letrasErradas = candidatas.split('').where(
        (c) => !g.palavraSecreta.contains(c),
      ).take(6).toList();

      for (final l in letrasErradas) {
        g.tentarLetra(l);
      }
      expect(g.resultado, equals(ResultadoJogo.derrota));
    });

    test('reiniciar reseta o estado completamente', () {
      final g = GameState();
      g.chutar('XXXXXXXXXXX');
      g.reiniciar();
      expect(g.vidas, equals(6));
      expect(g.erros, isEmpty);
      expect(g.encerrado, isFalse);
      expect(g.resultado, equals(ResultadoJogo.emAndamento));
    });
  });
}
