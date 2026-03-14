import 'dart:html';

/// Monta toda a estrutura HTML do jogo no [document.body].
void construirUI() {
  document.body!.style.cssText = '''
    font-family: monospace;
    background: #f5f5f5;
    display: flex;
    justify-content: center;
    padding: 20px 10px;
    min-height: 100vh;
    margin: 0;
    box-sizing: border-box;
  ''';

  final container = DivElement()
    ..style.cssText = '''
      background: #fff;
      border-radius: 12px;
      padding: 24px 28px;
      max-width: 560px;
      width: 100%;
      box-shadow: 0 2px 12px rgba(0,0,0,0.10);
    ''';

  container.innerHtml = '''
    <h1 style="font-size:24px; font-weight:700; margin:0 0 4px; color:#212121;">
      ⚰ Jogo da Forca
    </h1>
    <p style="font-size:13px; color:#757575; margin:0 0 20px;">
      Adivinhe a palavra letra por letra. Você tem 6 vidas.
    </p>

    <pre id="forca" style="
      font-size:15px;
      line-height:1.5;
      background:#f9f9f9;
      border:1px solid #e0e0e0;
      border-radius:8px;
      padding:12px 16px;
      margin-bottom:16px;
      color:#212121;
    "></pre>

    <div id="palavra" style="
      font-size:26px;
      letter-spacing:4px;
      text-align:center;
      font-weight:700;
      margin-bottom:12px;
      color:#1a237e;
      min-height:38px;
    "></div>

    <div style="display:flex; gap:24px; justify-content:center; font-size:14px; margin-bottom:12px; color:#555;">
      <span>Erros: <span id="erros" style="color:#c62828; font-weight:600;">-</span></span>
      <span>Vidas: <span id="vidas" style="font-weight:700; color:#2e7d32;">6</span></span>
    </div>

    <div id="mensagem" style="min-height:22px; font-size:14px; color:#555; margin-bottom:8px;"></div>

    <div style="display:flex; gap:8px; margin-bottom:10px;">
      <input id="input-letra"
        type="text" maxlength="1" placeholder="A"
        style="
          width:52px; height:40px; font-size:20px; text-align:center;
          border:1px solid #bdbdbd; border-radius:8px;
          text-transform:uppercase; outline:none;
          font-family:monospace; font-weight:700;
        "
      />
      <button id="btn-tentar" style="
        height:40px; padding:0 18px; border-radius:8px;
        border:1px solid #1a237e; background:#e8eaf6;
        color:#1a237e; font-size:14px; cursor:pointer;
        font-family:monospace; font-weight:600;
      ">Tentar letra</button>
    </div>

    <div style="display:flex; gap:8px; margin-bottom:8px;">
      <input id="input-chute"
        type="text" maxlength="20" placeholder="Chutar palavra inteira..."
        style="
          flex:1; height:38px; padding:0 10px; font-size:14px;
          border:1px solid #bdbdbd; border-radius:8px;
          text-transform:uppercase; outline:none; font-family:monospace;
        "
      />
      <button id="btn-chutar" style="
        height:38px; padding:0 14px; border-radius:8px;
        border:1px solid #e65100; background:#fff3e0;
        color:#e65100; font-size:14px; cursor:pointer;
        font-family:monospace; font-weight:600;
      ">Chutar ⚡</button>
    </div>

    <div style="font-size:11px; color:#9e9e9e; margin-bottom:10px;">
      ⚠ Chutar a palavra inteira custa 2 vidas se errar!
    </div>

    <div id="teclado" style="
      display:flex; flex-wrap:wrap; gap:5px;
      margin-bottom:16px;
    "></div>

    <div id="banner" style="
      display:none;
      text-align:center;
      padding:16px;
      background:#f5f5f5;
      border-radius:10px;
      border:1px solid #e0e0e0;
      margin-bottom:12px;
    ">
      <div id="banner-titulo"></div>
      <div id="banner-sub" style="font-size:14px; color:#555; margin-bottom:12px;"></div>
      <button id="btn-novo" style="
        padding:10px 24px; border-radius:8px;
        border:1px solid #388e3c; background:#e8f5e9;
        color:#2e7d32; font-size:15px; cursor:pointer;
        font-family:monospace; font-weight:600;
      ">▶ Jogar novamente</button>
    </div>
  ''';

  document.body!.append(container);
}

/// Constrói os 26 botões do teclado virtual e registra o callback [onLetra].
void construirTeclado(void Function(String) onLetra) {
  final teclado = querySelector('#teclado')!;
  for (int i = 0; i < 26; i++) {
    final letra = String.fromCharCode(65 + i);
    final btn = ButtonElement()
      ..id = 'key-$letra'
      ..text = letra
      ..style.cssText = '''
        width:32px; height:32px; font-size:13px; font-weight:600;
        border:1px solid #bdbdbd; border-radius:6px;
        background:#fafafa; color:#212121;
        cursor:pointer; font-family:monospace;
      ''';
    btn.onClick.listen((_) => onLetra(letra));
    teclado.append(btn);
  }
}

/// Atualiza o visual de cada tecla: verde (acerto), vermelho (erro), normal.
void atualizarTeclado(List<String> erros, String palavraSecreta, List<bool> reveladas) {
  for (int i = 0; i < 26; i++) {
    final letra = String.fromCharCode(65 + i);
    final btn = querySelector('#key-$letra');
    if (btn == null) continue;

    if (erros.contains(letra)) {
      btn.setAttribute('style', '''
        width:32px; height:32px; font-size:13px; font-weight:600;
        border:1px solid #ef9a9a; border-radius:6px;
        background:#ffcdd2; color:#c62828;
        cursor:default; font-family:monospace; opacity:0.7;
      ''');
    } else {
      final acertou = List.generate(palavraSecreta.length, (i) => i)
          .any((i) => palavraSecreta[i] == letra && reveladas[i]);
      if (acertou) {
        btn.setAttribute('style', '''
          width:32px; height:32px; font-size:13px; font-weight:600;
          border:1px solid #a5d6a7; border-radius:6px;
          background:#c8e6c9; color:#2e7d32;
          cursor:default; font-family:monospace; opacity:0.85;
        ''');
      } else {
        btn.setAttribute('style', '''
          width:32px; height:32px; font-size:13px; font-weight:600;
          border:1px solid #bdbdbd; border-radius:6px;
          background:#fafafa; color:#212121;
          cursor:pointer; font-family:monospace;
        ''');
      }
    }
  }
}

/// Exibe uma mensagem de feedback para o jogador.
void exibirMensagem(String texto, String tipo) {
  final el = querySelector('#mensagem')!;
  el.text = texto;
  final cor = tipo == 'ok'
      ? '#2e7d32'
      : tipo == 'erro'
          ? '#c62828'
          : '#888';
  el.setAttribute(
    'style',
    'min-height:22px; font-size:14px; color:$cor; margin-bottom:8px;',
  );
}

/// Habilita ou desabilita todos os controles de entrada.
void setControlesAtivos(bool ativo) {
  final ids = ['input-letra', 'btn-tentar', 'input-chute', 'btn-chutar'];
  for (final id in ids) {
    final el = querySelector('#$id')!;
    if (ativo) {
      el.attributes.remove('disabled');
    } else {
      el.attributes['disabled'] = 'true';
    }
  }
}
