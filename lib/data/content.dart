import '../models/puzzle.dart';
import 'porta.dart';
import 'sala1.dart';
import 'sala2.dart';
import 'sala3.dart';
import 'texts.dart';
import 'variation.dart';

export 'texts.dart';
export 'porta.dart' show Pany;
export 'variation.dart' show pdfSeed;

/// Tot el contingut d'una partida, generat a partir de la seva llavor.
///
/// Cada puzle és una funció `Puzzle nom(Rng r)` al fitxer de la seva sala
/// (`sala1.dart`…): l'enunciat, els passos, les pistes i la solució surten
/// dels mateixos paràmetres. Les solucions es verifiquen a
/// `test/content_test.dart`.
class GameContent {
  GameContent._({
    required this.seed,
    required this.pany,
    required this.rooms,
    required this.finalPuzzle,
    required this.secretBookText,
  }) : intro = buildIntroText(pany.pattern),
       homeBlurb = buildHomeBlurb(pany.pattern),
       puzzlesById = {
         for (final r in rooms)
           for (final p in r.puzzles) p.id: p,
         finalPuzzle.id: finalPuzzle,
       };

  /// Contingut de la llavor [seed]. Es genera un cop i queda a la memòria
  /// cau, perquè l'estat canvia cada segon.
  factory GameContent.forSeed(int seed) {
    final cached = _cache;
    if (cached != null && cached.seed == seed) return cached;
    return _cache = _build(seed);
  }

  static GameContent? _cache;

  static GameContent _build(int seed) {
    final v = Variation(seed);
    // Primer el pany: les sales en donen les xifres i la porta, les
    // condicions.
    final pany = buildPany(v);
    final (d1, d2, d3) = pany.digits;
    return GameContent._(
      seed: seed,
      pany: pany,
      rooms: [buildSala1(v, d1), buildSala2(v, d2), buildSala3(v, d3)],
      finalPuzzle: buildPorta(pany),
      secretBookText: buildSecretBookText(pany),
    );
  }

  final int seed;

  /// El pany «a 3 c 5 4» d'aquesta partida.
  final Pany pany;

  /// La intro (lletra a lletra) i el resum de la portada.
  final String intro;
  final String homeBlurb;

  final List<Room> rooms;

  /// La porta d'Euler.
  final Puzzle finalPuzzle;

  /// Condicions de la porta, escrites al quadern amagat.
  final String secretBookText;

  /// Tots els puzles, inclosa la porta, indexats per id.
  final Map<String, Puzzle> puzzlesById;
}
