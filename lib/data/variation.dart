import '../core/rng.dart';

/// La variació d'una partida: dona a cada puzle el seu generador.
class Variation {
  const Variation(this.seed);

  final int seed;

  /// Generador propi de [key] (un id de puzle, 'porta'…).
  Rng rng(String key) => Rng(seed, key);
}
