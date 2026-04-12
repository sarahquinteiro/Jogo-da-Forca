# ⚰️ Jogo da Forca — Dart Web

Jogo da Forca implementado em **Dart** para rodar no navegador via [DartPad](https://dartpad.dev).

---

## 🎮 Como jogar

1. Acesse **[dartpad.dev](https://dartpad.dev)**
2. Copie o conteúdo de [`lib/main.dart`](lib/main.dart)
3. Cole no editor do DartPad e clique em **Run**

Ou clone o repositório e abra localmente com o [Dart SDK](https://dart.dev/get-dart).

---

## 📋 Regras

- Uma palavra secreta é sorteada aleatoriamente a cada partida
- Tente adivinhar **letra por letra**
- Você tem **6 vidas** — cada erro derruba uma parte do boneco
- O jogo termina quando você revelar todas as letras (**vitória**) ou esgotar as vidas (**derrota**)

### ⚡ Chute da palavra inteira
Você pode tentar adivinhar a palavra completa de uma vez — mas se errar, **perde 2 vidas**!

---

## ✅ Funcionalidades

| Funcionalidade | Implementado |
|---|---|
| Lista de palavras (`List<String>`) | ✅ 15 palavras |
| Sorteio com `Random` | ✅ |
| Palavra oculta com underscores | ✅ |
| Letras erradas exibidas | ✅ |
| Contador de vidas | ✅ |
| Validação de entrada (1 letra, A-Z) | ✅ |
| Case insensitive | ✅ |
| Sem desconto ao repetir letra | ✅ |
| Arte ASCII da forca (7 estágios) | ✅ |
| Teclado virtual clicável | ✅ |
| Chute da palavra completa | ✅ |
| Jogar novamente | ✅ |

---

## 🗂️ Estrutura do projeto

```
jogo-da-forca/
├── lib/
│   ├── main.dart          # Ponto de entrada — monta a UI e inicia o jogo
│   ├── game_state.dart    # Estado do jogo e lógica principal
│   ├── words.dart         # Lista de palavras e sorteio
│   ├── ui_builder.dart    # Construção do HTML via dart:html
│   └── ascii_art.dart     # Arte ASCII da forca (7 estágios)
├── test/
│   └── game_state_test.dart  # Testes unitários
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

## 🧪 Testes

```bash
dart test
```

---

## 🛠️ Tecnologias

- **Dart** (dart:html, dart:math)
- Sem dependências externas
- Compatível com DartPad e Dart SDK 3.x

---

## 📄 Licença

MIT License © 2026
