/// Aritmètica modular bàsica: congruències, inversos i xifrats afins.
/// Només fa servir el que s'ha vist a classe (sense TXR, Fermat ni φ).
library;

/// Alfabet català de 27 lletres, amb la Ç entre la N i la O.
const String alphabet27 = 'ABCDEFGHIJKLMNÇOPQRSTUVWXYZ';

/// Representant de a a {0, …, n−1}.
int mod(int a, int n) {
  assert(n > 0);
  final r = a % n;
  return r < 0 ? r + n : r;
}

/// Invers de a mòdul n (a {0, …, n−1}) o `null` si no en té.
/// Es busca per força bruta: és el mètode de la llista d'exercicis.
int? inverse(int a, int n) {
  for (var x = 0; x < n; x++) {
    if (mod(a * x, n) == 1 % n) return x;
  }
  return null;
}

/// Totes les solucions x ∈ {0, …, n−1} de a·x ≡ b (mod n).
List<int> solveLinear(int a, int b, int n) => [
      for (var x = 0; x < n; x++)
        if (mod(a * x - b, n) == 0) x,
    ];

/// Escriu x ∈ ℤₙ amb la notació del professor: {1, …, n}, amb n ≡ 0.
int toProfNotation(int x, int n) {
  final r = mod(x, n);
  return r == 0 ? n : r;
}

/// Xifra amb e(x) = a·x + b (mod 27). Els caràcters fora de l'alfabet
/// es deixen igual.
String affineEncrypt(String text, int a, int b) =>
    _mapLetters(text, (x) => mod(a * x + b, alphabet27.length));

/// Desxifra e(x) = a·x + b (mod 27): x = a⁻¹·(y − b).
/// Llança [ArgumentError] si a no té invers mòdul 27.
String affineDecrypt(String text, int a, int b) {
  final inv = inverse(a, alphabet27.length);
  if (inv == null) {
    throw ArgumentError('$a no té invers mòdul ${alphabet27.length}');
  }
  return _mapLetters(text, (y) => mod(inv * (y - b), alphabet27.length));
}

String _mapLetters(String text, int Function(int) f) {
  final buffer = StringBuffer();
  for (final ch in text.toUpperCase().split('')) {
    final i = alphabet27.indexOf(ch);
    buffer.write(i < 0 ? ch : alphabet27[f(i)]);
  }
  return buffer.toString();
}
