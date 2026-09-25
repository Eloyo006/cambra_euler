import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_state.dart';

const String rankingKey = 'cambra_euler_ranking_v1';
const int rankingSize = 5;

/// Una partida acabada.
class RankEntry {
  const RankEntry({
    required this.total,
    required this.elapsed,
    required this.penalty,
    required this.hints,
    required this.finishedAt,
  });

  final int total;
  final int elapsed;
  final int penalty;
  final int hints;

  /// Data d'acabament (ISO 8601). Serveix també d'identificador.
  final String finishedAt;

  Map<String, dynamic> toJson() => {
    'total': total,
    'elapsed': elapsed,
    'penalty': penalty,
    'hints': hints,
    'finishedAt': finishedAt,
  };

  factory RankEntry.fromJson(Map<String, dynamic> j) => RankEntry(
    total: j['total'] as int,
    elapsed: j['elapsed'] as int,
    penalty: j['penalty'] as int,
    hints: j['hints'] as int,
    finishedAt: j['finishedAt'] as String,
  );
}

/// Afegeix [entry] al rànquing i en deixa les [max] millors (menys temps
/// total; en cas d'empat, la més antiga primer). Funció pura.
List<RankEntry> insertRanking(
  List<RankEntry> ranking,
  RankEntry entry, {
  int max = rankingSize,
}) {
  if (ranking.any((e) => e.finishedAt == entry.finishedAt)) return ranking;
  final all = [...ranking, entry]
    ..sort((a, b) {
      final byTotal = a.total.compareTo(b.total);
      return byTotal != 0 ? byTotal : a.finishedAt.compareTo(b.finishedAt);
    });
  return all.take(max).toList();
}

final rankingProvider = NotifierProvider<RankingNotifier, List<RankEntry>>(
  RankingNotifier.new,
);

class RankingNotifier extends Notifier<List<RankEntry>> {
  @override
  List<RankEntry> build() {
    final raw = ref.read(prefsProvider).getString(rankingKey);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          RankEntry.fromJson(e as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  void add(RankEntry entry) {
    state = insertRanking(state, entry);
    ref
        .read(prefsProvider)
        .setString(rankingKey, jsonEncode([for (final e in state) e.toJson()]));
  }
}
