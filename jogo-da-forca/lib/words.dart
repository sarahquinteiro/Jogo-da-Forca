import 'dart:math';

/// Lista de palavras disponíveis para o jogo.
const List<String> listaDePalavras = [
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

/// Retorna uma palavra aleatória da lista usando [Random].
String sortearPalavra() {
  final random = Random();
  return listaDePalavras[random.nextInt(listaDePalavras.length)];
}
