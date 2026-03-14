import 'words.dart';

/// Enumeração dos possíveis estados de fim de jogo.
enum ResultadoJogo { vitoria, derrota, emAndamento }

/// Representa o resultado de uma tentativa de letra ou chute.
class ResultadoTentativa {
  final bool valida;
  final String mensagem;
  final String tipo; // 'ok' | 'erro' | 'aviso'

  const ResultadoTentativa({
    required this.valida,
    required this.mensagem,
    required this.tipo,
  });
}

/// Contém todo o estado de uma partida do Jogo da Forca.
class GameState {
  late String palavraSecreta;
  late List<bool> reveladas;
  late List<String> erros;
  late int vidas;
  late bool encerrado;

  static const int vidasIniciais = 6;

  GameState() {
    reiniciar();
  }

  /// Reinicia o jogo sorteando uma nova palavra.
  void reiniciar() {
    palavraSecreta = sortearPalavra();
    reveladas = List.filled(palavraSecreta.length, false);
    erros = [];
    vidas = vidasIniciais;
    encerrado = false;
  }

  /// Retorna a palavra como lista de caracteres visíveis (letra ou null).
  List<String?> get palavraVisivel {
    return List.generate(
      palavraSecreta.length,
      (i) => reveladas[i] ? palavraSecreta[i] : null,
    );
  }

  /// Verifica se a letra já foi revelada corretamente.
  bool _letraJaRevelada(String letra) {
    return List.generate(palavraSecreta.length, (i) => i)
        .any((i) => palavraSecreta[i] == letra && reveladas[i]);
  }

  /// Processa uma tentativa de letra única.
  /// Retorna um [ResultadoTentativa] descrevendo o que aconteceu.
  ResultadoTentativa tentarLetra(String entrada) {
    final letra = entrada.trim().toUpperCase();

    if (encerrado) {
      return const ResultadoTentativa(
        valida: false,
        mensagem: 'O jogo já foi encerrado.',
        tipo: 'aviso',
      );
    }

    if (letra.isEmpty || !RegExp(r'^[A-Z]$').hasMatch(letra)) {
      return const ResultadoTentativa(
        valida: false,
        mensagem: '⚠ Digite apenas UMA letra (A-Z).',
        tipo: 'erro',
      );
    }

    if (erros.contains(letra)) {
      return ResultadoTentativa(
        valida: false,
        mensagem: '⚠ Você já tentou "$letra" e errou! Tente outra.',
        tipo: 'aviso',
      );
    }

    if (_letraJaRevelada(letra)) {
      return ResultadoTentativa(
        valida: false,
        mensagem: '⚠ A letra "$letra" já foi revelada! Tente outra.',
        tipo: 'aviso',
      );
    }

    if (palavraSecreta.contains(letra)) {
      int count = 0;
      for (int i = 0; i < palavraSecreta.length; i++) {
        if (palavraSecreta[i] == letra) {
          reveladas[i] = true;
          count++;
        }
      }
      return ResultadoTentativa(
        valida: true,
        mensagem: '✓ Boa! A letra "$letra" aparece ${count}x na palavra.',
        tipo: 'ok',
      );
    } else {
      erros.add(letra);
      vidas--;
      return ResultadoTentativa(
        valida: true,
        mensagem: '✗ A letra "$letra" não está na palavra. -1 vida!',
        tipo: 'erro',
      );
    }
  }

  /// Processa um chute da palavra completa.
  /// Se errar, perde 2 vidas.
  ResultadoTentativa chutar(String entrada) {
    final chute = entrada.trim().toUpperCase();

    if (encerrado) {
      return const ResultadoTentativa(
        valida: false,
        mensagem: 'O jogo já foi encerrado.',
        tipo: 'aviso',
      );
    }

    if (chute.isEmpty) {
      return const ResultadoTentativa(
        valida: false,
        mensagem: '⚠ Digite a palavra para chutar.',
        tipo: 'erro',
      );
    }

    if (chute == palavraSecreta) {
      for (int i = 0; i < reveladas.length; i++) {
        reveladas[i] = true;
      }
      return ResultadoTentativa(
        valida: true,
        mensagem: '🎉 Acertou o chute! A palavra era "$palavraSecreta".',
        tipo: 'ok',
      );
    } else {
      vidas = (vidas - 2).clamp(0, vidasIniciais);
      return ResultadoTentativa(
        valida: true,
        mensagem: '✗ Chute errado! ("$chute") Custou 2 vidas!',
        tipo: 'erro',
      );
    }
  }

  /// Verifica o estado atual do jogo.
  ResultadoJogo get resultado {
    if (reveladas.every((r) => r)) return ResultadoJogo.vitoria;
    if (vidas <= 0) return ResultadoJogo.derrota;
    return ResultadoJogo.emAndamento;
  }
}
