# La Cambra d'Euler — Brief complet per a Claude Code

> Aquest document és la **font de veritat** del projecte. Llegeix-lo sencer abans de tocar codi.
> Treballa **fase per fase**, en ordre. Al final de cada fase: `flutter analyze` sense errors, `flutter test` en verd, i un resum breu dels canvis. No passis a la fase següent sense aquests dos checks.

---

## 1. Context

- **Què és:** un escape room matemàtic per a Android, fet en Flutter. És un treball extra per al professor de **FOMA** (Enginyeria Informàtica, EPSEVG-UPC).
- **Temes:** teoria de conjunts, aritmètica modular (congruències, ℤ/nℤ i inversos) i inducció matemàtica.
- **Entregables:**
  1. Un APK Android en mode release.
  2. Una memòria en `.docx`.
  3. El codi font.
- **Durada objectiu:** 20–30 minuts per partida, amb nivell de curs.

### Restriccions fermes
| Restricció | Detall |
|---|---|
| Plataforma | **Android** (APK). 100 % **offline**: sense backend, sense Supabase i sense cap xarxa. |
| Idioma | Tota la UI en **català**. |
| Enunciats | **Variables per partida**: cada partida té una llavor (`GameState.seed`, aleatòria en fer «Nova partida») i el contingut es genera a partir d'ella (`GameContent.forSeed`). Les variants surten de **taules curades a mà**, mai de números a l'atzar sense control. Els ids dels puzles no canvien mai entre variants. |
| Estat | `flutter_riverpod` 2.x (`Notifier`) + `shared_preferences`. No afegeixis Hive, Bloc ni go_router. |
| Pistes | 3 nivells per puzle ("Suggeriment", "Teoria", "Gairebé la solució"). Penalització de **+30, +60 i +120 s**. |
| Temps | Cronòmetre que compta endavant. El widget `GameClock` mostra el temps total i, dins d'un enigma, també el temps d'aquell enigma (temps real a dins, acumulat entre visites i congelat en resoldre'l, més la penalització de les seves pistes). El temps total és el temps real més les penalitzacions. |
| Alfabet | **27 lletres, amb la Ç entre la N i la O**: `ABCDEFGHIJKLMNÇOPQRSTUVWXYZ`. No hi ha Ñ. |
| Notació del professor | A la llista d'exercicis, ℤₙ s'escriu com a **{1, …, n}**, amb n ≡ 0. Per exemple, ℤ₇ = {1,…,7} i ℤ₅ = {1,…,5}. Respecta aquesta notació allà on el PDF la fa servir: la taula mod 5 del puzle 2.1 i les rodes de la porta final. |
| Aritmètica modular | Només congruències, ℤ/nℤ, inversos i xifrats afins. **No facis servir** el Teorema Xinès del Residu, Fermat ni φ d'Euler: no s'han donat a classe. |
| Dependències | Mínimes. Les úniques noves que es permeten, i només si cal, són `flutter_math_fork` (fórmules) i `audioplayers` (so opcional). |

---

## 2. Estat actual (Fase 1: feta però **mai compilada**)

El codi s'ha escrit sense SDK. **La primera tasca és que compili.**

```
cambra_euler/
  pubspec.yaml            flutter_riverpod ^2.6.1, shared_preferences ^2.3.2, sdk >=3.6
  analysis_options.yaml
  README.md
  lib/
    main.dart             ProviderScope + override de prefsProvider; pausa el rellotge en segon pla
    core/modular.dart     mod(), inverse(), solveLinear(), affineEncrypt/Decrypt(), alphabet27
    core/theme.dart       AppColors (ink, slate, card, gold, chalk, ok, error), buildTheme(), formatTime()
    models/puzzle.dart    Room, Puzzle, PuzzleStep (.code / .text / .choice), StepKind
    data/content.dart     rooms (3 sales × 3 puzles), finalPuzzle, introText, hintPenalties
    state/game_state.dart GameState (progress, hints, elapsed, penalty, finished) + GameNotifier
    screens/              home, map (vestíbul + pany "_ 3 _ 5 4"), room, puzzle, victory
    widgets/mod_clock.dart
  test/content_test.dart  verifica matemàticament totes les solucions
```

### Fase 0: arrencada (fes-la primer)
1. `flutter create . --platforms android --project-name cambra_euler`. Genera `android/` i no ha de sobreescriure `lib/`. Comprova-ho amb `git status`, o el que toqui.
2. `flutter pub get`, després `flutter analyze` i després `flutter test`. Arregla tots els errors i warnings. Punts a revisar:
   - `CardThemeData` ha de coincidir amb la versió de Flutter instal·lada.
   - Cal `withValues(alpha:)`. Si el Flutter és antic, fes servir `withOpacity`.
   - `FontFeature` s'importa des de `dart:ui` o `material`.
3. Inicialitza git, fes un `.gitignore` estàndard de Flutter i el primer commit: `feat: fase 1 base jugable`.
4. Executa l'app en un emulador i recorre-la sencera fins a la victòria (les solucions són a la §4).

---

## 3. Arquitectura i convencions

- **El contingut és dades.** Cap enunciat, pista ni solució ha d'estar escrit dins dels widgets. Tot va a `lib/data/`: un fitxer per sala (`sala1.dart`…, `porta.dart`) amb una funció `Puzzle nom(Rng r)` per puzle, que treu enunciat, passos, pistes i solució dels mateixos paràmetres. `content.dart` hi munta `GameContent`; `texts.dart` té els textos i regles fixos. `lib/core/rng.dart` és el generador determinista (no el canviïs: les partides desades en depenen; ho vigila `test/rng_test.dart`).
- **Variants.** Cada taula de variants té la fila del PDF en primer lloc; `pdfSeed` (-1) la força (tests de la §4, captures, partides antigues). Les solucions es **calculen** amb `core/modular.dart`, mai a mà. Les xifres de les sales i les condicions de la porta surten d'un sol objecte, `Pany` (`lib/data/porta.dart`), que llegeixen sales, porta, quadern, intro i portada. Per afegir una variant, afegeix una fila a la taula; `test/content_test.dart` la valida per a 200 llavors.
- **La validació és una funció pura i té test.** Cada mecànica interactiva té un validador pur a `lib/core/` o al model, i test a `test/`.
- **Extensió del motor (Fase 2):** converteix `PuzzleStep` en una jerarquia `sealed class PuzzleStep`.
  - Subclasses actuals: `CodeStep`, `TextStep`, `ChoiceStep`.
  - Subclasses noves: `TableStep`, `VennStep`, `ExpressionStep`, `PartitionStep`, `OrderStep`, `HanoiStep`, `TapLineStep` i `WheelLockStep`.
  - Cada subclasse té dades immutables (`const`) i un mètode `bool check(Object answer)`.
  - Un `StepView` fa un `switch` exhaustiu sobre el tipus de pas i crida el widget que toca, dins de `lib/widgets/steps/`.
  - `GameNotifier.answer(Puzzle, Object)` es manté com a únic punt d'entrada.
- La persistència es fa amb la clau `cambra_euler_state_v1`. Si canvia el format, puja a `_v2` i migra les dades o reinicia la partida.
- **Estil visual:** tema fosc de pissarra amb accents daurats (`AppColors`). Cada sala té el seu color: Biblioteca `#3F7CAC`, Rellotges `#C08A2E`, Dòmino `#6A994E`.
- **UI:**
  - Àrea mínima tàctil de 48 px.
  - Ha de funcionar en vertical des de 360 dp d'amplada.
  - Cap text ha de sortir tallat.
  - Les fórmules poden anar en Unicode (ℤ₅, ⁻¹, ≡, ∪, ∩, ′). `flutter_math_fork` només s'ha de fer servir si realment millora el resultat.
- **Commits:** un commit per fase com a mínim, amb el format `feat(sala2): taula mod 5 interactiva`.

---

## 4. Contingut i solucions (font de veritat)

Totes les solucions estan verificades a `test/content_test.dart`. **No les canviïs.** Amb les variants per partida, aquests són els valors del PDF del professor: han de ser sempre **una de les variants** de cada taula.

**Lògica del codi final.** Cada sala dona una xifra del pany `a 3 c 5 4`:
- Sala 1 → «3» (posició 2)
- Sala 2 → «5» (posició 4)
- Sala 3 → «4» (posició 5)

La porta final demana calcular `a` i `c`.

### Sala 1 · La Biblioteca: Conjunts (apunts FOMA)
| Puzle | Passos i solució |
|---|---|
| **1.1 Venn.** 40 lectors: 25 llatí (A), 18 grec (B), 7 totes dues | \|A∪B\| = **36** · cap dels dos = **4** |
| **1.2 De Morgan.** La porta s'obre amb (A∪B)′ | (A∪B)′ = **A′ ∩ B′** · (A∩B)′ = **A′ ∪ B′** |
| **1.3 Particions.** Llibres 1–6 | La partició és **{1,3,5},{2,4},{6}** · amb a≡b (mod 3), la classe [2] = **{2,5}** |

### Sala 2 · La Sala dels Rellotges: Aritmètica modular (llista d'exercicis, ex. 1–8)
| Puzle | Exercici | Passos i solució |
|---|---|---|
| **2.1 Taula del rellotger** | Ex. 1 | L'invers de 2 a ℤ₅ és **3** · a ℤ₆ tenen invers **1 i 5** · 2x ≡ 1 (mod 6): **no té solució** |
| **2.2 Panys de control** | Ex. 2 i 3 | El codi `4x1y` amb 3b≡c i 2a≡d (mod 5) és **4213** · amb vocals a=0…u=4, `eoiX` amb 3X≡1 (mod 5) dona X = **i** (única) |
| **2.3 Missatge xifrat** | Ex. 6, 7 i 8 | César x+3: `ERP_GLD` → **BON DIA** · 2x+1 (mod 6) amb `BDF`: **no es pot saber, cada lletra té 2 orígens** · afí 2x+3 (mod 27), amb invers de 2 = 14: `YSFMG` → **LIBRO** |

- Ex. 5 (g(x) = 2x a ℤ₇: 3→6, 5→3, g⁻¹(4)=2, g⁻¹(2)=1) és la targeta de teoria del puzle 2.3: és bijectiva, però és un xifrat dolent.
- Casella pre-emplenada de la taula mod 5 del PDF (fila × columna, amb 5 ≡ 0):
  - fila 1: col 2 = 2
  - fila 2: col 1 = 2, col 3 = 1, col 4 = 3, col 5 = 5
  - fila 3: col 4 = 2
  - fila 4: col 1 = 4, col 3 = 2, col 4 = 1

### Sala 3 · La Torre del Dòmino: Inducció (apunts FOMA)
| Puzle | Passos i solució |
|---|---|
| **3.1 Prova de Bernoulli.** (1+a)ⁿ ≥ 1+an, a ≥ −1 | Cas base: **(1+a)⁰ = 1 = 1+a·0** · es pot multiplicar per (1+a) perquè **a ≥ −1 ⇒ 1+a ≥ 0** · a²k es pot eliminar perquè **a² ≥ 0 i k ≥ 0** |
| **3.2 Torres de Hanoi** | M(3) = **7** · M(5) = **31** · M(n) = **2ⁿ − 1** (suma geomètrica amb a₁=1, r=2) |
| **3.3 Cavalls del mateix color** | Falla **el pas de k=1 a k+1=2**: els grups {c₁} i {c₂} no comparteixen cap cavall |

### Porta d'Euler (Ex. 4)
- Condicions: `a 3 c 5 4` a ℤ₇, a = 3⁻¹ i 5c ≡ 4.
- Solució: **a = 5**, **c = 5**, codi **53554**.

---

## 5. Fases pendents

### Fase 2: motor de passos interactius
- Refactoritza `PuzzleStep` en una `sealed class` (§3). Migra el contingut actual sense canviar cap solució.
- Crea `StepView` i un widget base per a cada tipus nou. Al principi n'hi ha prou que siguin funcionals, encara que estiguin buits.
- Afegeix feedback comú per a tots els tipus:
  - Resposta incorrecta: una sacsejada horitzontal (`shake`) i un missatge.
  - Resposta correcta: un check animat i `HapticFeedback`.
- **Criteri d'acceptació:** tots els tests antics passen, i hi ha un test per a cada `check()` nou.

### Fase 3: Sala 1 interactiva
1. **1.1 Venn (`VennStep`):**
   - Un diagrama de dos cercles dibuixat amb `CustomPaint`.
   - L'alumne toca cada regió i hi escriu el nombre: només A, A∩B, només B i fora. Solució: **18, 7, 11, 4**.
   - Després ha de respondre |A∪B| = 36.
   - Cada regió s'il·lumina quan està bé.
2. **1.2 Tauler de De Morgan (`ExpressionStep`):**
   - Un constructor d'expressions amb fitxes `A′`, `B′`, `A`, `B`, `∩`, `∪`, `(`, `)`.
   - La validació ha de ser **semàntica**: s'avalua l'expressió sobre un univers de prova i es compara amb (A∪B)′. Univers de prova: U = {1..8}, A = {1,2,3,4}, B = {3,4,5,6}.
   - Es fa servir un parser petit a `lib/core/set_expr.dart`, amb tests.
   - S'accepta qualsevol expressió equivalent.
3. **1.3 Prestatgeria (`PartitionStep`):**
   - Es fa amb `Draggable` i `DragTarget`: 6 llibres i 3 caixes.
   - **Pas 1:** fer qualsevol partició de {1..6} en exactament 3 caixes no buides.
   - **Pas 2:** fer les classes mod 3, que són **{3,6}, {1,4}, {2,5}**. L'ordre de les caixes no importa.
   - Després es respon la pregunta de [2].
4. **Llibre amagat:**
   - Quan es resol el puzle 2.3 («LIBRO»), a la Biblioteca apareix un llibre brillant.
   - En obrir-lo es mostra la pista de la porta final: «a és l'invers de 3; c·5 ≡ 4, a ℤ₇».
   - La porta final només mostra aquest text si el llibre s'ha obert. Cal afegir el flag al `GameState`.

### Fase 4: Sala 2 interactiva
1. **2.1 Taula (`TableStep`):**
   - Una graella 5×5 amb les caselles pre-emplenades del PDF (§4).
   - L'alumne omple la resta amb un teclat de 1–5 (5 ≡ 0).
   - Quan la taula és correcta, marca les caselles on surt "1". D'aquí es dedueixen els inversos.
   - Després es mostra la taula de ℤ₆, que ja ve completa. L'alumne toca els elements que tenen invers: **1 i 5**.
   - Per acabar, el pany de 2x ≡ 1 (mod 6), on la resposta correcta és el botó «No té solució».
2. **2.2 Panys (`WheelLockStep`):**
   - Primer pany: 4 rodes numèriques; el codi `4 ? 1 ?` té dues rodes bloquejades.
   - Segon pany: 4 rodes de vocals a/e/i/o/u.
   - Les rodes es fan amb `ListWheelScrollView`.
3. **2.3 Roda de César:**
   - Dos discos concèntrics amb l'alfabet de 27 lletres. L'alumne gira el disc interior per trobar el desplaçament.
   - Un camp de text per escriure el missatge desxifrat.
   - Per a l'afí: una taula d'ajuda x → 2x+3 que es desbloqueja amb la pista 2.
   - La pregunta de `BDF` es manté com a opció múltiple.

### Fase 5: Sala 3 interactiva
1. **3.1 Prova de Bernoulli (`OrderStep`):**
   - Un `ReorderableListView` amb 6 línies de la prova desordenades, que cal ordenar: cas base, hipòtesi, multiplicar per (1+a), desenvolupar, eliminar a²k i conclusió.
   - Després, les dues preguntes de justificació que ja existeixen.
   - Animació: quan l'ordre és correcte, cau una fila de dòminos.
2. **3.2 Hanoi (`HanoiStep`):**
   - Joc real amb 3 agulles: primer amb 3 discos, després amb 4.
   - Es compta cada moviment, i un moviment il·legal es rebutja amb una sacsejada.
   - Per superar-lo cal acabar amb el mínim de moviments (7 i 15). Si en fa més, es mostra «Ho has aconseguit en N; el mínim és 2ⁿ−1» i s'ha de tornar a intentar.
   - Després, les preguntes de M(5) = 31 i de la fórmula.
3. **3.3 Cavalls (`TapLineStep`):**
   - La "prova" es mostra línia a línia i l'alumne toca la línia on falla.
   - Tot seguit, una animació amb k=1→2 on es veu que els dos grups són disjunts.
4. **(Opcional, bonus) 3.4 Divisibilitat:**
   - Ex. 11: 5ⁿ + 1 és divisible per 2 però no per 4. Ex. 30: 3⁴ⁿ + 9 és múltiple de 10.
   - Per inducció i amb congruències: 3⁴ = 81 ≡ 1 (mod 10), i per tant 3⁴ⁿ + 9 ≡ 1 + 9 ≡ 0.
   - Ha de ser un puzle opcional: no bloqueja la porta, però dona un bonus de −60 s.

### Fase 6: Porta final i narrativa
- **Porta:**
  - 5 rodes amb els valors 1–7 (notació del PDF).
  - Les rodes 2, 4 i 5 venen fixades amb les xifres guanyades a les sales.
  - Primer es demanen a i c com a passos guiats; després es giren les rodes fins a **53554**.
  - Animació d'obertura de la porta.
- **Narrativa:**
  - Pantalla d'intro amb text que s'escriu lletra a lletra (es pot saltar).
  - Frase d'entrada per a cada sala (ja existeix com a `room.intro`).
  - Missatge d'Euler a la victòria.
- **Victòria:**
  - Temps total, temps real, penalització i pistes fetes servir per sala.
  - Rànquing local de les 5 millors partides, guardat a `shared_preferences`.
- **So (opcional):** clic de les rodes, pany que s'obre i error. Ha d'haver-hi un botó per silenciar-lo.

### Fase 7: Poliment i APK
- Nom de l'app: `La Cambra d'Euler`, a `android:label`. Icona pròpia: un pany amb el símbol ≡, feta amb `flutter_launcher_icons` o a mà.
- Pantalla de splash de color `AppColors.ink`. Orientació només vertical.
- Widget tests del flux complet: inici → sala → puzle → pista → resolució.
- Accessibilitat: `Semantics` als elements interactius i contrast mínim AA.
- Comprova que no hi ha cap permís d'Internet al manifest de release.
- Executa `flutter build apk --release`. Signar amb la clau de debug és acceptable, però documenta-ho al README.
- Posa el README al dia amb les captures i les instruccions d'instal·lació de l'APK.

### Fase 8: Memòria (.docx)
Genera `docs/Memoria_Cambra_Euler.docx`, amb `python-docx` o el paquet npm `docx`. Format:
- **Fons blanc**, apte per imprimir.
- Títols jeràrquics i índex automàtic.
- Captures de pantalla fetes a l'emulador.

Estructura:
1. **Portada:** títol, assignatura (FOMA), autor (Eloy), curs 2026/27 i EPSEVG-UPC.
2. **Objectius:** aprendre jugant; relacionar els conjunts (classes d'equivalència) amb ℤ/nℤ, i connectar la inducció amb les progressions geomètriques.
3. **Descripció del joc:** narrativa, mapa de les sales, pany «a 3 c 5 4», pistes, temps total i temps per enigma.
4. **Una secció per sala i per puzle:**
   - Enunciat i origen (apunts o número d'exercici).
   - Teoria aplicada.
   - **Solució raonada pas a pas.**
   - Captura de pantalla.
5. **Connexions entre temes:**
   - Les classes mod n formen una partició, que és on es troben conjunts i modular.
   - Hanoi és alhora un problema d'inducció i una suma geomètrica.
   - «LIBRO» fa de pont entre la Sala 2 i la Sala 1.
6. **Disseny tècnic:** arquitectura, model de dades, per què els validadors són purs, tests (inclou la sortida de `flutter test`) i decisions preses (offline, enunciats fixos).
7. **Conclusions i possibles millores:** enunciats aleatoris, més sales (TXR, Fermat) i un mode per al professor.
8. **Annex:** taula de solucions completa (§4).

---

## 6. Definició de "fet"
- [ ] `flutter analyze`: 0 issues.
- [ ] `flutter test`: tot en verd, amb tests per a cada validador i per al contingut.
- [ ] Partida completa jugada a l'emulador de principi a final sense errors. Sabent les respostes, s'ha de poder acabar en menys de 5 minuts; un alumne nou hauria de trigar entre 20 i 30.
- [ ] Progrés persistent: si es tanca l'app i es torna a obrir, continua on era, amb el temps i les pistes.
- [ ] APK release generat i instal·lat en un dispositiu o emulador.
- [ ] `docs/Memoria_Cambra_Euler.docx` generada, amb captures.
- [ ] README actualitzat.

## 7. Regles de treball
- Treballa una fase cada vegada. En acabar-la, fes un resum breu del que s'ha fet i dels problemes que hagin sortit.
- No canviïs cap solució ni enunciat de la §4 sense preguntar-ho.
- Si una mecànica interactiva es complica massa, deixa-la com a `ChoiceStep` o `CodeStep` i apunta-ho com a millora pendent.
- Codi i comentaris en català o anglès, però la UI sempre en català.
