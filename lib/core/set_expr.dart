/// Parser i avaluador petit d'expressions de conjunts.
///
/// Gramàtica (∩ té més prioritat que ∪, com el producte davant la suma):
///   unió   := inter ('∪' inter)*
///   inter  := postfix ('∩' postfix)*
///   postfix:= primari ('′')*
///   primari:= VAR | '(' unió ')'
/// VAR és una lletra majúscula definida a l'entorn (A, B…).
/// L'apòstrof ' s'accepta com a sinònim de ′.
library;

class SetExprError implements Exception {
  const SetExprError(this.message);
  final String message;
  @override
  String toString() => 'SetExprError: $message';
}

/// Univers de prova: té dos elements a cada regió del Venn de A i B
/// (només A: 1,2 · A∩B: 3,4 · només B: 5,6 · fora: 7,8). Per això, dues
/// expressions en A i B que coincideixen aquí són equivalents sempre.
const Set<int> testUniverse = {1, 2, 3, 4, 5, 6, 7, 8};
const Map<String, Set<int>> testSets = {
  'A': {1, 2, 3, 4},
  'B': {3, 4, 5, 6},
};

/// Avalua [source] dins de [universe] amb els conjunts de [sets].
/// Llança [SetExprError] si l'expressió no és vàlida.
Set<int> evalSetExpr(
  String source, {
  Set<int> universe = testUniverse,
  Map<String, Set<int>> sets = testSets,
}) {
  final parser = _Parser(_tokenize(source), universe, sets);
  final result = parser.union();
  if (!parser.atEnd) {
    throw SetExprError('Símbol inesperat: ${parser.peek}');
  }
  return result;
}

/// Cert si [a] i [b] són expressions vàlides i equivalents a l'univers de prova.
bool setExprEquivalent(String a, String b) {
  try {
    final x = evalSetExpr(a), y = evalSetExpr(b);
    return x.length == y.length && x.containsAll(y);
  } on SetExprError {
    return false;
  }
}

List<String> _tokenize(String s) {
  final tokens = <String>[];
  for (final ch in s.split('')) {
    if (ch.trim().isEmpty) continue;
    if (ch == "'") {
      tokens.add('′');
    } else if ('∪∩()′'.contains(ch) || RegExp(r'^[A-Z]$').hasMatch(ch)) {
      tokens.add(ch);
    } else {
      throw SetExprError('Caràcter no vàlid: $ch');
    }
  }
  if (tokens.isEmpty) throw const SetExprError('Expressió buida');
  return tokens;
}

class _Parser {
  _Parser(this.tokens, this.universe, this.sets);

  final List<String> tokens;
  final Set<int> universe;
  final Map<String, Set<int>> sets;
  int pos = 0;

  bool get atEnd => pos >= tokens.length;
  String? get peek => atEnd ? null : tokens[pos];

  Set<int> union() {
    var left = inter();
    while (peek == '∪') {
      pos++;
      left = left.union(inter());
    }
    return left;
  }

  Set<int> inter() {
    var left = postfix();
    while (peek == '∩') {
      pos++;
      left = left.intersection(postfix());
    }
    return left;
  }

  Set<int> postfix() {
    var value = primary();
    while (peek == '′') {
      pos++;
      value = universe.difference(value);
    }
    return value;
  }

  Set<int> primary() {
    final t = peek;
    if (t == null) throw const SetExprError('Expressió incompleta');
    pos++;
    if (t == '(') {
      final value = union();
      if (peek != ')') throw const SetExprError('Falta tancar un parèntesi');
      pos++;
      return value;
    }
    final set = sets[t];
    if (set == null) throw SetExprError('Símbol inesperat: $t');
    return set;
  }
}
