/// Generador pseudoaleatori determinista per a les variants d'una partida.
///
/// No fa servir `dart:math` `Random` perquè el seu algorisme no està
/// garantit entre versions de Dart: una partida desada ha de tornar a sortir
/// exactament igual. Aquí l'algorisme és fix (FNV-1a + splitmix32).
///
/// Cada puzle té el seu propi generador, `Rng(seed, '1.1')`, de manera que
/// afegir o treure un puzle no canvia les variants dels altres.
class Rng {
  Rng(int seed, String key) : _state = _mix(seed ^ _fnv1a(key)), _first = false;

  /// Generador «sense atzar»: [pick] tria sempre el primer element i
  /// [shuffled] no barreja. Serveix per a la variant del PDF del professor.
  Rng.first() : _state = 0, _first = true;

  static const _mask = 0xFFFFFFFF;
  int _state;
  final bool _first;

  /// Enter uniforme a [0, max).
  int nextInt(int max) {
    assert(max > 0);
    if (_first) return 0;
    _state = (_state + 0x9E3779B9) & _mask;
    return _mix(_state) % max;
  }

  /// Un element de [items].
  T pick<T>(List<T> items) => items[nextInt(items.length)];

  /// Una còpia de [items] barrejada (Fisher–Yates).
  List<T> shuffled<T>(List<T> items) {
    final out = [...items];
    if (_first) return out;
    for (var i = out.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = out[i];
      out[i] = out[j];
      out[j] = t;
    }
    return out;
  }

  static int _fnv1a(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h = ((h ^ c) * 0x01000193) & _mask;
    }
    return h;
  }

  /// Funció de barreja de splitmix32 (32 bits).
  static int _mix(int x) {
    var z = x & _mask;
    z = ((z ^ (z >> 16)) * 0x85EBCA6B) & _mask;
    z = ((z ^ (z >> 13)) * 0xC2B2AE35) & _mask;
    return (z ^ (z >> 16)) & _mask;
  }
}
