import 'dart:html';

import 'ascii_art.dart';
import 'game_state.dart';
import 'ui_builder.dart';

// ─────────────────────────────────────────
// PONTO DE ENTRADA
// ─────────────────────────────────────────

final GameState estado = GameState();

void main() {
  construirUI();
  construirTeclado(_aoClicarTeclado);
  _registrarEventos();
  _iniciarJogo();
}

// ─────────────────────────────────────────
// CICLO DE JOGO
// ─────────────────────────────────────────

void _iniciarJogo() {
  estado.reiniciar();
  querySelector('#banner')!.style.display = 'none';
  (querySelector('#input-letra') as InputElement).value = '';
  (querySelector('#input-chute') as InputElement).value = '';
  setControlesAtivos(true);
  exibirMensagem('', '');
  _renderizar();
  querySelector('#input-letra')!.focus();
}

void _aoTentarLetra() {
  final inp = querySelector('#input-letra') as InputElement;
  final resultado = estado.tentarLetra(inp.value ?? '');
  inp.value = '';
  inp.focus();
  exibirMensagem(resultado.mensagem, resultado.tipo);
  if (resultado.valida) {
    _renderizar();
    _verificarFim();
  }
}

void _aoChutar() {
  final inp = querySelector('#input-chute') as InputElement;
  final resultado = estado.chutar(inp.value ?? '');
  inp.value = '';
  exibirMensagem(resultado.mensagem, resultado.tipo);
  if (resultado.valida) {
    _renderizar();
    _verificarFim();
  }
}

void _aoClicarTeclado(String letra) {
  if (estado.encerrado) return;
  final resultado = estado.tentarLetra(letra);
  exibirMensagem(resultado.mensagem, resultado.tipo);
  if (resultado.valida) {
    _renderizar();
    _verificarFim();
  }
}

void _verificarFim() {
  final r = estado.resultado;
  if (r == ResultadoJogo.vitoria) {
    _encerrarJogo(vitoria: true);
  } else if (r == ResultadoJogo.derrota) {
    _encerrarJogo(vitoria: false);
  }
}

void _encerrarJogo({required bool vitoria}) {
  estado.encerrado = true;

  // Revela a palavra inteira na derrota
  if (!vitoria) {
    for (int i = 0; i < estado.reveladas.length; i++) {
      estado.reveladas[i] = true;
    }
    _renderizar();
  }

  setControlesAtivos(false);

  final banner = querySelector('#banner')!;
  final titulo = querySelector('#banner-titulo')!;
  final sub = querySelector('#banner-sub')!;

  if (vitoria) {
    titulo
      ..text = '🎉 Parabéns, você venceu!'
      ..setAttribute(
        'style',
        'color:#2e7d32; font-size:22px; font-weight:600; margin-bottom:6px;',
      );
  } else {
    titulo
      ..text = '💀 Você perdeu!'
      ..setAttribute(
        'style',
        'color:#c62828; font-size:22px; font-weight:600; margin-bottom:6px;',
      );
  }

  sub.text = 'A palavra era: ${estado.palavraSecreta}';
  banner.style.display = 'block';
}

// ─────────────────────────────────────────
// RENDERIZAÇÃO
// ─────────────────────────────────────────

void _renderizar() {
  // Arte ASCII da forca
  final errosCount = estado.erros.length.clamp(0, 6);
  querySelector('#forca')!.text = forcaAscii[errosCount];

  // Palavra com underscores
  final palavra = estado.palavraVisivel
      .map((c) => c != null ? ' $c ' : ' _ ')
      .join('');
  querySelector('#palavra')!.text = palavra;

  // Lista de erros
  querySelector('#erros')!.text =
      estado.erros.isEmpty ? '-' : '[${estado.erros.join(', ')}]';

  // Vidas com cor dinâmica
  final corVidas = estado.vidas <= 2
      ? '#c62828'
      : estado.vidas <= 4
          ? '#e65100'
          : '#2e7d32';
  querySelector('#vidas')!
    ..text = '${estado.vidas}'
    ..setAttribute('style', 'font-weight:700; color:$corVidas;');

  // Teclado virtual
  atualizarTeclado(estado.erros, estado.palavraSecreta, estado.reveladas);
}

// ─────────────────────────────────────────
// EVENTOS DE TECLADO / BOTÕES
// ─────────────────────────────────────────

void _registrarEventos() {
  querySelector('#btn-tentar')!.onClick.listen((_) => _aoTentarLetra());
  querySelector('#btn-chutar')!.onClick.listen((_) => _aoChutar());
  querySelector('#btn-novo')!.onClick.listen((_) => _iniciarJogo());

  (querySelector('#input-letra') as InputElement).onKeyDown.listen((e) {
    if (e.keyCode == 13) _aoTentarLetra();
  });
  (querySelector('#input-chute') as InputElement).onKeyDown.listen((e) {
    if (e.keyCode == 13) _aoChutar();
  });
}
