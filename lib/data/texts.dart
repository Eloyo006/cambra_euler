// Textos i regles del joc. Els que depenen de la partida (el pany) són
// funcions i en queden desats a GameContent.

const List<int> hintPenalties = [30, 60, 120];
const List<String> hintLabels = ['Suggeriment', 'Teoria', 'Gairebé la solució'];

/// La intro que s'escriu lletra a lletra. [pany] és «a 3 c 5 4».
String buildIntroText(String pany) =>
    "Sant Petersburg, 18 de setembre de 1783. Leonhard Euler ha mort aquesta "
    "tarda, i tu, el seu ajudant, ets l'única persona que queda a la casa.\n\n"
    "A la seva cambra de treball hi ha l'últim manuscrit d'Euler. A trenc "
    "d'alba, l'Acadèmia de Ciències vindrà a segellar-la, i ningú no el "
    "tornarà a llegir. La porta té un pany de cinc xifres. Només s'hi llegeix "
    "«$pany».\n\n"
    "Els últims anys, Euler ja no hi veia, i ho guardava tot al cap. Va "
    "amagar cada xifra que falta en una sala de la casa i hi va deixar "
    "enigmes, perquè només pogués entrar qui els entengués: la Biblioteca "
    "(conjunts), la Sala dels Rellotges (aritmètica modular) i la Torre del "
    "Dòmino (inducció). Les dues lletres, a i c, les hauràs de calcular tu.\n\n"
    "La nit s'acaba. Cada pista que demanis t'acosta a l'alba.";

/// Resum curt per a la portada; la història sencera és a [buildIntroText].
String buildHomeBlurb(String pany) =>
    "Sant Petersburg, 1783. Euler acaba de morir, i a trenc d'alba "
    "l'Acadèmia segellarà la seva cambra de treball. Tens una nit per trobar "
    "les xifres del pany «$pany» i salvar-ne l'últim manuscrit.";

const String victoryText =
    "La porta cedeix. Sobre la taula, entre espelmes consumides, hi ha el "
    "manuscrit i una nota amb la lletra tremolosa d'Euler:\n\n"
    "«Si llegeixes això, has entès que els conjunts, els residus i la "
    "inducció són una mateixa manera de pensar. Continua tu el que jo no he "
    "pogut acabar.»\n\n"
    "Just quan surts amb el manuscrit sota el braç, se sent la carrossa de "
    "l'Acadèmia. «Llegiu Euler, llegiu Euler: és el mestre de tots "
    "nosaltres.»";

/// El llibre amagat: apareix a la Biblioteca quan es resol el puzle 2.3
/// i conté les condicions de la porta (el text és a [GameContent]).
const String secretBookUnlockedBy = '2.3';
const String secretBookRoom = 'sala1';
const String secretBookTitle = 'Un llibre que brilla';
const String secretBookMissing =
    "Encara no has trobat on són escrites les condicions. Potser les cartes "
    "xifrades de la Sala dels Rellotges diuen on buscar…";
