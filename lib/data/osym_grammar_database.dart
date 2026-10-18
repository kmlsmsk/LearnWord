import '../models/grammar_topic.dart';

class OsymGrammarDatabase {
  static const List<GrammarTopic> topics = [
    // ==========================================
    // 1. TENSES & ZAMAN UYUMU (TIME HARMONY)
    // ==========================================
    GrammarTopic(
      id: 'g_present_perfect',
      title: 'Present Perfect Tense & Since / For Matrisi',
      titleTr: 'Yakın Geçmiş Zaman & Since / For Kuralı',
      category: 'Zamanlar (Tenses)',
      formula: 'S + have / has + V3',
      explanation: 'Geçmişte başlayıp günümüzde devam eden veya etkisi süren eylemleri ifade eder. ÖSYM sınavlarının en çok test edilen zaman yapısıdır. "Recently, lately, so far, up to now, over the last/past 10 years, in recent decades" gibi zaman zarflarıyla zorunlu olarak kullanılır.',
      osymTips: [
        '📌 "Since + Past Simple (V2), Main Clause = Present Perfect (have/has V3)" kuralı ÖSYM\'nin en sevdiği ve hemen her sınavda sorduğu altın kuraldır.',
        '📌 "Over / In / During the last/past decade/century" kalıbı doğrudan "have/has V3" gerektirir.',
        '📌 Cümlede net bir geçmiş zaman belirteci (in 1995, ago, yesterday, during the Ottoman era) varsa KESİNLİKLE Present Perfect DEĞİL, Past Simple (V2) seçilmelidir.',
      ],
      examples: [
        GrammarExample(
          english: 'Since the industrial revolution began, carbon dioxide levels have risen dramatically.',
          turkish: 'Sanayi devrimi başladığından beri, karbondioksit seviyeleri çarpıcı biçimde yükselmiştir.',
          examNote: 'Since + V2 (began) -> Main clause (have risen)',
        ),
        GrammarExample(
          english: 'Over the past two decades, scientists have discovered hundreds of new exoplanets.',
          turkish: 'Son yirmi yıl boyunca bilim insanları yüzlerce yeni ötegezegen keşfetti.',
          examNote: 'Over the past two decades -> have discovered',
        ),
      ],
      commonMistakes: [
        '"In the past" tek başına verilirse Past Simple (V2), "Over the past years" verilirse Present Perfect (have V3) kullanılır.',
      ],
    ),
    GrammarTopic(
      id: 'g_past_perfect',
      title: 'Past Perfect Tense (Öncelik-Sonralık)',
      titleTr: 'Geçmişin Geçmişi (Had + V3)',
      category: 'Zamanlar (Tenses)',
      formula: 'S + had + V3',
      explanation: 'Geçmişte gerçekleşen iki olaydan daha önce meydana geleni ifade eder. Tek başına bağımsız bir cümlede gerekçesiz yere kullanılmaz; mutlaka geçmişte başka bir referans noktası (Past Simple) bulunmalıdır.',
      osymTips: [
        '📌 By the time + Past Simple (V2), S + had + V3 (ÖSYM\'nin klasik şablonu).',
        '📌 "Before" bağlacının bağlı olduğu cümle V2 iken diğer taraf had V3 olur. "After"ın bağlı olduğu cümle ise had V3 olur.',
        '📌 "No sooner ... than" ve "Hardly / Scarcely ... when" kalıplarında devrik Past Perfect kullanılır: "Hardly had the meeting started when the power went out."',
      ],
      examples: [
        GrammarExample(
          english: 'By the time the rescue team arrived at the scene, the fire had already destroyed the warehouse.',
          turkish: 'Kurtarma ekibi olay yerine vardığında, yangın depoyu çoktan yok etmişti.',
          examNote: 'By the time + V2 (arrived) -> had destroyed',
        ),
      ],
    ),
    GrammarTopic(
      id: 'g_future_perfect',
      title: 'Future Perfect Tense (By + Gelecek Zaman)',
      titleTr: 'Gelecekte Tamamlanmışlık (Will have + V3)',
      category: 'Zamanlar (Tenses)',
      formula: 'S + will have + V3',
      explanation: 'Gelecekte belirli bir tarihten veya olaydan önce tamamlanmış olacak eylemleri anlatır.',
      osymTips: [
        '📌 "By + Future Time" (ör. By 2050, by the end of this century, by next decade) görüldüğü anda doğrudan "will have V3" veya pasif hali "will have been V3" aranmalıdır.',
        '📌 "By the time + Present Simple (V1), S + will have V3" zaman uyumu kuralıdır.',
      ],
      examples: [
        GrammarExample(
          english: 'By the year 2050, renewable energy sources will have replaced fossil fuels in many sectors.',
          turkish: '2050 yılına kadar yenilenebilir enerji kaynakları birçok sektörde fosil yakıtların yerini almış olacaktır.',
          examNote: 'By 2050 -> will have replaced',
        ),
      ],
    ),
    GrammarTopic(
      id: 'g_tense_harmony',
      title: 'Zaman Uyumu Kuralları (Tense Harmony Matrix)',
      titleTr: 'Bağlaçlarda Zaman Uyumu Matrisi',
      category: 'Zamanlar (Tenses)',
      formula: 'Zaman Bağlacı (When, While, As, After, Before, Until) + Yan Cümle, Ana Cümle',
      explanation: 'Zaman bağlaçlarının bulunduğu yan cümlelerde KESİNLİKLE "will, would, be going to" KULLANILMAZ! Zaman uyumu gereği Present zamanlar Present/Future ile, Past zamanlar ise sadece Past ile eşleşir.',
      osymTips: [
        '📌 Asla zaman bağlacının hemen yanındaki cümlede "will / would" aramayın.',
        '📌 Present - Future eşleşmesi: When S + V1, S + will V1 / can V1.',
        '📌 Past - Past eşleşmesi: When S + V2, S + was/were Ving / had V3 / V2.',
      ],
      examples: [
        GrammarExample(
          english: 'When volcanic magma reaches the ocean surface, it cools down rapidly and forms basalt rock.',
          turkish: 'Volkanik magma okyanus yüzeyine ulaştığında hızla soğur ve bazalt kayası oluşturur.',
          examNote: 'Genel doğa kuralı: reaches (V1) -> cools down (V1)',
        ),
      ],
    ),

    // ==========================================
    // 2. CONDITIONALS (KOŞUL CÜMLELERİ & DEVİRİKLİK)
    // ==========================================
    GrammarTopic(
      id: 'g_conditionals_standard',
      title: 'Koşul Cümleleri (Type 1, 2, 3)',
      titleTr: 'Temel Şart Cümleleri (If Clauses)',
      category: 'Koşul Cümleleri (Conditionals)',
      formula: 'Type 1: If + V1, will + V1 | Type 2: If + V2, would + V1 | Type 3: If + had V3, would have V3',
      explanation: 'Bir durumun gerçekleşmesinin başka bir şarta bağlı olduğunu ifade eden yapılardır. Type 1 gerçekçi olasılıkları, Type 2 şimdiki zamandaki hayali durumları, Type 3 ise geçmişteki pişmanlık ve kaçırılmış durumları anlatır.',
      osymTips: [
        '📌 If cümlesinin içine "will / would" ASLA gelmez.',
        '📌 "Mixed Type 3 to 2": Geçmişteki bir eylemin bugünkü sonucu kastediliyorsa (ör. "now, today" varsa): "If had V3, would V1 (today)" kullanılır.',
        '📌 Unless = If ... not (Eğer ... olmazsa/medikçe). Arkasından gelen cümle olumlu yapıda olur ama anlamı olumsuzdur.',
      ],
      examples: [
        GrammarExample(
          english: 'If the government had taken strict measures earlier, the economic crisis would not be so severe today.',
          turkish: 'Hükümet daha önce sıkı tedbirler almış olsaydı, ekonomik kriz bugün bu kadar şiddetli olmazdı.',
          examNote: 'Mixed Conditional: had taken (geçmiş) -> would not be (bugün/now)',
        ),
      ],
    ),
    GrammarTopic(
      id: 'g_inversion_conditionals',
      title: 'Devrik Koşul Yapıları (Inversion in Conditionals)',
      titleTr: 'If Olmadan Devrik Şart Cümleleri',
      category: 'Koşul Cümleleri (Conditionals)',
      formula: 'Type 1: Should S + V1 | Type 2: Were S + to V1 / Were S | Type 3: Had S + V3',
      explanation: 'Akademik dilde "If" kelimesi atılarak cümle devrik (soru cümlesi dizilimi) yapılır. ÖSYM bu yapıları paragraf ve cümle tamamlama sorularında sıkça tercih eder.',
      osymTips: [
        '📌 "Had the patient arrived earlier, she would have survived." -> (If the patient had arrived earlier demektir).',
        '📌 "Should you encounter any difficulty, contact our team." -> (If you encounter demektir).',
        '📌 "Were it not for his support..." = "Onun desteği olmasaydı..." (But for / Without kalıbının eş anlamlısıdır).',
      ],
      examples: [
        GrammarExample(
          english: 'Had scientists not developed the vaccine in record time, millions more people would have died.',
          turkish: 'Bilim insanları aşıyı rekor sürede geliştirmemiş olsaydı, milyonlarca insan daha hayatını kaybetmiş olurdu.',
          examNote: 'Had + S + V3 devrik yapısı Type 3 yerine kullanılmıştır.',
        ),
      ],
    ),

    // ==========================================
    // 3. RELATIVE CLAUSES (SIFAT CÜMLECİKLERİ)
    // ==========================================
    GrammarTopic(
      id: 'g_relative_clauses',
      title: 'Relative Clauses & Edat + Which/Whom',
      titleTr: 'Sıfat Cümlecikleri ve Preposition + Relative Pronoun',
      category: 'Sıfat Cümlecikleri (Relative Clauses)',
      formula: 'İsim + [who / which / that / whose / where / preposition + which]',
      explanation: 'Bir ismi niteleyip onun hakkında detaylı bilgi veren yan cümlelerdir. ÖSYM özellikle virgülden sonra "that" GELMEYECEĞİNİ ve edatlardan sonra sadece "which" (nesneler) veya "whom" (insanlar) gelebileceğini test eder.',
      osymTips: [
        '📌 Virgülden sonra (Non-defining) ve edattan sonra (in, on, at, with) ASLA "that" KULLANILMAZ!',
        '📌 "Whose + Tam Noun": Whose kelimesinden sonra mutlaka eksiz ve tanımsız bir isim gelmelidir (whose father, whose symptoms).',
        '📌 "in which = where", "at which = where", "on which = when", "for which = why".',
        '📌 Miktar ifadeleri ile: "some of which, all of whom, none of which" (virgül sonrası kullanılır).',
      ],
      examples: [
        GrammarExample(
          english: 'The university offers various programs, many of which are accredited internationally.',
          turkish: 'Üniversite, birçoğu uluslararası düzeyde akredite olan çeşitli programlar sunmaktadır.',
          examNote: 'Virgül + many of which (that gelemez)',
        ),
        GrammarExample(
          english: 'Photosynthesis is a vital process through which plants convert solar energy into chemical energy.',
          turkish: 'Fotosentez, bitkilerin güneş enerjisini kimyasal enerjiye dönüştürdüğü hayati bir süreçtir.',
          examNote: 'through which = o süreç vasıtasıyla',
        ),
      ],
    ),

    // ==========================================
    // 4. NOUN CLAUSES (İSİM CÜMLECİKLERİ)
    // ==========================================
    GrammarTopic(
      id: 'g_noun_clauses',
      title: 'Noun Clauses & Subjunctive Yapılar',
      titleTr: 'İsim Cümlecikleri ve İsteme/Gereklilik Kipi',
      category: 'İsim Cümlecikleri (Noun Clauses)',
      formula: 'That + S+V+O | Whether ... or not | Question word + S+V',
      explanation: 'Cümlenin öznesi veya nesnesi konumunda görev yapan cümlelerdir. Fiilden veya sıfattan sonra "That" gelerek bir gerçeği belirtir.',
      osymTips: [
        '📌 "The fact that + S+V": Edatlardan sonra doğrudan cümle gelemez, araya "the fact that" girer: "Due to the fact that..."',
        '📌 Whether / If: İkilem ve belirsizlik anlatır. "Whether or not" yan yana gelebilir, ancak "if or not" yan yana GELEMEZ.',
        '📌 Subjunctive Yapı: "It is essential / crucial / vital / recommended that S + (should) V1". Özne ne olursa olsun fiil YALIN (V1) kalır!',
      ],
      examples: [
        GrammarExample(
          english: 'It is imperative that every doctor adhere strictly to the ethical code of conduct.',
          turkish: 'Her doktorun etik kurallara harfiyen uyması zorunludur.',
          examNote: 'Subjunctive: every doctor tekil olmasına rağmen "adheres" değil yalın "adhere" kullanılır.',
        ),
        GrammarExample(
          english: 'Researchers are investigating whether climate change will trigger unprecedented ocean currents.',
          turkish: 'Araştırmacılar, iklim değişikliğinin eşi benzeri görülmemiş okyanus akıntılarını tetikleyip tetiklemeyeceğini araştırıyor.',
          examNote: 'whether ... (olup olmayacağı)',
        ),
      ],
    ),

    // ==========================================
    // 5. REDUCTIONS (KISALTMALAR / PARTICIPLE CLAUSES)
    // ==========================================
    GrammarTopic(
      id: 'g_reductions_participle',
      title: 'Kısaltmalar (Participle Reductions & To-Infinitive)',
      titleTr: 'Fiilimsi ve Cümlecik Kısaltmaları',
      category: 'Kısaltmalar (Reductions)',
      formula: 'Aktif: Ving / Having V3 | Pasif: V3 / Having been V3 | To-infinitive: to V1 / to have V3',
      explanation: 'Özneleri ortak olan sıfat ve zarf cümleciklerinin daha akıcı bir akademik anlatım için kısaltılmasıdır. ÖSYM sorularında en çok soru gelen ileri düzey konudur.',
      osymTips: [
        '📌 Cümle başındaki boşlukta: Virgülden sonraki özne eylemi YAPIYORSA -> Ving / Having V3 (Aktif).',
        '📌 Virgülden sonraki özne eylemden ETKİLENİYORSA -> V3 / Having been V3 (Pasif).',
        '📌 Zaman farkı / öncelik vurgulanıyorsa: "Having V3" (Aktif öncelik) veya "Having been V3" (Pasif öncelik).',
        '📌 Sıfat cümleciği kısaltmasında: "the first, the second, the last, the only, the best" gibi süperlativ ve sıra sayılarından sonra DAİMA "to V1 / to be V3" kısaltması gelir!',
      ],
      examples: [
        GrammarExample(
          english: 'Having completed all clinical trials successfully, the pharmaceutical company applied for official approval.',
          turkish: 'Tüm klinik deneyleri başarıyla tamamlamış olan ilaç şirketi, resmi onay için başvuruda bulundu.',
          examNote: 'Having completed: Şirket deneyleri daha önce tamamladığı için öncelikli aktif kısaltma.',
        ),
        GrammarExample(
          english: 'Discovered by Alexander Fleming in 1928, penicillin revolutionized modern medicine.',
          turkish: '1928 yılında Alexander Fleming tarafından keşfedilen penisilin, modern tıpta devrim yarattı.',
          examNote: 'Discovered (V3): Penisilin keşfedildiği için pasif kısaltma.',
        ),
        GrammarExample(
          english: 'Neil Armstrong was the first person to walk on the lunar surface.',
          turkish: 'Neil Armstrong, ay yüzeyinde yürüyen ilk kişiydi.',
          examNote: 'the first person -> to walk (to-infinitive kısaltması)',
        ),
      ],
      commonMistakes: [
        'Zaman farkı yoksa sadece "Ving", zaman farkı varsa "Having V3" seçilmelidir.',
      ],
    ),
  ];
}
