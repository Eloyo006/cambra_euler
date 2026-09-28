/// Tipografia de les fórmules escrites en text pla (Unicode).
library;

/// Espai que no permet salt de línia.
const String nbsp = ' ';

/// Caràcter invisible que impedeix un salt de línia entre dos caràcters.
const String wordJoiner = '⁠';

const _glue = '+−·×…';
const _relations = '=≥≤≡<>⇒';

/// Evita que un salt de línia parteixi una fórmula per un lloc absurd,
/// com «(k +» | «1)» o «n» | «≥ 0». Canvia per [nbsp] els espais:
/// - al voltant de `+ − · × …` (mai no s'hi parteix);
/// - davant d'una relació (`= ≥ ≤ ≡ …`), i darrere si el que ve és curt
///   («≥ 0», «= 0,»);
/// - dins d'un parèntesi curt, com «(k + 1)».
/// Els espais de la prosa normal no es toquen.
String keepMathTogether(String s) {
  final out = StringBuffer();
  var glueUntil = -1; // Final del parèntesi curt actual.
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (ch == '(') {
      final close = s.indexOf(')', i);
      if (close > i && close - i <= 14) glueUntil = close;
    }
    if (ch != ' ') {
      out.write(ch);
      // Ni «k(k + 1)/» | «2» ni «(k + 1)» | «(k + 2)».
      final nextCh = i + 1 < s.length ? s[i + 1] : '';
      if (ch == '/' || ch == ')' && nextCh == '(') out.write(wordJoiner);
      continue;
    }
    final prev = i > 0 ? s[i - 1] : '';
    final next = i + 1 < s.length ? s[i + 1] : '';
    final glue =
        i < glueUntil ||
        _glue.contains(prev) && prev.isNotEmpty ||
        _glue.contains(next) && next.isNotEmpty ||
        _relations.contains(next) && next.isNotEmpty ||
        _relations.contains(prev) && prev.isNotEmpty && _shortTokenAt(s, i + 1);
    out.write(glue ? nbsp : ' ');
  }
  return out.toString();
}

/// Cert si la paraula que comença a [start] té com a molt 2 caràcters i no
/// obre cap parèntesi (llavors és l'inici d'una expressió llarga).
bool _shortTokenAt(String s, int start) {
  var end = s.indexOf(' ', start);
  if (end < 0) end = s.length;
  return end - start <= 2 && !s.substring(start, end).contains('(');
}
