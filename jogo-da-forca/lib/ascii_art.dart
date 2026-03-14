/// Arte ASCII da forca em 7 estágios (0 erros → 6 erros).
///
/// Cada índice corresponde ao número de erros cometidos pelo jogador.
const List<String> forcaAscii = [
  // 0 erros — forca vazia
  '''
  +---+
  |   |
      |
      |
      |
      |
=========''',

  // 1 erro — cabeça
  '''
  +---+
  |   |
  O   |
      |
      |
      |
=========''',

  // 2 erros — tronco
  '''
  +---+
  |   |
  O   |
  |   |
      |
      |
=========''',

  // 3 erros — braço esquerdo
  '''
  +---+
  |   |
  O   |
 /|   |
      |
      |
=========''',

  // 4 erros — braço direito
  '''
  +---+
  |   |
  O   |
 /|\\  |
      |
      |
=========''',

  // 5 erros — perna esquerda
  '''
  +---+
  |   |
  O   |
 /|\\  |
 /    |
      |
=========''',

  // 6 erros — boneco completo (derrota)
  '''
  +---+
  |   |
  O   |
 /|\\  |
 / \\  |
      |
=========''',
];
