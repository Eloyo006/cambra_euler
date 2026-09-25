import 'package:cambra_euler/state/ranking.dart';
import 'package:flutter_test/flutter_test.dart';

RankEntry e(int total, String date) => RankEntry(
  total: total,
  elapsed: total,
  penalty: 0,
  hints: 0,
  finishedAt: date,
);

void main() {
  test('ordena per temps total i en guarda 5', () {
    var r = <RankEntry>[];
    for (final (t, d) in [
      (500, 'a'),
      (300, 'b'),
      (700, 'c'),
      (100, 'd'),
      (600, 'e'),
      (200, 'f'),
      (900, 'g'),
    ]) {
      r = insertRanking(r, e(t, d));
    }
    expect(r.map((x) => x.total), [100, 200, 300, 500, 600]);
  });

  test('una partida lenta no entra si el rànquing és ple', () {
    final full = [for (var i = 1; i <= 5; i++) e(i * 100, '$i')];
    final r = insertRanking(full, e(1000, 'x'));
    expect(r.map((x) => x.finishedAt), ['1', '2', '3', '4', '5']);
  });

  test('en cas d\'empat, primer la més antiga', () {
    final r = insertRanking([e(300, '2026-01-02')], e(300, '2026-01-01'));
    expect(r.map((x) => x.finishedAt), ['2026-01-01', '2026-01-02']);
  });

  test('la mateixa partida no s\'afegeix dues vegades', () {
    final r = insertRanking([e(300, 'a')], e(300, 'a'));
    expect(r, hasLength(1));
  });

  test('JSON d\'anada i tornada', () {
    final x = e(123, '2026-09-25T12:00:00');
    final y = RankEntry.fromJson(x.toJson());
    expect(
      [y.total, y.elapsed, y.penalty, y.hints, y.finishedAt],
      [123, 123, 0, 0, '2026-09-25T12:00:00'],
    );
  });
}
