import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/word.dart';

class OsymWordDatabase {
  static List<Word> _loadedWords = [];
  static List<Word> get words => _loadedWords.isNotEmpty ? _loadedWords : _coreWords;

  static Future<void> init() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/osym_words.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _loadedWords = jsonList.map((j) => Word.fromJson(j)).toList();
      debugPrint("OsymWordDatabase: Successfully loaded ${_loadedWords.length} words from JSON.");
    } catch (e) {
      debugPrint("OsymWordDatabase: Error loading JSON: $e");
      _loadedWords = List.from(_coreWords);
    }
  }

  static const List<Word> _coreWords = [
    // ---------------- VERBS (FİİLLER) ----------------
    Word(
      id: 'v_mitigate',
      word: 'mitigate',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sağlık', 'Son 15 Yıl'],
      meaning: 'hafifletmek, azaltmak, yatıştırmak',
      detailedMeaning: 'Bir acının, zararın veya olumsuz etkinin şiddetini azaltmak.',
      root: WordRoot(
        rootWord: 'mitis (Lat.)',
        rootMeaning: 'yumuşak, ılımlı',
        explanation: 'Latince "mitis" (yumuşak) + "agere" (yapmak) birleşiminden türemiştir: yumuşatmak, şiddetini kırmak.',
      ),
      derivatives: [
        WordDerivative(word: 'mitigate', partOfSpeech: 'Fiil', meaning: 'hafifletmek, azaltmak'),
        WordDerivative(word: 'mitigation', partOfSpeech: 'İsim', meaning: 'hafifletme, azaltım (ör. climate change mitigation)'),
        WordDerivative(word: 'mitigating', partOfSpeech: 'Sıfat', meaning: 'hafifletici (ör. mitigating circumstances)'),
        WordDerivative(word: 'unmitigated', partOfSpeech: 'Sıfat', meaning: 'hafifletilmemiş, katıksız, tam bir (felaket vb.)'),
      ],
      synonyms: ['alleviate', 'lessen', 'relieve', 'diminish', 'curb', 'soothe'],
      antonyms: ['aggravate', 'exacerbate', 'worsen', 'intensify'],
      examples: [
        ExampleSentence(
          english: 'Governments must take urgent measures to mitigate the devastating impacts of climate change.',
          turkish: 'Hükümetler, iklim değişikliğinin yıkıcı etkilerini hafifletmek için acil önlemler almalıdır.',
        ),
      ],
      collocations: ['mitigate the effects/impacts of', 'mitigate the risk', 'mitigation strategy'],
      examTip: 'ÖSYM sorularında sıklıkla "alleviate", "lessen" veya "ease" kelimeleriyle doğru seçenek eşleştirmesi yapılır.',
    ),

    Word(
      id: 'v_deteriorate',
      word: 'deteriorate',
      type: WordType.verb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'kötüleşmek, bozulmak, fenalaşmak',
      detailedMeaning: 'Zamanla kalitesini, sağlığını veya durumunu kaybetmek.',
      root: WordRoot(
        rootWord: 'deterior (Lat.)',
        rootMeaning: 'daha kötü, aşağı',
        explanation: 'Latince "deterior" (daha kötü) kökünden gelir; giderek daha kötü bir duruma gerilemeyi ifade eder.',
      ),
      derivatives: [
        WordDerivative(word: 'deteriorate', partOfSpeech: 'Fiil', meaning: 'kötüleşmek, bozulmak'),
        WordDerivative(word: 'deterioration', partOfSpeech: 'İsim', meaning: 'kötüleşme, bozulma, çöküş'),
        WordDerivative(word: 'deteriorating', partOfSpeech: 'Sıfat', meaning: 'kötüleşmekte olan, bozulan'),
      ],
      synonyms: ['worsen', 'decline', 'degenerate', 'decay', 'impair'],
      antonyms: ['improve', 'ameliorate', 'recover', 'enhance'],
      examples: [
        ExampleSentence(
          english: 'The patient’s health began to deteriorate rapidly despite intensive medical intervention.',
          turkish: 'Yoğun tıbbi müdahaleye rağmen hastanın sağlığı hızla kötüleşmeye başladı.',
        ),
      ],
      collocations: ['rapidly deteriorate', 'deteriorate into chaos', 'economic deterioration'],
      examTip: 'YÖKDİL Sağlık ve Fen sınavlarında "decline" ve "worsen" yerine sıklıkla aranan kelimedir.',
    ),

    Word(
      id: 'v_allocate',
      word: 'allocate',
      type: WordType.verb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'tahsis etmek, ayırmak, paylaştırmak',
      detailedMeaning: 'Bütçe, kaynak veya zamanı belirli bir amaca tahsis etmek.',
      root: WordRoot(
        rootWord: 'locus (Lat.)',
        rootMeaning: 'yer, konum',
        explanation: 'Latince "ad-" (doğru) + "locus" (yer) -> Bir şeyi yerleştirmek, payına yer ayırmak.',
      ),
      derivatives: [
        WordDerivative(word: 'allocate', partOfSpeech: 'Fiil', meaning: 'tahsis etmek, ayırmak'),
        WordDerivative(word: 'allocation', partOfSpeech: 'İsim', meaning: 'ödenek, paylaştırma, tahsisat'),
        WordDerivative(word: 'allocator', partOfSpeech: 'İsim', meaning: 'dağıtıcı, tahsis eden'),
      ],
      synonyms: ['assign', 'allot', 'designate', 'distribute', 'apportion'],
      antonyms: ['withhold', 'deprive', 'deny'],
      examples: [
        ExampleSentence(
          english: 'The ministry decided to allocate more financial resources to educational infrastructure.',
          turkish: 'Bakanlık, eğitim altyapısına daha fazla mali kaynak tahsis etmeye karar verdi.',
        ),
      ],
      collocations: ['allocate resources/funds/budget to', 'resource allocation'],
      examTip: 'Sosyal Bilimler ve YDS Ekonomi paragraflarında "allocate ... to" edatı ile çok sık test edilir.',
    ),

    Word(
      id: 'v_jeopardize',
      word: 'jeopardize',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'tehlikeye atmak, riske sokmak',
      detailedMeaning: 'Birinin veya bir şeyin güvenliğini, başarısını riske atmak.',
      root: WordRoot(
        rootWord: 'jeu parti (Eski Fr.)',
        rootMeaning: 'bölünmüş oyun, eşit şans',
        explanation: 'Eski Fransızca "jeu parti" (sonucu belirsiz, tehlikeli kumar/oyun) sözünden türetilmiştir.',
      ),
      derivatives: [
        WordDerivative(word: 'jeopardize', partOfSpeech: 'Fiil', meaning: 'tehlikeye atmak'),
        WordDerivative(word: 'jeopardy', partOfSpeech: 'İsim', meaning: 'tehlike, risk (ör. in jeopardy)'),
      ],
      synonyms: ['endanger', 'imperil', 'threaten', 'put at risk'],
      antonyms: ['protect', 'safeguard', 'shield', 'secure'],
      examples: [
        ExampleSentence(
          english: 'A hasty political decision could jeopardize the long-term peace process in the region.',
          turkish: 'Acelece alınmış bir siyasi karar, bölgedeki uzun vadeli barış sürecini tehlikeye atabilir.',
        ),
      ],
      collocations: ['jeopardize future/peace/success', 'put in jeopardy'],
      examTip: 'Paragraf sorularında "endanger" ile eşanlamlı olarak soru kökünde veya şıkta yer alır.',
    ),

    Word(
      id: 'v_exacerbate',
      word: 'exacerbate',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'kötüleştirmek, alevlendirmek, şiddetlendirmek',
      detailedMeaning: 'Mevcut bir sorunu, hastalığı veya gerginliği daha da vahim hale getirmek.',
      root: WordRoot(
        rootWord: 'acerbus (Lat.)',
        rootMeaning: 'acı, sert, keskin',
        explanation: 'Latince "ex-" (yoğunlaştırıcı) + "acerbus" (acı, sert) -> acılığı/sertliği katlamak.',
      ),
      derivatives: [
        WordDerivative(word: 'exacerbate', partOfSpeech: 'Fiil', meaning: 'kötüleştirmek, şiddetlendirmek'),
        WordDerivative(word: 'exacerbation', partOfSpeech: 'İsim', meaning: 'alevlenme, şiddetlenme, kriz'),
      ],
      synonyms: ['aggravate', 'worsen', 'intensify', 'inflame'],
      antonyms: ['mitigate', 'alleviate', 'soothe', 'improve'],
      examples: [
        ExampleSentence(
          english: 'High pollution levels can exacerbate chronic respiratory illnesses among elderly individuals.',
          turkish: 'Yüksek kirlilik seviyeleri, yaşlı bireyler arasındaki kronik solunum yolu hastalıklarını şiddetlendirebilir.',
        ),
      ],
      collocations: ['exacerbate the crisis/problem/symptoms', 'acute exacerbation'],
      examTip: 'ÖSYM "mitigate" (hafifletmek) kelimesinin zıt anlamlısı (antonym) olarak bu kelimeyi çok sever.',
    ),

    Word(
      id: 'v_scrutinize',
      word: 'scrutinize',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'dikkatle incelemek, didik didik etmek',
      detailedMeaning: 'Bir metni, veriyi veya şüpheli durumu en ince ayrıntısına kadar incelemek.',
      root: WordRoot(
        rootWord: 'scrutari (Lat.)',
        rootMeaning: 'arama yapmak, eşyaları didiklemek',
        explanation: 'Eski Roma’da hurdalar arasından değerli şey arama eylemidir; günümüzde derinlemesine inceleme anlamındadır.',
      ),
      derivatives: [
        WordDerivative(word: 'scrutinize', partOfSpeech: 'Fiil', meaning: 'dikkatle incelemek'),
        WordDerivative(word: 'scrutiny', partOfSpeech: 'İsim', meaning: 'yakın inceleme, denetim (under close scrutiny)'),
        WordDerivative(word: 'inscrutable', partOfSpeech: 'Sıfat', meaning: 'gizemli, anlaşılmaz, çözülemez'),
      ],
      synonyms: ['examine', 'inspect', 'investigate', 'probe', 'audit'],
      antonyms: ['ignore', 'overlook', 'neglect', 'disregard'],
      examples: [
        ExampleSentence(
          english: 'Scientists rigorously scrutinize historical documents to verify their authenticity.',
          turkish: 'Bilim insanları, özgünlüklerini doğrulamak için tarihi belgeleri titizlikle inceler.',
        ),
      ],
      collocations: ['closely scrutinize', 'rigorous scrutiny', 'come under scrutiny'],
      examTip: '"under close scrutiny" kalıbı YDS ve YÖKDİL Sosyal sınavlarında sıkça edat sorusu olarak karşımıza çıkar.',
    ),

    Word(
      id: 'v_curb',
      word: 'curb',
      type: WordType.verb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'dizginlemek, kontrol altına almak, sınırlamak',
      detailedMeaning: 'İstenmeyen bir artışı (enflasyon, emisyon, suç) kontrol altında tutmak.',
      root: WordRoot(
        rootWord: 'courber (Eski Fr.)',
        rootMeaning: 'bükmek, eğmek',
        explanation: 'Atların ağzına takılan gem/dizgin kayışından türemiştir; baskılayıp durdurmak anlamına gelir.',
      ),
      derivatives: [
        WordDerivative(word: 'curb', partOfSpeech: 'Fiil / İsim', meaning: 'frenlemek; kısıtlama, dizgin'),
      ],
      synonyms: ['restrain', 'restrict', 'control', 'limit', 'suppress'],
      antonyms: ['encourage', 'stimulate', 'promote', 'unleash'],
      examples: [
        ExampleSentence(
          english: 'Strict monetary policies were introduced in order to curb escalating inflation.',
          turkish: 'Tırmanan enflasyonu dizginlemek amacıyla sıkı para politikaları yürürlüğe kondu.',
        ),
      ],
      collocations: ['curb inflation', 'curb carbon emissions', 'curb the spread of virus'],
      examTip: 'Metin tamamlama ve çeviri sorularında "restrain" ve "control" karşılığı olarak verilir.',
    ),

    Word(
      id: 'v_induce',
      word: 'induce',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'tetiklemek, yol açmak, ikna etmek',
      detailedMeaning: 'Bir duruma, reaksiyona veya hastalığa sebep olmak ya da birini bir şeye ikna etmek.',
      root: WordRoot(
        rootWord: 'ducere (Lat.)',
        rootMeaning: 'yönlendirmek, çekmek',
        explanation: 'Latince "in-" (içeri) + "ducere" (yöneltmek) -> Bir fikre yöneltmek veya bir olayı harekete geçirmek.',
      ),
      derivatives: [
        WordDerivative(word: 'induce', partOfSpeech: 'Fiil', meaning: 'tetiklemek, neden olmak'),
        WordDerivative(word: 'inducement', partOfSpeech: 'İsim', meaning: 'teşvik, özendirici etken'),
        WordDerivative(word: 'inductive', partOfSpeech: 'Sıfat', meaning: 'tümevarımsal (mantık)'),
      ],
      synonyms: ['cause', 'trigger', 'provoke', 'lead to', 'prompt'],
      antonyms: ['prevent', 'hinder', 'inhibit', 'dissuade'],
      examples: [
        ExampleSentence(
          english: 'Certain synthetic medications may induce severe allergic reactions in sensitive patients.',
          turkish: 'Bazı sentetik ilaçlar, duyarlı hastalarda şiddetli alerjik reaksiyonları tetikleyebilir.',
        ),
      ],
      collocations: ['induce sleep/coma', 'drug-induced', 'induce someone to do sth'],
      examTip: 'YÖKDİL Sağlıkta "drug-induced" (ilacın tetiklediği) veya "induce symptoms" biçiminde çok çıkar.',
    ),

    // ---------------- ADJECTIVES (SIFATLAR) ----------------
    Word(
      id: 'adj_reluctant',
      word: 'reluctant',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'isteksiz, gönülsüz, tereddütlü',
      detailedMeaning: 'Bir şeyi yapmakta istek duymayan, çekingen davranan.',
      root: WordRoot(
        rootWord: 'luctari (Lat.)',
        rootMeaning: 'güreşmek, mücadele etmek',
        explanation: 'Latince "re-" (geri, karşı) + "luctari" (mücadele etmek) -> İçe karşı direnç göstermek, istememek.',
      ),
      derivatives: [
        WordDerivative(word: 'reluctant', partOfSpeech: 'Sıfat', meaning: 'isteksiz, gönülsüz'),
        WordDerivative(word: 'reluctance', partOfSpeech: 'İsim', meaning: 'isteksizlik, gönülsüzlük'),
        WordDerivative(word: 'reluctantly', partOfSpeech: 'Zarf', meaning: 'isteksizce, gönülsüz bir şekilde'),
      ],
      synonyms: ['unwilling', 'hesitant', 'loath', 'disinclined'],
      antonyms: ['willing', 'eager', 'keen', 'enthusiastic'],
      examples: [
        ExampleSentence(
          english: 'Many developing nations are reluctant to sign international carbon reduction treaties.',
          turkish: 'Gelişmekte olan birçok ulus, uluslararası karbon azaltma anlaşmalarını imzalamakta isteksizdir.',
        ),
      ],
      collocations: ['be reluctant to do sth', 'reluctant agreement', 'reluctant participant'],
      examTip: 'Arkasına mastar fiil alır: "be reluctant TO DO something". Zarf hali "reluctantly" olarak da çıkar.',
    ),

    Word(
      id: 'adj_indispensable',
      word: 'indispensable',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'vazgeçilmez, olmazsa olmaz, zorunlu',
      detailedMeaning: 'Onsuz var olunamayan veya işlemeyen temel bileşen.',
      root: WordRoot(
        rootWord: 'dispensare (Lat.)',
        rootMeaning: 'dağıtmak, muaf tutmak',
        explanation: 'in- (olumsuzluk eki) + dispense (vazgeçmek/muaf tutmak) + -able -> Vazgeçilemez, gözden çıkarılamaz.',
      ),
      derivatives: [
        WordDerivative(word: 'indispensable', partOfSpeech: 'Sıfat', meaning: 'vazgeçilmez'),
        WordDerivative(word: 'dispensable', partOfSpeech: 'Sıfat', meaning: 'gözden çıkarılabilir, fuzuli'),
        WordDerivative(word: 'dispense', partOfSpeech: 'Fiil', meaning: 'dağıtmak, ilaç vermek; -den feragat etmek'),
        WordDerivative(word: 'dispensation', partOfSpeech: 'İsim', meaning: 'bağışıklık, dağıtım'),
      ],
      synonyms: ['essential', 'vital', 'crucial', 'irreplaceable', 'imperative'],
      antonyms: ['dispensable', 'redundant', 'unnecessary', 'optional'],
      examples: [
        ExampleSentence(
          english: 'Clean potable water is an indispensable element for the survival of all living organisms.',
          turkish: 'Temiz içilebilir su, tüm canlı organizmaların hayatta kalması için vazgeçilmez bir unsurdur.',
        ),
      ],
      collocations: ['indispensable to/for', 'indispensable role/tool'],
      examTip: 'Preposition sorusu: "indispensable TO / FOR". Eş anlamlı olarak "vital" ve "crucial" gelir.',
    ),

    Word(
      id: 'adj_prevalent',
      word: 'prevalent',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'yaygın, hâkim, çok rastlanan',
      detailedMeaning: 'Belirli bir alanda veya dönemde geniş ölçüde var olan.',
      root: WordRoot(
        rootWord: 'valere (Lat.)',
        rootMeaning: 'güçlü olmak, geçerli olmak',
        explanation: 'Latince "prae-" (önce/üstün) + "valere" (güçlü olmak) -> Üstün gelen, baskın ve yaygın olan.',
      ),
      derivatives: [
        WordDerivative(word: 'prevalent', partOfSpeech: 'Sıfat', meaning: 'yaygın, hâkim'),
        WordDerivative(word: 'prevalence', partOfSpeech: 'İsim', meaning: 'yaygınlık (ör. disease prevalence)'),
        WordDerivative(word: 'prevail', partOfSpeech: 'Fiil', meaning: 'hüküm sürmek, üstün gelmek, yaygın olmak'),
        WordDerivative(word: 'prevailing', partOfSpeech: 'Sıfat', meaning: 'hâkim olan, geçerli (prevailing opinion)'),
      ],
      synonyms: ['widespread', 'common', 'rampant', 'predominant', 'ubiquitous'],
      antonyms: ['rare', 'scarce', 'uncommon', 'isolated'],
      examples: [
        ExampleSentence(
          english: 'Vitamin D deficiency is becoming increasingly prevalent among urban populations.',
          turkish: 'D vitamini eksikliği, kent nüfusları arasında giderek daha yaygın hale gelmektedir.',
        ),
      ],
      collocations: ['prevalent among/in', 'prevalence of diseases', 'prevailing attitude'],
      examTip: 'Sağlık bilimlerinde "the prevalence of disease" (hastalığın yaygınlığı) soru köklerinde sıkça geçer.',
    ),

    Word(
      id: 'adj_unprecedented',
      word: 'unprecedented',
      type: WordType.adjective,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'eşi benzeri görülmemiş, tarihte ilk kez yaşanan',
      detailedMeaning: 'Daha önce benzeri yaşanmamış, emsalsiz.',
      root: WordRoot(
        rootWord: 'cedere (Lat.)',
        rootMeaning: 'gitmek, adım atmak',
        explanation: 'un- (olumsuz) + pre- (önce) + cedere (gitmek) -> Öncesi olmayan, emsalsiz.',
      ),
      derivatives: [
        WordDerivative(word: 'precedent', partOfSpeech: 'İsim', meaning: 'emsal, geçmiş örnek'),
        WordDerivative(word: 'precede', partOfSpeech: 'Fiil', meaning: '-den önce gelmek'),
        WordDerivative(word: 'preceding', partOfSpeech: 'Sıfat', meaning: 'önceki, evvelki'),
        WordDerivative(word: 'unprecedented', partOfSpeech: 'Sıfat', meaning: 'eşi benzeri görülmemiş'),
      ],
      synonyms: ['unparalleled', 'unequaled', 'novel', 'groundbreaking', 'unheard-of'],
      antonyms: ['precedented', 'customary', 'ordinary', 'commonplace'],
      examples: [
        ExampleSentence(
          english: 'The sudden global pandemic led to an unprecedented collapse in international travel.',
          turkish: 'Ani küresel salgın, uluslararası seyahatte eşi benzeri görülmemiş bir çöküşe yol açtı.',
        ),
      ],
      collocations: ['unprecedented growth/crisis/scale', 'at an unprecedented rate'],
      examTip: 'ÖSYM okuma parçalarında "unparalleled" ve "unique" sözcükleriyle yeniden ifade edilir.',
    ),

    Word(
      id: 'adj_vulnerable',
      word: 'vulnerable',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'savunmasız, hassas, kırılgan, risk altında',
      detailedMeaning: 'Fiziksel ya da duygusal olarak saldırıya veya hasara açık.',
      root: WordRoot(
        rootWord: 'vulnus (Lat.)',
        rootMeaning: 'yara, bere',
        explanation: 'Latince "vulnus" (yara) sözünden türetilmiştir: Kolayca yaralanabilir, incinebilir.',
      ),
      derivatives: [
        WordDerivative(word: 'vulnerable', partOfSpeech: 'Sıfat', meaning: 'savunmasız, hassas'),
        WordDerivative(word: 'vulnerability', partOfSpeech: 'İsim', meaning: 'hassasiyet, savunmasızlık'),
        WordDerivative(word: 'invulnerable', partOfSpeech: 'Sıfat', meaning: 'zarar görmez, yenilmez'),
      ],
      synonyms: ['susceptible', 'defenseless', 'exposed', 'prone', 'fragile'],
      antonyms: ['immune', 'protected', 'resilient', 'shielded'],
      examples: [
        ExampleSentence(
          english: 'Coastal cities are particularly vulnerable to rising sea levels caused by global warming.',
          turkish: 'Kıyı kentleri, küresel ısınmanın yol açtığı deniz seviyesindeki yükselmelere karşı bilhassa savunmasızdır.',
        ),
      ],
      collocations: ['vulnerable to attack/disease', 'vulnerable groups', 'climate vulnerability'],
      examTip: 'Preposition kuralı: "vulnerable TO" (savunmasız) ve "susceptible TO" (açık, duyarlı) ayrılmaz ikilidir.',
    ),

    Word(
      id: 'adj_plausible',
      word: 'plausible',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'akla yatkın, makul, inandırıcı',
      detailedMeaning: 'Doğru veya gerçekleşmesi muhtemel görünen sav, açıklama veya teori.',
      root: WordRoot(
        rootWord: 'plaudere (Lat.)',
        rootMeaning: 'alkışlamak, onaylamak',
        explanation: 'Dinlendiğinde alkışlanası, kulağa doğru ve inandırıcı gelen.',
      ),
      derivatives: [
        WordDerivative(word: 'plausible', partOfSpeech: 'Sıfat', meaning: 'akla yatkın, mantıklı'),
        WordDerivative(word: 'plausibility', partOfSpeech: 'İsim', meaning: 'akla yatkınlık, inandırıcılık'),
        WordDerivative(word: 'implausible', partOfSpeech: 'Sıfat', meaning: 'akıl almaz, inanılması güç'),
        WordDerivative(word: 'plausibly', partOfSpeech: 'Zarf', meaning: 'akla yatkın şekilde'),
      ],
      synonyms: ['credible', 'believable', 'reasonable', 'feasible', 'convincing'],
      antonyms: ['implausible', 'unbelievable', 'unlikely', 'ridiculous'],
      examples: [
        ExampleSentence(
          english: 'The biologist proposed a plausible explanation for the unexpected mutation in the sample.',
          turkish: 'Biyolog, numunedeki beklenmedik mutasyon için akla yatkın bir açıklama önerdi.',
        ),
      ],
      collocations: ['plausible explanation/theory/alternative', 'highly plausible'],
      examTip: 'Seçeneklerde zıttı olan "implausible" (akla yatkın olmayan) ile de test edilir.',
    ),

    Word(
      id: 'adj_lucrative',
      word: 'lucrative',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'kârlı, kazançlı, bol getiri sağlayan',
      detailedMeaning: 'Büyük miktarda para veya kazanç üreten iş/sektör.',
      root: WordRoot(
        rootWord: 'lucrum (Lat.)',
        rootMeaning: 'kazanç, kâr',
        explanation: 'Latince servet ve kâr ifade eden "lucrum" kelimesinden türemiştir.',
      ),
      derivatives: [
        WordDerivative(word: 'lucrative', partOfSpeech: 'Sıfat', meaning: 'kârlı, kazançlı'),
        WordDerivative(word: 'lucratively', partOfSpeech: 'Zarf', meaning: 'kazançlı şekilde'),
      ],
      synonyms: ['profitable', 'rewarding', 'gainful', 'money-making'],
      antonyms: ['unprofitable', 'loss-making', 'unremunerative'],
      examples: [
        ExampleSentence(
          english: 'Investing in renewable energy has proven to be a highly lucrative venture in recent years.',
          turkish: 'Yenilenebilir enerjiye yatırım yapmanın son yıllarda oldukça kârlı bir girişim olduğu kanıtlandı.',
        ),
      ],
      collocations: ['lucrative business/market/contract', 'highly lucrative'],
      examTip: '"profitable" kelimesinin C1 akademik muadili olarak sıklıkla şıklarda karşımıza çıkar.',
    ),

    // ---------------- NOUNS (İSİMLER) ----------------
    Word(
      id: 'n_disparity',
      word: 'disparity',
      type: WordType.noun,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'farklılık, uçurum, eşitsizlik, denksizlik',
      detailedMeaning: 'Özellikle gelir, statü veya sağlık alanlarında adil olmayan belirgin fark.',
      root: WordRoot(
        rootWord: 'par (Lat.)',
        rootMeaning: 'eşit, denk',
        explanation: 'dis- (ayrılık, olumsuzluk) + par (eşitlik) -> Eşit olmama hali, derin uçurum.',
      ),
      derivatives: [
        WordDerivative(word: 'disparity', partOfSpeech: 'İsim', meaning: 'farklılık, eşitsizlik'),
        WordDerivative(word: 'parity', partOfSpeech: 'İsim', meaning: 'denklik, eşitlik (ör. purchasing power parity)'),
        WordDerivative(word: 'disparate', partOfSpeech: 'Sıfat', meaning: 'bambaşka, apayrı, tamamen farklı'),
      ],
      synonyms: ['discrepancy', 'inequality', 'gap', 'imbalance', 'divergence'],
      antonyms: ['parity', 'equality', 'similarity', 'uniformity'],
      examples: [
        ExampleSentence(
          english: 'There is a growing economic disparity between industrial urban regions and rural areas.',
          turkish: 'Sanayileşmiş kentsel bölgeler ile kırsal alanlar arasında büyüyen bir ekonomik uçurum bulunmaktadır.',
        ),
      ],
      collocations: ['income/wealth disparity', 'disparity between', 'wide disparity'],
      examTip: 'ÖSYM sınavlarında "gap" veya "inequality" kelimelerinin akademik metinlerdeki tam karşılığıdır.',
    ),

    Word(
      id: 'n_depletion',
      word: 'depletion',
      type: WordType.noun,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'tükenme, boşalma, azalma',
      detailedMeaning: 'Kaynakların, rezervlerin veya doğal varlıkların hızla bitmesi.',
      root: WordRoot(
        rootWord: 'plere (Lat.)',
        rootMeaning: 'doldurmak',
        explanation: 'de- (tersine çevirme) + plere (doldurmak) -> Dolu olanı boşaltmak, tüketmek.',
      ),
      derivatives: [
        WordDerivative(word: 'deplete', partOfSpeech: 'Fiil', meaning: 'tüketmek, bitirmek'),
        WordDerivative(word: 'depletion', partOfSpeech: 'İsim', meaning: 'tükenme, azalma'),
        WordDerivative(word: 'depleted', partOfSpeech: 'Sıfat', meaning: 'tükenmiş, boşalmış'),
      ],
      synonyms: ['exhaustion', 'drain', 'reduction', 'consumption'],
      antonyms: ['replenishment', 'restoration', 'accumulation'],
      examples: [
        ExampleSentence(
          english: 'The rapid depletion of groundwater reserves poses an imminent threat to regional agriculture.',
          turkish: 'Yeraltı su rezervlerinin hızla tükenmesi, bölgesel tarım için yakın bir tehdit oluşturmaktadır.',
        ),
      ],
      collocations: ['ozone layer depletion', 'depletion of natural resources', 'soil depletion'],
      examTip: 'Fen Bilimleri çevre paragraflarında "ozone depletion" veya "depletion of fossil fuels" kalıplarında görülür.',
    ),

    Word(
      id: 'n_feasibility',
      word: 'feasibility',
      type: WordType.noun,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'yapılabilirlik, uygulanabilirlik, fizibilite',
      detailedMeaning: 'Bir projenin, planın ya da yöntemin pratikte başarıyla uygulanabilir olma durumu.',
      root: WordRoot(
        rootWord: 'facere (Lat.)',
        rootMeaning: 'yapmak, meydana getirmek',
        explanation: 'Latince "facere" -> yapılabilir (feasible) -> yapılabilirlik (feasibility).',
      ),
      derivatives: [
        WordDerivative(word: 'feasible', partOfSpeech: 'Sıfat', meaning: 'uygulanabilir, pratik'),
        WordDerivative(word: 'feasibility', partOfSpeech: 'İsim', meaning: 'yapılabilirlik, fizibilite'),
        WordDerivative(word: 'feasibly', partOfSpeech: 'Zarf', meaning: 'uygulanabilir biçimde'),
        WordDerivative(word: 'unfeasible', partOfSpeech: 'Sıfat', meaning: 'uygulanamaz, imkansız'),
      ],
      synonyms: ['viability', 'practicability', 'workability', 'possibility'],
      antonyms: ['unfeasibility', 'impracticability', 'impossibility'],
      examples: [
        ExampleSentence(
          english: 'Engineers conducted a comprehensive feasibility study before starting the high-speed rail project.',
          turkish: 'Mühendisler, yüksek hızlı tren projesine başlamadan önce kapsamlı bir fizibilite çalışması yürüttüler.',
        ),
      ],
      collocations: ['feasibility study', 'economic feasibility', 'assess the feasibility of'],
      examTip: '"feasibility study" (fizibilite/uygulanabilirlik araştırması) kalıbı doğrudan isim tamlaması olarak sorulur.',
    ),

    Word(
      id: 'n_coincidence',
      word: 'coincidence',
      type: WordType.noun,
      level: 'B2 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'tesadüf, rastlantı, aynı ana denk gelme',
      detailedMeaning: 'Görünürde nedensel bağ olmadan iki olayın aynı anda meydana gelmesi.',
      root: WordRoot(
        rootWord: 'cidere / cadere (Lat.)',
        rootMeaning: 'düşmek, meydana gelmek',
        explanation: 'co- (birlikte) + in- + cadere (düşmek) -> İki olayın aynı noktaya/zamana birlikte denk düşmesi.',
      ),
      derivatives: [
        WordDerivative(word: 'coincide', partOfSpeech: 'Fiil', meaning: 'aynı zamana rastlamak, örtüşmek (- with)'),
        WordDerivative(word: 'coincidence', partOfSpeech: 'İsim', meaning: 'tesadüf, rastlantı'),
        WordDerivative(word: 'coincidental', partOfSpeech: 'Sıfat', meaning: 'tesadüfi, rastlantısal'),
        WordDerivative(word: 'coincidentally', partOfSpeech: 'Zarf', meaning: 'tesadüfen, şans eseri'),
      ],
      synonyms: ['chance', 'fluke', 'serendipity', 'accident'],
      antonyms: ['design', 'intention', 'plan', 'deliberation'],
      examples: [
        ExampleSentence(
          english: 'It was mere coincidence that the discovery was made on the exact same day in two different laboratories.',
          turkish: 'Keşfin iki farklı laboratuvarda tamı tamına aynı günde yapılmış olması sadece bir tesadüftü.',
        ),
      ],
      collocations: ['by coincidence', 'pure/mere coincidence', 'coincide with'],
      examTip: 'Fiil hali "coincide WITH" olarak edat sorularında en çok çıkan fiiller arasındadır.',
    ),

    // ---------------- ADVERBS (ZARFLAR) ----------------
    Word(
      id: 'adv_adversely',
      word: 'adversely',
      type: WordType.adverb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'olumsuz yönde, zararına, aksi şekilde',
      detailedMeaning: 'Bir durumu kötü etkileyecek biçimde.',
      root: WordRoot(
        rootWord: 'vertere (Lat.)',
        rootMeaning: 'dönmek, çevirmek',
        explanation: 'ad- (karşı) + vertere (dönmek) -> Karşı yöne dönük, hasmane, aleyhte.',
      ),
      derivatives: [
        WordDerivative(word: 'adverse', partOfSpeech: 'Sıfat', meaning: 'olumsuz, aleyhte (adverse effects)'),
        WordDerivative(word: 'adversely', partOfSpeech: 'Zarf', meaning: 'olumsuz biçimde (adversely affect)'),
        WordDerivative(word: 'adversity', partOfSpeech: 'İsim', meaning: 'sıkıntı, güçlük, felaket'),
        WordDerivative(word: 'adversary', partOfSpeech: 'İsim', meaning: 'hasım, rakip, düşman'),
      ],
      synonyms: ['negatively', 'detrimentally', 'unfavorably', 'harmfully'],
      antonyms: ['favorably', 'beneficially', 'positively', 'advantageously'],
      examples: [
        ExampleSentence(
          english: 'Prolonged sleep deprivation can adversely affect both cognitive performance and immune function.',
          turkish: 'Uzun süreli uyku yoksunluğu hem bilişsel performansı hem de bağışıklık fonksiyonunu olumsuz yönde etkileyebilir.',
        ),
      ],
      collocations: ['adversely affect/impact', 'adverse reaction', 'in the face of adversity'],
      examTip: 'ÖSYM soru kalıbı: "adversely affect" (olumsuz etkilemek). Neredeyse her yıl en az bir soruda test edilir!',
    ),

    Word(
      id: 'adv_substantially',
      word: 'substantially',
      type: WordType.adverb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'önemli ölçüde, büyük oranda, esasen',
      detailedMeaning: 'Miktar veya derece bakımından kayda değer büyüklükte.',
      root: WordRoot(
        rootWord: 'substantia (Lat.)',
        rootMeaning: 'öz, varlık, madde',
        explanation: 'sub- (altında) + stare (durmak) -> Bir şeyin temelinde duran asıl madde/öz; esaslı oluş.',
      ),
      derivatives: [
        WordDerivative(word: 'substance', partOfSpeech: 'İsim', meaning: 'madde; öz, içerik'),
        WordDerivative(word: 'substantial', partOfSpeech: 'Sıfat', meaning: 'kayda değer, önemli miktarda'),
        WordDerivative(word: 'substantially', partOfSpeech: 'Zarf', meaning: 'önemli ölçüde, büyük oranda'),
        WordDerivative(word: 'substantiate', partOfSpeech: 'Fiil', meaning: 'kanıtlamak, doğrulamak, somutlaştırmak'),
      ],
      synonyms: ['significantly', 'considerably', 'markedly', 'greatly', 'drastically'],
      antonyms: ['insignificantly', 'slightly', 'marginally', 'negligibly'],
      examples: [
        ExampleSentence(
          english: 'Adopting modern irrigation methods substantially reduced water consumption in the farming valley.',
          turkish: 'Modern sulama yöntemlerinin benimsenmesi, tarım vadisindeki su tüketimini önemli ölçüde azalttı.',
        ),
      ],
      collocations: ['substantially increase/decrease', 'substantially different', 'substantial evidence'],
      examTip: 'Artış veya azalış bildiren fiillerle (increase, decrease, reduce) "substantially" ve "considerably" birlikte kullanılır.',
    ),

    Word(
      id: 'adv_inevitably',
      word: 'inevitably',
      type: WordType.adverb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'kaçınılmaz olarak, ister istemez, er ya da geç',
      detailedMeaning: 'Engellenmesi ya da önlenmesi imkansız bir biçimde.',
      root: WordRoot(
        rootWord: 'evitare (Lat.)',
        rootMeaning: 'kaçınmak, savuşturmak',
        explanation: 'in- (olumsuz) + ex- (dışarı) + vitare (kaçmak) -> Kaçılması mümkün olmayan biçimde.',
      ),
      derivatives: [
        WordDerivative(word: 'inevitable', partOfSpeech: 'Sıfat', meaning: 'kaçınılmaz'),
        WordDerivative(word: 'inevitability', partOfSpeech: 'İsim', meaning: 'kaçınılmazlık'),
        WordDerivative(word: 'inevitably', partOfSpeech: 'Zarf', meaning: 'kaçınılmaz olarak'),
      ],
      synonyms: ['unavoidably', 'inescapably', 'necessarily', 'surely'],
      antonyms: ['avoidably', 'preventably', 'uncertainly'],
      examples: [
        ExampleSentence(
          english: 'The rapid depletion of non-renewable fossil fuels will inevitably accelerate the shift toward solar power.',
          turkish: 'Yenilenemez fosil yakıtların hızla tükenmesi, güneş enerjisine geçişi kaçınılmaz olarak hızlandıracaktır.',
        ),
      ],
      collocations: ['inevitably lead to', 'inevitably result in'],
      examTip: '"inevitably lead to" kalıbı sonuç cümlelerinde ÖSYM paragraf ve cümle tamamlama sorularının anahtarıdır.',
    ),

    // ---------------- PHRASAL VERBS (DEYİMSEL FİİLLER) ----------------
    Word(
      id: 'phr_stem_from',
      word: 'stem from',
      type: WordType.phrasalVerb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: '-den kaynaklanmak, ileri gelmek, kökenini almak',
      detailedMeaning: 'Bir durumun, sorunun veya olgunun temel sebebinin başka bir şey olması.',
      root: WordRoot(
        rootWord: 'stem (Germen)',
        rootMeaning: 'ağaç gövdesi, dal, sap',
        explanation: 'Bir ağacın dallarının ana gövdeden (stem) fışkırması benzetmesinden doğmuştur.',
      ),
      derivatives: [
        WordDerivative(word: 'stem from', partOfSpeech: 'Phrasal Verb', meaning: '-den ileri gelmek'),
        WordDerivative(word: 'stem', partOfSpeech: 'Fiil', meaning: 'akışı durdurmak, önünü kesmek (stem the bleeding)'),
        WordDerivative(word: 'stem', partOfSpeech: 'İsim', meaning: 'bitki sapı; kök; kök hücre (stem cell)'),
      ],
      synonyms: ['originate from', 'derive from', 'arise from', 'emanate from'],
      antonyms: ['result in', 'lead to', 'culminate in'],
      examples: [
        ExampleSentence(
          english: 'Most contemporary psychological anxieties stem from overwhelming social pressure and burnout.',
          turkish: 'Çağdaş psikolojik kaygıların çoğu, ezici toplumsal baskı ve tükenmişlikten kaynaklanmaktadır.',
        ),
      ],
      collocations: ['stem from childhood', 'problems stem from', 'stem cell research'],
      examTip: 'Sebep-sonuç ilişkisinde "stem from" = kaynaklanmak (sebep arkadan gelir). "result in" = sebep olmak (sonuç arkadan gelir). Bu fark ÖSYM’de hayat kurtarır!',
    ),

    Word(
      id: 'phr_bring_about',
      word: 'bring about',
      type: WordType.phrasalVerb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'sebep olmak, yol açmak, beraberinde getirmek',
      detailedMeaning: 'Büyük çaplı bir değişimin ya da olayın gerçekleşmesini sağlamak.',
      root: WordRoot(
        rootWord: 'bring + about',
        rootMeaning: 'çevresine taşımak, meydana çıkarmak',
        explanation: 'Eski İngilizce hareket ve dönüşüm edatlarının birleşimiyle köklü değişime yol açma anlamı kazanmıştır.',
      ),
      derivatives: [
        WordDerivative(word: 'bring about', partOfSpeech: 'Phrasal Verb', meaning: 'yol açmak, meydana getirmek'),
      ],
      synonyms: ['cause', 'lead to', 'trigger', 'give rise to', 'induce', 'engender'],
      antonyms: ['prevent', 'halt', 'impede'],
      examples: [
        ExampleSentence(
          english: 'The industrial revolution brought about fundamental transformations in manufacturing and society.',
          turkish: 'Sanayi devrimi, üretimde ve toplumda köklü dönüşümlere yol açtı.',
        ),
      ],
      collocations: ['bring about change', 'bring about revolution', 'bring about collapse'],
      examTip: 'YDS 1-6. sorular arasındaki klasik Phrasal Verb sorularının vazgeçilmez favorisidir. "cause" ve "lead to" eş anlamlısıdır.',
    ),

    Word(
      id: 'phr_cope_with',
      word: 'cope with',
      type: WordType.phrasalVerb,
      level: 'B2 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'başa çıkmak, üstesinden gelmek, idare etmek',
      detailedMeaning: 'Zorlu bir problemle ya da stresle başarılı şekilde mücadele etmek.',
      root: WordRoot(
        rootWord: 'colpus / coup (Eski Fr.)',
        rootMeaning: 'yumruklaşmak, darbeleşmek',
        explanation: 'Zorluklarla göğüs göğüse çarpışıp ayakta kalma mecazından türemiştir.',
      ),
      derivatives: [
        WordDerivative(word: 'cope with', partOfSpeech: 'Phrasal Verb', meaning: 'başa çıkmak'),
        WordDerivative(word: 'coping mechanism', partOfSpeech: 'İsim', meaning: 'başa çıkma mekanizması'),
      ],
      synonyms: ['deal with', 'handle', 'manage', 'tackle', 'overcome'],
      antonyms: ['succumb to', 'surrender', 'fail'],
      examples: [
        ExampleSentence(
          english: 'Many hospitals in developing countries struggled to cope with the unprecedented influx of patients.',
          turkish: 'Gelişmekte olan ülkelerdeki birçok hastane, eşi görülmemiş hasta akınıyla başa çıkmakta zorlandı.',
        ),
      ],
      collocations: ['cope with stress', 'cope with difficulty', 'coping strategy'],
      examTip: 'Preposition sorusu: "cope ... with". Şıklarda "deal with" ve "handle" ile eşleştirilir.',
    ),

    Word(
      id: 'phr_compensate_for',
      word: 'compensate for',
      type: WordType.phrasalVerb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'telafi etmek, bedelini karşılamak, dengelemek',
      detailedMeaning: 'Eksik veya zararlı bir durumu başka bir iyilikle dengelemek.',
      root: WordRoot(
        rootWord: 'compensare (Lat.)',
        rootMeaning: 'birlikte tartmak, dengelemek',
        explanation: 'Terazinin iki kefesini denk hale getirmek; eksilen tarafı tamamlamak.',
      ),
      derivatives: [
        WordDerivative(word: 'compensate for', partOfSpeech: 'Phrasal Verb', meaning: 'telafi etmek'),
        WordDerivative(word: 'compensation', partOfSpeech: 'İsim', meaning: 'tazminat, telafi'),
        WordDerivative(word: 'compensatory', partOfSpeech: 'Sıfat', meaning: 'tazmin edici, dengeleyici'),
      ],
      synonyms: ['make up for', 'offset', 'balance out', 'recompense'],
      antonyms: ['deprive', 'damage', 'worsen'],
      examples: [
        ExampleSentence(
          english: 'The company offered bonus shares to compensate for the significant financial losses suffered by investors.',
          turkish: 'Şirket, yatırımcıların maruz kaldığı önemli mali kayıpları telafi etmek için prim hisseleri teklif etti.',
        ),
      ],
      collocations: ['compensate for losses', 'financial compensation', 'compensatory mechanism'],
      examTip: '"make up for" ile tamamen birebir eş anlamlıdır. Preposition sorularında "FOR" aranır.',
    ),

    Word(
      id: 'phr_culminate_in',
      word: 'culminate in',
      type: WordType.phrasalVerb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'ile sonuçlanmak, zirveye ulaşmak, ile noktalanmak',
      detailedMeaning: 'Bir dizi olayın doruk noktasına ulaşarak belirli bir nihai sonuca varması.',
      root: WordRoot(
        rootWord: 'culmen (Lat.)',
        rootMeaning: 'doruk, tepe, zirve',
        explanation: 'Dağın zirvesine (culmen) varmak -> Sürecin doruk noktada nihayet bulması.',
      ),
      derivatives: [
        WordDerivative(word: 'culminate in', partOfSpeech: 'Phrasal Verb', meaning: 'ile noktalanmak'),
        WordDerivative(word: 'culmination', partOfSpeech: 'İsim', meaning: 'doruk noktası, zirve, nihai sonuç'),
      ],
      synonyms: ['result in', 'end in', 'climax in', 'lead up to'],
      antonyms: ['commence with', 'originate in', 'start with'],
      examples: [
        ExampleSentence(
          english: 'Months of diplomatic negotiations finally culminated in a historic bilateral peace treaty.',
          turkish: 'Aylarca süren diplomatik müzakereler nihayet tarihi bir ikili barış anlaşmasıyla noktalandı.',
        ),
      ],
      collocations: ['culminate in success', 'culminate in victory/crisis', 'the culmination of years of work'],
      examTip: 'Preposition sorusu olarak "IN" edatı ile sıklıkla sorulur: "culminate IN".',
    ),

    // ---------------- MORE HIGH FREQUENCY WORDS ----------------
    Word(
      id: 'adj_coherent',
      word: 'coherent',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'tutarlı, mantıklı, birbiriyle uyumlu',
      detailedMeaning: 'Fikirleri, parçaları birbiriyle ahenkli ve mantıksal bütünlük içinde olan.',
      root: WordRoot(
        rootWord: 'haerere (Lat.)',
        rootMeaning: 'yapışmak, birbirine tutunmak',
        explanation: 'co- (birlikte) + haerere (yapışmak) -> Birbiriyle sıkıca kenetlenen, mantık bağı kopmayan.',
      ),
      derivatives: [
        WordDerivative(word: 'coherent', partOfSpeech: 'Sıfat', meaning: 'tutarlı, mantıklı'),
        WordDerivative(word: 'coherence', partOfSpeech: 'İsim', meaning: 'tutarlılık, ahenk'),
        WordDerivative(word: 'incoherent', partOfSpeech: 'Sıfat', meaning: 'tutarsız, kopuk, anlamsız'),
        WordDerivative(word: 'cohere', partOfSpeech: 'Fiil', meaning: 'birbirine yapışmak, tutarlı olmak'),
      ],
      synonyms: ['logical', 'consistent', 'lucid', 'rational', 'well-structured'],
      antonyms: ['incoherent', 'illogical', 'disjointed', 'confused'],
      examples: [
        ExampleSentence(
          english: 'The author failed to present a coherent argument in favor of the radical economic reform.',
          turkish: 'Yazar, radikal ekonomik reform lehine tutarlı bir sav sunmayı başaramadı.',
        ),
      ],
      collocations: ['coherent strategy', 'coherent explanation', 'lack of coherence'],
      examTip: 'ÖSYM İngilizce paragraf bütünlüğünü bozan cümleyi bulma sorularında "lack of coherence" (tutarlılık eksikliği) esastır.',
    ),

    Word(
      id: 'v_reinforce',
      word: 'reinforce',
      type: WordType.verb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'güçlendirmek, takviye etmek, pekiştirmek',
      detailedMeaning: 'Bir yapıyı, orduyu veya argümanı daha güçlü hale getirmek.',
      root: WordRoot(
        rootWord: 'fortis (Lat.)',
        rootMeaning: 'güçlü, kuvvetli',
        explanation: 're- (tekrar) + in- + fortis (güçlü kılmak) -> Yeniden sağlamlaştırmak, pekiştirmek.',
      ),
      derivatives: [
        WordDerivative(word: 'reinforce', partOfSpeech: 'Fiil', meaning: 'güçlendirmek, pekiştirmek'),
        WordDerivative(word: 'reinforcement', partOfSpeech: 'İsim', meaning: 'takviye, pekiştirme, güçlendirme'),
      ],
      synonyms: ['strengthen', 'fortify', 'bolster', 'consolidate', 'support'],
      antonyms: ['weaken', 'undermine', 'diminish'],
      examples: [
        ExampleSentence(
          english: 'Recent archaeological findings strongly reinforce the theory that ancient trade routes were interconnected.',
          turkish: 'Son arkeolojik bulgular, antik ticaret yollarının birbiriyle bağlantılı olduğu teorisini güçlü bir şekilde pekiştirmektedir.',
        ),
      ],
      collocations: ['reinforce beliefs', 'positive reinforcement', 'reinforce the structure'],
      examTip: 'Akademik metinlerde sıklıkla "bolster" ve "strengthen" eş anlamlılarıyla test edilir.',
    ),

    Word(
      id: 'v_relinquish',
      word: 'relinquish',
      type: WordType.verb,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'feragat etmek, bırakmak, vazgeçmek',
      detailedMeaning: 'Bir hak, taht, yetki veya iddiadan gönüllü veya zoraki vazgeçmek.',
      root: WordRoot(
        rootWord: 'linquere (Lat.)',
        rootMeaning: 'bırakmak, terk etmek',
        explanation: 're- (geri) + linquere (bırakmak) -> Geriye bırakıp çekilmek.',
      ),
      derivatives: [
        WordDerivative(word: 'relinquish', partOfSpeech: 'Fiil', meaning: 'vazgeçmek, feragat etmek'),
        WordDerivative(word: 'relinquishment', partOfSpeech: 'İsim', meaning: 'feragat, vazgeçiş'),
      ],
      synonyms: ['abandon', 'surrender', 'give up', 'renounce', 'yield'],
      antonyms: ['retain', 'maintain', 'keep', 'claim'],
      examples: [
        ExampleSentence(
          english: 'The aging monarch agreed to relinquish his crown in favor of his eldest son.',
          turkish: 'Yaşlanan hükümdar, en büyük oğlunun lehine tacından feragat etmeyi kabul etti.',
        ),
      ],
      collocations: ['relinquish power/control', 'relinquish rights'],
      examTip: '"give up" phrasal verb’ünün üst düzey akademik (C1) fiil karşılığıdır.',
    ),

    Word(
      id: 'adj_ambiguous',
      word: 'ambiguous',
      type: WordType.adjective,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'belirsiz, muğlak, birden fazla anlama gelebilen',
      detailedMeaning: 'Açık ve net olmayan, çift anlam barındıran ifade veya durum.',
      root: WordRoot(
        rootWord: 'ambi (Lat.)',
        rootMeaning: 'her iki taraf, ikili',
        explanation: 'ambi (iki yönlü) + agere (sürmek) -> İki tarafa da çekilebilen, net olmayan.',
      ),
      derivatives: [
        WordDerivative(word: 'ambiguous', partOfSpeech: 'Sıfat', meaning: 'belirsiz, muğlak'),
        WordDerivative(word: 'ambiguity', partOfSpeech: 'İsim', meaning: 'muğlaklık, belirsizlik'),
        WordDerivative(word: 'unambiguous', partOfSpeech: 'Sıfat', meaning: 'açık, net, kesin'),
        WordDerivative(word: 'ambiguously', partOfSpeech: 'Zarf', meaning: 'muğlak bir şekilde'),
      ],
      synonyms: ['vague', 'unclear', 'obscure', 'equivocal', 'doubtful'],
      antonyms: ['clear', 'lucid', 'unambiguous', 'explicit', 'definite'],
      examples: [
        ExampleSentence(
          english: 'The legal wording in the contract was intentionally left ambiguous by the negotiators.',
          turkish: 'Sözleşmedeki hukuki ifade, müzakereciler tarafından kasıtlı olarak muğlak bırakılmıştı.',
        ),
      ],
      collocations: ['ambiguous statement', 'moral ambiguity', 'avoid ambiguity'],
      examTip: 'Zıttı olan "unambiguous" ve "explicit" (açık, net) kelimeleriyle birlikte ezberlenmelidir.',
    ),

    Word(
      id: 'v_diminish',
      word: 'diminish',
      type: WordType.verb,
      level: 'B2-C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Fen', 'YÖKDİL Sosyal', 'Son 15 Yıl'],
      meaning: 'azalmak, eksilmek, önemini yitirmek',
      detailedMeaning: 'Boyut, güç veya değer bakımından küçülmek veya küçültmek.',
      root: WordRoot(
        rootWord: 'minuere (Lat.)',
        rootMeaning: 'küçültmek, azaltmak (minor)',
        explanation: 'Latince "minus" ve "minor" (küçük, az) kökünden gelir; küçültmek, azaltmak.',
      ),
      derivatives: [
        WordDerivative(word: 'diminish', partOfSpeech: 'Fiil', meaning: 'azalmak, eksiltmek'),
        WordDerivative(word: 'diminishing', partOfSpeech: 'Sıfat', meaning: 'azalan (diminishing returns)'),
        WordDerivative(word: 'diminution', partOfSpeech: 'İsim', meaning: 'azalma, eksilme'),
      ],
      synonyms: ['decrease', 'reduce', 'lessen', 'shrink', 'dwindle'],
      antonyms: ['increase', 'grow', 'expand', 'augment'],
      examples: [
        ExampleSentence(
          english: 'The country’s diplomatic influence began to diminish after the economic collapse.',
          turkish: 'Ekonomik çöküşün ardından ülkenin diplomatik nüfuzu azalmaya başladı.',
        ),
      ],
      collocations: ['law of diminishing returns', 'diminish influence', 'rapidly diminish'],
      examTip: 'Ekonomi metinlerinde "the law of diminishing returns" (azalan verimler kanunu) kalıbı sıkça çıkar.',
    ),

    Word(
      id: 'adj_paramount',
      word: 'paramount',
      type: WordType.adjective,
      level: 'C1 (YDS / YÖKDİL)',
      tags: ['YDS', 'YÖKDİL Sağlık', 'YÖKDİL Fen', 'Son 15 Yıl'],
      meaning: 'son derece önemli, en üstün, her şeyden önce gelen',
      detailedMeaning: 'Diğer her şeyden daha fazla önem veya önceliğe sahip olan.',
      root: WordRoot(
        rootWord: 'amont (Eski Fr.)',
        rootMeaning: 'yukarıda, dağın tepesinde',
        explanation: 'par (ötesinde) + amont (yukarıda) -> Her şeyin en tepesinde duran, en mühim olan.',
      ),
      derivatives: [
        WordDerivative(word: 'paramount', partOfSpeech: 'Sıfat', meaning: 'en üstün, hayati önemde'),
      ],
      synonyms: ['supreme', 'foremost', 'vital', 'predominant', 'primary'],
      antonyms: ['minor', 'secondary', 'trivial', 'negligible'],
      examples: [
        ExampleSentence(
          english: 'Ensuring passenger safety is of paramount importance in the design of commercial aircraft.',
          turkish: 'Yolcu güvenliğini sağlamak, ticari uçakların tasarımında son derece büyük bir öneme sahiptir.',
        ),
      ],
      collocations: ['of paramount importance', 'paramount concern'],
      examTip: '"of paramount importance" kalıbı = "of vital importance" = çok mühim.',
    ),
  ];

  /// Get list of all distinct roots with their associated word family members
  static List<Map<String, dynamic>> getWordFamilies() {
    return [
      {
        'root': 'MITIS / AGERE (Yatıştırmak, Hafifletmek)',
        'description': 'Zararı, acıyı veya cezayı yumuşatma kökü',
        'family': [
          {'word': 'mitigate', 'pos': 'Fiil', 'tr': 'hafifletmek, azaltmak'},
          {'word': 'mitigation', 'pos': 'İsim', 'tr': 'hafifletme, azaltım eylemi'},
          {'word': 'mitigating', 'pos': 'Sıfat', 'tr': 'hafifletici (etken, durum)'},
          {'word': 'unmitigated', 'pos': 'Sıfat', 'tr': 'hafifletilmemiş, tam, mutlak'},
        ]
      },
      {
        'root': 'PRAE-VALERE (Üstün Gelmek, Yaygın Olmak)',
        'description': 'Gücünü ve hâkimiyetini kabul ettirerek her yere yayılma kökü',
        'family': [
          {'word': 'prevail', 'pos': 'Fiil', 'tr': 'üstün gelmek, hüküm sürmek'},
          {'word': 'prevalent', 'pos': 'Sıfat', 'tr': 'yaygın, hâkim, çok rastlanan'},
          {'word': 'prevalence', 'pos': 'İsim', 'tr': 'yaygınlık (hastalık, eğilim)'},
          {'word': 'prevailing', 'pos': 'Sıfat', 'tr': 'hâlihazırda geçerli olan'},
        ]
      },
      {
        'root': 'LUCTARI (Direnç Göstermek, Çekimser Kalmak)',
        'description': 'İçsel bir isteksizlik ve çekince bildiren kök',
        'family': [
          {'word': 'reluctant', 'pos': 'Sıfat', 'tr': 'isteksiz, gönülsüz, tereddütlü'},
          {'word': 'reluctance', 'pos': 'İsim', 'tr': 'isteksizlik, çekingenlik'},
          {'word': 'reluctantly', 'pos': 'Zarf', 'tr': 'isteksiz bir biçimde'},
        ]
      },
      {
        'root': 'CEDERE / PRECEDENT (Önden Gitmek, Emsal)',
        'description': 'Zaman veya sıra olarak öncesinde yer alma ve emsal teşkil etme kökü',
        'family': [
          {'word': 'precede', 'pos': 'Fiil', 'tr': '-den önce gelmek'},
          {'word': 'precedent', 'pos': 'İsim', 'tr': 'emsal, geçmiş örnek'},
          {'word': 'preceding', 'pos': 'Sıfat', 'tr': 'önceki, evvelki'},
          {'word': 'unprecedented', 'pos': 'Sıfat', 'tr': 'eşi benzeri görülmemiş'},
        ]
      },
      {
        'root': 'VULNUS (Yara Alabilirlik, Kırılganlık)',
        'description': 'Zarar görmeye, incinmeye açık olma durumu',
        'family': [
          {'word': 'vulnerable', 'pos': 'Sıfat', 'tr': 'savunmasız, hassas, kırılgan'},
          {'word': 'vulnerability', 'pos': 'İsim', 'tr': 'kırılganlık, savunmasızlık'},
          {'word': 'invulnerable', 'pos': 'Sıfat', 'tr': 'hasar görmez, yenilmez'},
        ]
      },
      {
        'root': 'PAR (Eşitlik, Denklik)',
        'description': 'İki veya daha fazla unsur arasındaki eşitlik ve uçurum kökü',
        'family': [
          {'word': 'parity', 'pos': 'İsim', 'tr': 'denklik, eşitlik durumu'},
          {'word': 'disparity', 'pos': 'İsim', 'tr': 'eşitsizlik, derin uçurum'},
          {'word': 'disparate', 'pos': 'Sıfat', 'tr': 'bambaşka, apayrı'},
        ]
      },
      {
        'root': 'SUBSTANTIA (Temel, Öz, Varlık)',
        'description': 'Gözle görülür esaslı büyüklük ve kanıtlama kökü',
        'family': [
          {'word': 'substance', 'pos': 'İsim', 'tr': 'madde; öz, içerik'},
          {'word': 'substantial', 'pos': 'Sıfat', 'tr': 'kayda değer, esaslı, büyük'},
          {'word': 'substantially', 'pos': 'Zarf', 'tr': 'önemli ölçüde, büyük oranda'},
          {'word': 'substantiate', 'pos': 'Fiil', 'tr': 'kanıtlamak, somutlamak'},
        ]
      },
    ];
  }
}
