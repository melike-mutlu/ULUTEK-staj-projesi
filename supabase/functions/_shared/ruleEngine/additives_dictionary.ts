import { normalize } from "./allergen_dictionary.ts";

/**
 * Additive info model representing E-code explanations in plain language.
 */
export interface AdditiveInfo {
  code: string;
  name: string;
  category: string;
  description: string;
  riskLevel: "safe" | "caution" | "avoid";
  isAllergenOrIrritant?: boolean;
  isControversial?: boolean;
}

/**
 * Open Food Facts E-code Dictionary in plain, everyday Turkish.
 * Key format is lowercase bare code (e.g. "e330", "e621").
 */
export const ADDITIVE_DICTIONARY: Record<string, AdditiveInfo> = {
  e100: {
    code: "E100",
    name: "Kurkumin (Zerdeçal Sarısı)",
    category: "Doğal Renklendirici",
    description:
      "Zerdeçal bitkisinden elde edilen doğal sarı renklendirici. Gıdalara canlı sarı renk verir. Sağlığa zararsızdır, antioksidan özellik gösterir.",
    riskLevel: "safe",
  },
  e101: {
    code: "E101",
    name: "Riboflavin (B2 Vitamini)",
    category: "Doğal Renklendirici / Vitamin",
    description:
      "B2 vitamini türevi olan sarı renklendirici. Gıdaları zenginleştirmek ve sarı renk vermek için kullanılır. Vücut için faydalı ve tamamen güvenlidir.",
    riskLevel: "safe",
  },
  e102: {
    code: "E102",
    name: "Tartrazin",
    category: "Sentetik Renklendirici",
    description:
      "Yapay sarı renklendirici. Şekerleme ve içeceklerde kullanılır. Astımlı veya alerjik kişilerde reaksiyon yapabilir; çocuklarda hiperaktivite riski nedeniyle dikkat edilmelidir.",
    riskLevel: "caution",
    isAllergenOrIrritant: true,
    isControversial: true,
  },
  e110: {
    code: "E110",
    name: "Sunset Yellow (Gün Batımı Sarısı)",
    category: "Sentetik Renklendirici",
    description:
      "Sentetik turuncu-sarı renklendirici. Şekerlemeler ve içeceklerde görülür. Hassas bünyelerde alerji yapabilir ve çocuklarda dikkat eksikliğini tetikleyebilir.",
    riskLevel: "caution",
    isAllergenOrIrritant: true,
    isControversial: true,
  },
  e120: {
    code: "E120",
    name: "Karmin (Cochineal / Karasinek Özütü)",
    category: "Doğal Renklendirici (Böcek Kaynaklı)",
    description:
      "Kurutulmuş karmin böceklerinden elde edilen parlak kırmızı renklendirici. Şeker ve yoğurtlarda kullanılır. Alerji riski vardır; böcek kaynaklı olduğundan vegan/vejetaryen beslenmeye uygun değildir.",
    riskLevel: "caution",
    isAllergenOrIrritant: true,
    isControversial: true,
  },
  e129: {
    code: "E129",
    name: "Allura Red AC",
    category: "Sentetik Renklendirici",
    description:
      "Yapay kırmızı renklendirici. Tatlılar ve içeceklerde kullanılır. Hassas kişilerde alerjik reaksiyon yapma riski taşır.",
    riskLevel: "caution",
    isAllergenOrIrritant: true,
  },
  e133: {
    code: "E133",
    name: "Parlak Mavi (Brilliant Blue FCF)",
    category: "Sentetik Renklendirici",
    description:
      "Sentetik mavi renklendirici. Dondurma, içecek ve şekerlemelerde kullanılır. Hassas veya astımlı bireylerde alerjik tepkilere yol açabilir.",
    riskLevel: "caution",
    isAllergenOrIrritant: true,
  },
  e141: {
    code: "E141",
    name: "Klorofil Bakır Kompleksi",
    category: "Doğal Renklendirici",
    description:
      "Bitkilerden elde edilen klorofilin bakır ile kararlı hale getirilmiş doğal yeşil renklendiricisi. Güvenlidir.",
    riskLevel: "safe",
  },
  e150a: {
    code: "E150a",
    name: "Sade Karamel",
    category: "Doğal Renklendirici",
    description:
      "Şekerin ısıtılmasıyla elde edilen kahverengi renklendirici. Soslarda ve içeceklerde kullanılır, güvenlidir.",
    riskLevel: "safe",
  },
  e150d: {
    code: "E150d",
    name: "Amonyum Sülfit Karamel",
    category: "Sentetik Karamel Renklendirici",
    description:
      "Koyu kahverengi renk veren karamel türevi (özellikle kola ve soslarda). Sülfit bileşeni içerir, yüksek tüketimde tartışmalı maddeler arasındadır.",
    riskLevel: "caution",
    isControversial: true,
  },
  e160a: {
    code: "E160a",
    name: "Beta-Karoten",
    category: "Doğal Renklendirici / A Vitamini",
    description:
      "Havuç ve turuncu meyvelerde bulunan doğal A vitamini öncülü renklendirici. Güvenli ve besleyicidir.",
    riskLevel: "safe",
  },
  e160c: {
    code: "E160c",
    name: "Paprika Ekstratı",
    category: "Doğal Renklendirici",
    description:
      "Kırmızı biberden elde edilen doğal turuncu-kırmızı renklendirici ve lezzet verici. Sağlığa zararsızdır.",
    riskLevel: "safe",
  },
  e162: {
    code: "E162",
    name: "Pancar Kırmızısı (Betanin)",
    category: "Doğal Renklendirici",
    description:
      "Kırmızı pancardan elde edilen doğal pembe-kırmızı renklendirici. Tamamen doğaldır ve güvenlidir.",
    riskLevel: "safe",
  },
  e171: {
    code: "E171",
    name: "Titanyum Dioksit",
    category: "Mineral Renklendirici (Yasaklı/Tartışmalı)",
    description:
      "Gıdalara beyaz renk ve parlaklık veren pigment. Avrupa Birliği'nde DNA hasarı ve vücutta birikim riski nedeniyle gıdalarda kullanımı yasaklanmıştır.",
    riskLevel: "avoid",
    isControversial: true,
  },
  e200: {
    code: "E200",
    name: "Sorbik Asit",
    category: "Koruyucu",
    description:
      "Küf ve maya oluşumunu önleyen koruyucu. Peynir, zeytin ve soslarda kullanılır. Vücutta doğal yağ asitleri gibi işlenir, güvenlidir.",
    riskLevel: "safe",
  },
  e202: {
    code: "E202",
    name: "Potasyum Sorbat",
    category: "Koruyucu",
    description:
      "Gıdalarda bozulmayı ve küflenmeyi engelleyen yaygın koruyucu. İçecekler, peynirler ve soslarda kullanılır. Güvenli kabul edilir.",
    riskLevel: "safe",
  },
  e211: {
    code: "E211",
    name: "Sodyum Benzoat",
    category: "Koruyucu",
    description:
      "Gazlı içecekler ve turşularda küf önleyici koruyucu. C vitamini ile yüksek ısıda birleştiğinde zararlı bileşik oluşturma riski tartışmalıdır; çocuklarda hiperaktiviteyle ilişkilendirilebilir.",
    riskLevel: "caution",
    isControversial: true,
  },
  e220: {
    code: "E220",
    name: "Kükürt Dioksit",
    category: "Koruyucu / Alerjen Sülfit",
    description:
      "Kuru meyveler ve içeceklerde kararmayı önleyen koruyucu. Astım hastalarında ve duyarlı bireylerde solunum sıkıntısı ile alerjik reaksiyon tetikleyebilir. Bilinen bir alerjendir.",
    riskLevel: "avoid",
    isAllergenOrIrritant: true,
  },
  e223: {
    code: "E223",
    name: "Sodyum Metabisülfit",
    category: "Koruyucu / Alerjen Sülfit",
    description:
      "Unlu mamuller ve kuru gıdalarda renk koruyucu. Astımlı ve sülfit alerjisi olan bireyler için belirgin bir alerjendir.",
    riskLevel: "avoid",
    isAllergenOrIrritant: true,
  },
  e250: {
    code: "E250",
    name: "Sodyum Nitrit",
    category: "Koruyucu / Renk Sabitleyici",
    description:
      "Sucuk, salam, sosis gibi işlenmiş etlerde bakteri üremesini engelleyen ve pembe rengi koruyan koruyucu. Yüksek ısıda kanserojen nitrosamin oluşturma riski nedeniyle tartışmalıdır.",
    riskLevel: "avoid",
    isControversial: true,
  },
  e251: {
    code: "E251",
    name: "Sodyum Nitrat",
    category: "Koruyucu",
    description:
      "İşlenmiş et ve peynirlerde kullanılan koruyucu. Vücutta nitrite dönüşebilir, yüksek tüketimi önerilmez.",
    riskLevel: "caution",
    isControversial: true,
  },
  e282: {
    code: "E282",
    name: "Kalsiyum Propiyonat",
    category: "Koruyucu",
    description:
      "Paket ekmek ve unlu mamullerde küflenmeyi önleyen koruyucu. Genel olarak güvenlidir; hassas kişilerde nadiren baş ağrısı yapabilir.",
    riskLevel: "safe",
  },
  e300: {
    code: "E300",
    name: "Askorbik Asit (C Vitamini)",
    category: "Antioksidan / Vitamin",
    description:
      "Doğal C vitamini. Gıdaların kararmasını önler ve tazeliği korur. Vücut için faydalı ve tamamen güvenlidir.",
    riskLevel: "safe",
  },
  e306: {
    code: "E306",
    name: "Tokoferol (E Vitamini)",
    category: "Doğal Antioksidan",
    description:
      "Bitkisel yağlardan elde edilen E vitamini. Yağların acılaşmasını önler, hücre koruyucu ve güvenlidir.",
    riskLevel: "safe",
  },
  e322: {
    code: "E322",
    name: "Lesitin",
    category: "Emülgatör / Dokusal Katkı",
    description:
      "Çikolata ve soslarda yağ ile suyun ayrışmasını önleyen emülgatör. Genellikle soya veya yumurtadan elde edilir. Soya/yumurta alerjisi olanlar dikkat etmelidir.",
    riskLevel: "safe",
    isAllergenOrIrritant: true,
  },
  e322i: {
    code: "E322i",
    name: "Lesitin (Soya / Ayçiçek)",
    category: "Emülgatör / Dokusal Katkı",
    description:
      "Soya veya ayçiçeğinden elde edilen doğal emülgatör. Dokunun pürüzsüz kalmasını sağlar. Soya alerjisi olanlar ham kaynağına dikkat etmelidir.",
    riskLevel: "safe",
    isAllergenOrIrritant: true,
  },
  e330: {
    code: "E330",
    name: "Sitrik Asit (Limon Tuzu)",
    category: "Asitlik Düzenleyici / Antioksidan",
    description:
      "Meyvelerde doğal bulunan asitlik düzenleyici. Gıdalara ferahlatıcı ekşilik verir ve tazeliği korur. Mutfaklardaki limon tuzuyla aynıdır, çok yaygın ve güvenlidir.",
    riskLevel: "safe",
  },
  e331: {
    code: "E331",
    name: "Sodyum Sitrat",
    category: "Asitlik Düzenleyici",
    description:
      "Sitrik asidin sodyum tuzu. İçecekler ve peynirlerde asitlik ayarlar ve lezzeti dengeler. Güvenlidir.",
    riskLevel: "safe",
  },
  e338: {
    code: "E338",
    name: "Fosforik Asit",
    category: "Asitlik Düzenleyici",
    description:
      "Gazlı ve kolalı içeceklerde ekşi tat veren asit. Aşırı tüketildiğinde kemik kalsiyum dengesini ve diş sağlığını olumsuz etkileyebilir.",
    riskLevel: "caution",
    isControversial: true,
  },
  e339: {
    code: "E339",
    name: "Sodyum Fosfat",
    category: "Emülgatör / Asitlik Düzenleyici",
    description:
      "Peynir ve işlenmiş gıdalarda doku düzenleyici. Fazla tüketildiğinde böbrek ve kemik sağlığı açısından dikkat edilmelidir.",
    riskLevel: "caution",
  },
  e407: {
    code: "E407",
    name: "Karragenan (Carrageenan)",
    category: "Kıvam Arttırıcı / Jelleştirici",
    description:
      "Kırmızı deniz yosunlarından elde edilen jelleştirici (sütlü tatlılar, bitkisel sütler). Hassas bağırsaklarda tahrişe veya sindirim rahatsızlıklarına yol açabileceği için tartışmalıdır.",
    riskLevel: "caution",
    isControversial: true,
  },
  e410: {
    code: "E410",
    name: "Harnup (Keçiboynuzu Gamı)",
    category: "Doğal Kıvam Arttırıcı",
    description:
      "Keçiboynuzu çekirdeklerinden elde edilen bitkisel lif ve kıvam verici. Dondurma ve soslarda kullanılır, tamamen güvenlidir.",
    riskLevel: "safe",
  },
  e412: {
    code: "E412",
    name: "Guar Gam",
    category: "Doğal Kıvam Arttırıcı",
    description:
      "Guar fasulyesinden elde edilen bitkisel lif. Doğaldır ancak yüksek miktarda tüketildiğinde gaz veya şişkinlik hissi yapabilir.",
    riskLevel: "safe",
  },
  e414: {
    code: "E414",
    name: "Arap Gamı (Gum Arabic)",
    category: "Doğal Stabilizatör",
    description:
      "Akasya ağacından elde edilen doğal lif kaynağı. İçecek ve şekerlemelerde kıvamı korur, güvenlidir.",
    riskLevel: "safe",
  },
  e415: {
    code: "E415",
    name: "Ksantan Gam (Xanthan Gum)",
    category: "Doğal Kıvam Arttırıcı",
    description:
      "Bitkisel şekerlerin fermantasyonuyla üretilen kıvam arttırıcı. Glutensiz gıdalarda esneklik sağlamak için sık kullanılır, güvenlidir.",
    riskLevel: "safe",
  },
  e422: {
    code: "E422",
    name: "Gliserol (Gliserin)",
    category: "Nem Tutucu / Tatlandırıcı",
    description:
      "Gıdaların kurumasını önleyen ve nemli kalmasını sağlayan bileşen. Sağlığa zararsızdır.",
    riskLevel: "safe",
  },
  e440: {
    code: "E440",
    name: "Pektin",
    category: "Doğal Jelleştirici",
    description:
      "Elma ve narenciye kabuklarından elde edilen jelleştirici (reçel, jöle). Sağlıklı bir bitkisel liftir.",
    riskLevel: "safe",
  },
  e471: {
    code: "E471",
    name: "Yağ Asitlerinin Mono ve Digliseritleri",
    category: "Emülgatör",
    description:
      "Ekmek, kek ve dondurmalarda yağ ile suyun ayrışmasını önler. Bitkisel veya hayvansal kaynaklı olabilir; vegan veya helal beslenenlerin kaynağına dikkat etmesi önerilir.",
    riskLevel: "safe",
  },
  e621: {
    code: "E621",
    name: "Monosodyum Glutamat (MSG / Çin Tuzu)",
    category: "Lezzet Arttırıcı (Umami)",
    description:
      "Cips, hazır çorba ve bulyonlarda umami (tuzlu/lezzetli) tadı güçlendiren madde. Hassas kişilerde baş ağrısı, terleme veya yüz kızarmasına yol açabildiği için tartışmalıdır.",
    riskLevel: "caution",
    isControversial: true,
  },
  e627: {
    code: "E627",
    name: "Disodyum Guanilat",
    category: "Lezzet Arttırıcı",
    description:
      "Genellikle MSG ile birlikte kullanılan güçlü lezzet verici. Gut hastalarının pürin içeriği nedeniyle tüketimi sınırlandırması önerilir.",
    riskLevel: "caution",
  },
  e631: {
    code: "E631",
    name: "Disodyum İnosinat",
    category: "Lezzet Arttırıcı",
    description:
      "Et ve maya özütlerinde bulunan lezzet pekiştirici. Et hassasiyeti veya gut rahatsızlığı olanlarda dikkat gerektirebilir.",
    riskLevel: "caution",
  },
  e901: {
    code: "E901",
    name: "Balmumu (Beeswax)",
    category: "Yüzey Cilalama Maddesi",
    description:
      "Meyve ve şekerleme yüzeylerine parlaklık veren doğal arı ürünü. Zararsızdır; ancak hayvansal kökenli olduğu için vegan beslenmeye uygun değildir.",
    riskLevel: "safe",
  },
  e904: {
    code: "E904",
    name: "Şolak (Shellac)",
    category: "Yüzey Cilalama Maddesi",
    description:
      "Şekerleme ve çikolatalara parlaklık veren doğal reçine. Lak böceği salgısından elde edildiği için vegan beslenmeye uygun değildir.",
    riskLevel: "safe",
  },
  e950: {
    code: "E950",
    name: "Asesulfam K",
    category: "Yapay Tatlandırıcı",
    description:
      "Şekerden yüzlerce kat tatlı, kalorisiz tatlandırıcı (diyet içecekler, sakızlar). Sağlık üzerindeki uzun vadeli etkileri tartışılmaktadır.",
    riskLevel: "caution",
    isControversial: true,
  },
  e951: {
    code: "E951",
    name: "Aspartam",
    category: "Yapay Tatlandırıcı / Alerjen Risk",
    description:
      "Diyet ürünlerde yaygın yapay tatlandırıcı. Fenilalanin içerir; fenilketonüri (PKU) hastaları kesinlikle tüketmemelidir. Sağlık üzerindeki etkileri tartışılan bir katkı maddesidir.",
    riskLevel: "avoid",
    isAllergenOrIrritant: true,
    isControversial: true,
  },
  e955: {
    code: "E955",
    name: "Sukraloz",
    category: "Yapay Tatlandırıcı",
    description:
      "Şekerden elde edilen yapay kalorisiz tatlandırıcı. Yüksek ısıda pişirmede bozunma riski ve bağırsak mikrobiyotasına etkileri tartışılmaktadır.",
    riskLevel: "caution",
    isControversial: true,
  },
  e960: {
    code: "E960",
    name: "Steviol Glikozitleri (Stevia)",
    category: "Doğal Tatlandırıcı",
    description:
      "Stevia bitkisinden elde edilen doğal kalorisiz tatlandırıcı. Şekere sağlıklı bir alternatiftir ve güvenlidir.",
    riskLevel: "safe",
  },
  e965: {
    code: "E965",
    name: "Maltitol",
    category: "Şeker Alkolü / Tatlandırıcı",
    description:
      "Şekersiz ürünlerde kullanılan şeker alkolü. Kan şekerini yavaş yükseltir; ancak fazla tüketildiğinde gaz, şişkinlik veya laksatif (ishal) etki yapabilir.",
    riskLevel: "caution",
  },
};

/**
 * Normalizes input tag (e.g. "en:e330", "E-330", "e330", "330") to canonical key ("e330").
 */
export function normalizeAdditiveCode(raw: string): string {
  if (!raw) return "";
  let clean = normalize(raw).replace(/^[a-z]{2}:/, "");
  clean = clean.replace(/[\s\-]/g, "");
  if (/^\d+[a-z]?$/i.test(clean)) {
    clean = "e" + clean;
  }
  return clean.toLowerCase();
}

/**
 * Retrieves the full additive dictionary entry for a given tag or code.
 * If not explicitly in the dictionary, returns a fallback default structure.
 */
export function getAdditiveInfo(rawTagOrCode: string): AdditiveInfo {
  const key = normalizeAdditiveCode(rawTagOrCode);
  const found = ADDITIVE_DICTIONARY[key];
  if (found) return found;

  const displayCode = rawTagOrCode.replace(/^[a-z]{2}:/, "").toUpperCase();
  return {
    code: displayCode,
    name: `Katkı Maddesi (${displayCode})`,
    category: "Katkı Maddesi",
    description:
      "Bu katkı maddesi için henüz detaylı bir açıklama tanımlanmamıştır.",
    riskLevel: "safe",
  };
}
