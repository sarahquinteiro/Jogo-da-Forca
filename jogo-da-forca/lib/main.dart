import 'dart:math';
import 'package:web/web.dart';

// ─────────────────────────────────────────
// LISTA DE PALAVRAS
// ─────────────────────────────────────────
final List<String> palavras = [
  'ABACAXI',
  'ELEFANTE',
  'BORBOLETA',
  'COMPUTADOR',
  'JAVASCRIPT',
  'PROGRAMACAO',
  'TARTARUGA',
  'CHOCOLATE',
  'BIBLIOTECA',
  'FOTOGRAFIA',
  'HORIZONTE',
  'GIRASSOL',
  'DICIONARIO',
  'MICROSCOPIO',
  'ASTRONAUTA',
];

// ─────────────────────────────────────────
// ESTADO DO JOGO
// ─────────────────────────────────────────
late String palavraSecreta;
late List<bool> reveladas;
late List<String> erros;
late int vidas;
late bool jogoEncerrado;

final Random random = Random();

// ─────────────────────────────────────────
// ARTE ASCII DA FORCA (7 estágios)
// Definida como strings com \n para evitar
// problemas com raw strings no DartPad
// ─────────────────────────────────────────
const List<String> forcaAscii = [
  '  +---+\n  |   |\n      |\n      |\n      |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n      |\n      |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n  |   |\n      |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n /|   |\n      |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n /|\\  |\n      |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n /|\\  |\n /    |\n      |\n=========',
  '  +---+\n  |   |\n  O   |\n /|\\  |\n / \\  |\n      |\n=========',
];

// ─────────────────────────────────────────
// HELPERS — acesso ao DOM
// ─────────────────────────────────────────
Element _el(String id) => document.getElementById(id)!;

HTMLInputElement _inp(String id) => _el(id) as HTMLInputElement;

HTMLElement _hel(String id) => _el(id) as HTMLElement;

void _setText(String id, String text) {
  _el(id).textContent = text;
}

void _setStyle(String id, String css) {
  _hel(id).style.cssText = css;
}

void _setAttr(String id, String attr, String value) {
  _el(id).setAttribute(attr, value);
}

void _removeAttr(String id, String attr) {
  _el(id).removeAttribute(attr);
}

// ─────────────────────────────────────────
// INICIALIZA / REINICIA O JOGO
// ─────────────────────────────────────────
void iniciarJogo() {
  palavraSecreta = palavras[random.nextInt(palavras.length)];
  reveladas = List.filled(palavraSecreta.length, false);
  erros = [];
  vidas = 6;
  jogoEncerrado = false;

  _hel('banner').style.display = 'none';
  _removeAttr('input-letra', 'disabled');
  _removeAttr('btn-tentar', 'disabled');
  _removeAttr('input-chute', 'disabled');
  _removeAttr('btn-chutar', 'disabled');
  _inp('input-letra').value = '';
  _inp('input-chute').value = '';
  setMensagem('', '');
  renderizar();
  _el('input-letra').focus();
}

// ─────────────────────────────────────────
// TENTATIVA DE LETRA
// ─────────────────────────────────────────
void tentarLetra() {
  if (jogoEncerrado) return;

  final inp = _inp('input-letra');
  final letra = inp.value.trim().toUpperCase();
  inp.value = '';
  inp.focus();

  if (letra.isEmpty || !RegExp(r'^[A-Z]$').hasMatch(letra)) {
    setMensagem('⚠ Digite apenas UMA letra (A-Z).', 'erro');
    return;
  }

  if (erros.contains(letra)) {
    setMensagem('⚠ Você já tentou "$letra" e errou! Tente outra.', 'aviso');
    return;
  }

  final jaRevelada = List.generate(palavraSecreta.length, (i) => i)
      .any((i) => palavraSecreta[i] == letra && reveladas[i]);

  if (jaRevelada) {
    setMensagem('⚠ A letra "$letra" já foi revelada! Tente outra.', 'aviso');
    return;
  }

  if (palavraSecreta.contains(letra)) {
    int count = 0;
    for (int i = 0; i < palavraSecreta.length; i++) {
      if (palavraSecreta[i] == letra) {
        reveladas[i] = true;
        count++;
      }
    }
    setMensagem('✓ Boa! A letra "$letra" aparece ${count}x na palavra.', 'ok');
  } else {
    erros.add(letra);
    vidas--;
    setMensagem('✗ A letra "$letra" não está na palavra. -1 vida!', 'erro');
  }

  renderizar();
  verificarFim();
}

// ─────────────────────────────────────────
// CHUTE DA PALAVRA INTEIRA
// ─────────────────────────────────────────
void chutar() {
  if (jogoEncerrado) return;

  final inp = _inp('input-chute');
  final chute = inp.value.trim().toUpperCase();
  inp.value = '';

  if (chute.isEmpty) {
    setMensagem('⚠ Digite a palavra para chutar.', 'erro');
    return;
  }

  if (chute == palavraSecreta) {
    for (int i = 0; i < reveladas.length; i++) {
      reveladas[i] = true;
    }
    renderizar();
    encerrarJogo(true);
  } else {
    vidas = (vidas - 2).clamp(0, 6);
    setMensagem('✗ Chute errado! ("$chute") Custou 2 vidas!', 'erro');
    renderizar();
    verificarFim();
  }
}

// ─────────────────────────────────────────
// VERIFICA VITÓRIA / DERROTA
// ─────────────────────────────────────────
void verificarFim() {
  if (reveladas.every((r) => r)) {
    encerrarJogo(true);
  } else if (vidas <= 0) {
    encerrarJogo(false);
  }
}

void encerrarJogo(bool vitoria) {
  jogoEncerrado = true;

  if (!vitoria) {
    for (int i = 0; i < reveladas.length; i++) {
      reveladas[i] = true;
    }
    renderizar();
  }

  _setAttr('input-letra', 'disabled', 'true');
  _setAttr('btn-tentar', 'disabled', 'true');
  _setAttr('input-chute', 'disabled', 'true');
  _setAttr('btn-chutar', 'disabled', 'true');

  if (vitoria) {
    _setText('banner-titulo', '🎉 Parabéns, você venceu!');
    _setAttr('banner-titulo', 'style',
        'color:#2e7d32;font-size:22px;font-weight:600;margin-bottom:6px;');
  } else {
    _setText('banner-titulo', '💀 Você perdeu!');
    _setAttr('banner-titulo', 'style',
        'color:#c62828;font-size:22px;font-weight:600;margin-bottom:6px;');
  }

  _setText('banner-sub', 'A palavra era: $palavraSecreta');
  _hel('banner').style.display = 'block';
}

// ─────────────────────────────────────────
// RENDERIZAÇÃO
// ─────────────────────────────────────────
void renderizar() {
  final errosCount = erros.length.clamp(0, 6);
  _setText('forca', forcaAscii[errosCount]);

  final palavra = List.generate(palavraSecreta.length, (i) {
    return reveladas[i] ? ' ${palavraSecreta[i]} ' : ' _ ';
  }).join('');
  _setText('palavra', palavra);

  _setText('erros', erros.isEmpty ? '-' : '[${erros.join(', ')}]');

  final corVidas = vidas <= 2
      ? '#c62828'
      : vidas <= 4
          ? '#e65100'
          : '#2e7d32';
  _setText('vidas', '$vidas');
  _setAttr('vidas', 'style', 'font-weight:700;color:$corVidas;');

  renderTeclado();
}

void renderTeclado() {
  final kb = _el('teclado');
  final items = kb.children;

  for (int i = 0; i < items.length; i++) {
    final btn = items.item(i)!;
    final letra = (btn.textContent ?? '').trim();

    if (erros.contains(letra)) {
      btn.setAttribute(
        'style',
        'width:32px;height:32px;font-size:13px;font-weight:600;'
        'border:1px solid #ef9a9a;border-radius:6px;'
        'background:#ffcdd2;color:#c62828;'
        'cursor:default;font-family:monospace;opacity:0.7;',
      );
    } else {
      final acertou = List.generate(palavraSecreta.length, (j) => j)
          .any((j) => palavraSecreta[j] == letra && reveladas[j]);

      if (acertou) {
        btn.setAttribute(
          'style',
          'width:32px;height:32px;font-size:13px;font-weight:600;'
          'border:1px solid #a5d6a7;border-radius:6px;'
          'background:#c8e6c9;color:#2e7d32;'
          'cursor:default;font-family:monospace;opacity:0.85;',
        );
      } else {
        btn.setAttribute(
          'style',
          'width:32px;height:32px;font-size:13px;font-weight:600;'
          'border:1px solid #bdbdbd;border-radius:6px;'
          'background:#fafafa;color:#212121;'
          'cursor:pointer;font-family:monospace;',
        );
      }
    }
  }
}

void setMensagem(String texto, String tipo) {
  final cor = tipo == 'ok'
      ? '#2e7d32'
      : tipo == 'erro'
          ? '#c62828'
          : '#e65100';
  _setText('mensagem', texto);
  _setAttr(
    'mensagem',
    'style',
    'min-height:22px;font-size:14px;color:$cor;margin-bottom:8px;',
  );
}

// ─────────────────────────────────────────
// CONSTRUÇÃO DO HTML
// ─────────────────────────────────────────
void construirUI() {
  final body = document.body!;
  (body as HTMLElement).style.cssText =
      'font-family:monospace;background:#f5f5f5;display:flex;'
      'justify-content:center;padding:20px 10px;min-height:100vh;'
      'margin:0;box-sizing:border-box;';

  final container = document.createElement('div') as HTMLDivElement;
  (container as HTMLElement).style.cssText =
      'background:#fff;border-radius:12px;padding:24px 28px;'
      'max-width:560px;width:100%;'
      'box-shadow:0 2px 12px rgba(0,0,0,0.10);';

  container.innerHTML = '''
<h1 style="font-size:24px;font-weight:700;margin:0 0 4px;color:#212121;">
  &#x26B0; Jogo da Forca
</h1>
<p style="font-size:13px;color:#757575;margin:0 0 20px;">
  Adivinhe a palavra letra por letra. Voc&#234; tem 6 vidas.
</p>
<pre id="forca" style="font-size:15px;line-height:1.5;background:#f9f9f9;
  border:1px solid #e0e0e0;border-radius:8px;padding:12px 16px;
  margin-bottom:16px;color:#212121;"></pre>
<div id="palavra" style="font-size:26px;letter-spacing:4px;text-align:center;
  font-weight:700;margin-bottom:12px;color:#1a237e;min-height:38px;"></div>
<div style="display:flex;gap:24px;justify-content:center;font-size:14px;
  margin-bottom:12px;color:#555;">
  <span>Erros: <span id="erros" style="color:#c62828;font-weight:600;">-</span></span>
  <span>Vidas: <span id="vidas" style="font-weight:700;color:#2e7d32;">6</span></span>
</div>
<div id="mensagem" style="min-height:22px;font-size:14px;color:#555;margin-bottom:8px;"></div>
<div style="display:flex;gap:8px;margin-bottom:10px;">
  <input id="input-letra" type="text" maxlength="1" placeholder="A"
    style="width:52px;height:40px;font-size:20px;text-align:center;
      border:1px solid #bdbdbd;border-radius:8px;text-transform:uppercase;
      outline:none;font-family:monospace;font-weight:700;" />
  <button id="btn-tentar" style="height:40px;padding:0 18px;border-radius:8px;
    border:1px solid #1a237e;background:#e8eaf6;color:#1a237e;
    font-size:14px;cursor:pointer;font-family:monospace;font-weight:600;">
    Tentar letra
  </button>
</div>
<div style="display:flex;gap:8px;margin-bottom:8px;">
  <input id="input-chute" type="text" maxlength="20"
    placeholder="Chutar palavra inteira..."
    style="flex:1;height:38px;padding:0 10px;font-size:14px;
      border:1px solid #bdbdbd;border-radius:8px;text-transform:uppercase;
      outline:none;font-family:monospace;" />
  <button id="btn-chutar" style="height:38px;padding:0 14px;border-radius:8px;
    border:1px solid #e65100;background:#fff3e0;color:#e65100;
    font-size:14px;cursor:pointer;font-family:monospace;font-weight:600;">
    Chutar &#9889;
  </button>
</div>
<div style="font-size:11px;color:#9e9e9e;margin-bottom:10px;">
  &#9888; Chutar a palavra inteira custa 2 vidas se errar!
</div>
<div id="teclado" style="display:flex;flex-wrap:wrap;gap:5px;margin-bottom:16px;"></div>
<div id="banner" style="display:none;text-align:center;padding:16px;
  background:#f5f5f5;border-radius:10px;border:1px solid #e0e0e0;margin-bottom:12px;">
  <div id="banner-titulo"></div>
  <div id="banner-sub" style="font-size:14px;color:#555;margin-bottom:12px;"></div>
  <button id="btn-novo" style="padding:10px 24px;border-radius:8px;
    border:1px solid #388e3c;background:#e8f5e9;color:#2e7d32;
    font-size:15px;cursor:pointer;font-family:monospace;font-weight:600;">
    &#9658; Jogar novamente
  </button>
</div>
''';

  body.appendChild(container);

  // Teclado virtual — 26 botões A–Z
  final teclado = _el('teclado');
  for (int i = 0; i < 26; i++) {
    final letra = String.fromCharCode(65 + i);
    final btn = document.createElement('button') as HTMLButtonElement;
    btn.textContent = letra;
    (btn as HTMLElement).style.cssText =
        'width:32px;height:32px;font-size:13px;font-weight:600;'
        'border:1px solid #bdbdbd;border-radius:6px;'
        'background:#fafafa;color:#212121;'
        'cursor:pointer;font-family:monospace;';
    btn.addEventListener(
      'click',
      (Event _) {
        if (!jogoEncerrado) {
          _inp('input-letra').value = letra;
          tentarLetra();
        }
      }.toJS,
    );
    teclado.appendChild(btn);
  }

  // Botões de ação
  _el('btn-tentar').addEventListener('click', (Event _) => tentarLetra().toJS);
  _el('btn-chutar').addEventListener('click', (Event _) => chutar().toJS);
  _el('btn-novo').addEventListener('click', (Event _) => iniciarJogo().toJS);

  // Tecla Enter nos inputs
  _el('input-letra').addEventListener(
    'keydown',
    (Event e) {
      if ((e as KeyboardEvent).key == 'Enter') tentarLetra();
    }.toJS,
  );
  _el('input-chute').addEventListener(
    'keydown',
    (Event e) {
      if ((e as KeyboardEvent).key == 'Enter') chutar();
    }.toJS,
  );
}

// ─────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────
void main() {
  construirUI();
  iniciarJogo();
}
