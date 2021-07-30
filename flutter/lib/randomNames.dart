import 'dart:math';

const Set<String> _adjective = {
  "pendula",
  "jacquemontii",
  "pubescens",
  "ilex",
  "robur",
  "petrae",
  "suber",
  "grandiflora",
  "sinensis",
  "floribunda",
  "vinifera",
  "lambrusca",
  "alba",
  "europaea",
  "japonica",
  "officinalis",
  "angustifolia",
  "sativa",
  "regia",
  "avium",
  "cordata",
  "biloba",
  "carica",
  "laurocerasus",
  "americana",
  "nobilis"
};
const Set<String> _thing = {
  "betula",
  "quercus",
  "magnolia",
  "wisteria",
  "vitis",
  "abies",
  "olea",
  "camellia",
  "lavandula",
  "salvia",
  "rosmarinus",
  "castanea",
  "juglans",
  "prunus",
  "tilia",
  "ginkgo",
  "ficus",
  "fraxinus",
  "laurus"
};

class RandomNames {
  static Random rand = Random.secure();

  static String randomAdjective() {
    int l = _adjective.length - 1;
    int idx = (rand.nextDouble() * l).round().toInt();
    return _adjective.elementAt(idx);
  }

  static String randomThing() {
    int l = _thing.length - 1;
    int idx = (rand.nextDouble() * l).round().toInt();
    return _thing.elementAt(idx);
  }
}
