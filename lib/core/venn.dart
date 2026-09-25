import 'dart:ui';

/// Geometria d'un diagrama de Venn de dos conjunts dins d'un rectangle U.
/// Les regions segueixen l'ordre de `VennStep.regions`:
/// 0 = només A, 1 = A ∩ B, 2 = només B, 3 = fora (cap dels dos).
class VennLayout {
  const VennLayout(this.size);

  final Size size;

  static const int onlyA = 0, both = 1, onlyB = 2, outside = 3;

  /// Proporció alçada/amplada recomanada.
  static const double aspect = 0.62;

  double get radius => size.height * 0.36;
  Offset get centerA => Offset(size.width / 2 - radius * 0.62, size.height / 2);
  Offset get centerB => Offset(size.width / 2 + radius * 0.62, size.height / 2);

  bool inA(Offset p) => (p - centerA).distance <= radius;
  bool inB(Offset p) => (p - centerB).distance <= radius;

  /// Regió on cau el punt, o `null` si és fora del rectangle.
  int? regionAt(Offset p) {
    if (!(Offset.zero & size).contains(p)) return null;
    final a = inA(p), b = inB(p);
    if (a && b) return both;
    if (a) return onlyA;
    if (b) return onlyB;
    return outside;
  }

  /// On s'escriu el nombre de cada regió.
  Offset labelPosition(int region) => switch (region) {
    onlyA => centerA - Offset(radius * 0.45, 0),
    both => Offset(size.width / 2, size.height / 2),
    onlyB => centerB + Offset(radius * 0.45, 0),
    _ => Offset(size.width - 24, size.height - 20),
  };

  Path get pathA =>
      Path()..addOval(Rect.fromCircle(center: centerA, radius: radius));
  Path get pathB =>
      Path()..addOval(Rect.fromCircle(center: centerB, radius: radius));

  Path regionPath(int region) {
    final rect = Path()..addRect(Offset.zero & size);
    return switch (region) {
      onlyA => Path.combine(PathOperation.difference, pathA, pathB),
      both => Path.combine(PathOperation.intersect, pathA, pathB),
      onlyB => Path.combine(PathOperation.difference, pathB, pathA),
      _ => Path.combine(
        PathOperation.difference,
        rect,
        Path.combine(PathOperation.union, pathA, pathB),
      ),
    };
  }
}
