import '../models/conjunction.dart';
import '../models/word.dart';

class OsymConjunctionsDatabase {
  static const List<Conjunction> conjunctions = [
    // ---------------- 1. ZITLIK & BEKLENTİNİN AKSİ (CONTRAST & CONCESSION) ----------------
    Conjunction(
      id: 'conj_although',
      conjunction: 'although',
      meaning: '-e rağmen, -se de, karşın',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. (İki zıt durumu birbirine bağlar)',
      synonyms: ['even though', 'though', 'despite the fact that', 'in spite of the fact that'],
      examples: [
        ExampleSentence(
          english: 'Although renewable energy investments have surged, fossil fuels still dominate global power generation.',
          turkish: 'Yenilenebilir enerji yatırımları artış göstermesine rağmen, fosil yakıtlar küresel enerji üretiminde hâlâ baskındır.',
        ),
      ],
      examTip: 'Kendinden sonra tam cümle (S+V) alır. Şıklarda "despite" ve "in spite of" ile birlikte verilirse ardındaki yapının cümle mi yoksa isim mi olduğuna bakılır.',
    ),

    Conjunction(
      id: 'conj_even_though',
      conjunction: 'even though',
      meaning: '-e rağmen, -se bile (Vurgulu)',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. (Zıtlığı although\'dan daha güçlü vurgular)',
      synonyms: ['although', 'though', 'despite the fact that'],
      examples: [
        ExampleSentence(
          english: 'Even though the clinical trial involved a small cohort, the preliminary findings were highly promising.',
          turkish: 'Klinik deney küçük bir hasta grubunu içermesine rağmen, ön bulgular oldukça umut vericiydi.',
        ),
      ],
      examTip: 'Cümle tamamlama sorularında zıtlık bildiren ana cümle ile yan cümle arasındaki köprüdür.',
    ),

    Conjunction(
      id: 'conj_though',
      conjunction: 'though',
      meaning: '-e rağmen; cümle sonunda: yine de',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Bağlaç / Zarf',
      grammarRule: '+ Cümle (S + V) alır. Ayrıca cümle sonuna gelerek "yine de" anlamında zarf gibi kullanılabilir.',
      synonyms: ['although', 'even though', 'however (cümle sonunda)'],
      examples: [
        ExampleSentence(
          english: 'Though artificial intelligence presents ethical concerns, its healthcare benefits cannot be denied.',
          turkish: 'Yapay zeka etik kaygılar oluştursa da sağlık sektöründeki faydaları inkar edilemez.',
        ),
      ],
      examTip: 'Cümle sonuna konduğunda "yine de, buna rağmen" anlamı verir (Örn: "The task was arduous; we succeeded, though.").',
    ),

    Conjunction(
      id: 'conj_despite_the_fact_that',
      conjunction: 'despite the fact that',
      meaning: '-dığı gerçeğine rağmen, -e rağmen',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. ("the fact that" eklendiği için cümle kabul eder)',
      synonyms: ['although', 'even though', 'in spite of the fact that'],
      examples: [
        ExampleSentence(
          english: 'Despite the fact that the surgery was prolonged, the recovery process progressed smoothly.',
          turkish: 'Ameliyatın uzun sürmüş olmasına rağmen iyileşme süreci pürüzsüzce ilerledi.',
        ),
      ],
      examTip: '"despite" normalde isim alır; ancak "the fact that" geldiğinde mutlaka TAM CÜMLE alır!',
    ),

    Conjunction(
      id: 'conj_however',
      conjunction: 'however',
      meaning: 'ancak, fakat, buna rağmen; zarf: ne kadar ... olursa olsun',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Geçiş Kelimesi (Transition) / Zarf',
      grammarRule: 'İki bağımsız cümle arasına noktalama işaretleriyle gelir (; however, / . However,).',
      synonyms: ['nevertheless', 'nonetheless', 'yet', 'still'],
      examples: [
        ExampleSentence(
          english: 'The new policy aims to reduce regional emissions; however, implementation costs remain substantial.',
          turkish: 'Yeni politika bölgesel emisyonları azaltmayı hedeflemektedir; ancak uygulama maliyetleri kayda değer kalmaktadır.',
        ),
      ],
      examTip: 'Sıfat/Zarf ile kullanımı: "However difficult the exam is, you can pass." (Ne kadar zor olursa olsun...). Bu kalıp Dil Sınavı\'nin en sevdiği tuzaklardandır!',
    ),

    Conjunction(
      id: 'conj_nevertheless',
      conjunction: 'nevertheless / nonetheless',
      meaning: 'yine de, buna rağmen, her şeye rağmen',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Geçiş Kelimesi (Transition)',
      grammarRule: 'Bağımsız iki cümle arasına gelir (; nevertheless, / . Nevertheless,)',
      synonyms: ['nonetheless', 'even so', 'however', 'still', 'yet'],
      examples: [
        ExampleSentence(
          english: 'Severe blizzards disrupted transport across the region; nevertheless, emergency teams reached the trapped villagers.',
          turkish: 'Şiddetli kar fırtınaları bölgedeki ulaşımı aksattı; yine de acil durum ekipleri mahsur kalan köylülere ulaştı.',
        ),
      ],
      examTip: 'Paragraf tamamlama ve geçiş sorularında beklenmeyen olumlu veya olumsuz sonucu bağlar.',
    ),

    Conjunction(
      id: 'conj_whereas',
      conjunction: 'whereas / while',
      meaning: '-e rağmen, oysa, halbuki, taban tabana zıt olarak',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Bağlaç (Doğrudan Karşılaştırma)',
      grammarRule: '+ Tam Cümle (S + V) alır. İki farklı özne veya niteliği doğrudan karşılaştırır.',
      synonyms: ['while', 'on the other hand', 'in contrast'],
      examples: [
        ExampleSentence(
          english: 'Whereas developed economies face demographic aging, many African nations have predominantly young populations.',
          turkish: 'Gelişmiş ekonomiler demografik yaşlanmayla karşı karşıya iken, birçok Afrika ülkesi ağırlıklı olarak genç nüfusa sahiptir.',
        ),
      ],
      examTip: 'Dil Sınavı iki farklı grup (zengin/fakir, kadın/erkek, geçmiş/günümüz) karşılaştırıldığında doğru cevap olarak "whereas" veya "while" seçtirir.',
    ),

    Conjunction(
      id: 'conj_on_the_contrary',
      conjunction: 'on the contrary / in contrast / conversely',
      meaning: 'aksine, tam tersine',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Prepositional Phrase / Zarf',
      grammarRule: 'Genellikle olumsuz bir iddiadan sonra gelip zıttını pekiştirir (; on the contrary,).',
      synonyms: ['in contrast', 'conversely', 'by contrast'],
      examples: [
        ExampleSentence(
          english: 'The economic sanction did not weaken the regime; on the contrary, it consolidated domestic political support.',
          turkish: 'Ekonomik yaptırım rejimi zayıflatmadı; aksine, iç siyasi desteği daha da pekiştirdi.',
        ),
      ],
      examTip: '"on the contrary" genellikle kendisinden önce olumsuz (not / never) bir yargı arar!',
    ),

    Conjunction(
      id: 'conj_on_the_other_hand',
      conjunction: 'on the other hand',
      meaning: 'öte yandan, diğer taraftan',
      category: 'Zıtlık & Karşıtlık (Contrast)',
      type: 'Prepositional Phrase',
      grammarRule: 'Bir konunun madalyonunun diğer yüzünü anlatmak için kullanılır.',
      synonyms: ['in contrast', 'conversely'],
      examples: [
        ExampleSentence(
          english: 'Nuclear energy provides vast amounts of electricity; on the other hand, managing nuclear waste remains perilous.',
          turkish: 'Nükleer enerji muazzam miktarda elektrik sağlar; öte yandan, nükleer atıkların yönetimi tehlikeli olmaya devam etmektedir.',
        ),
      ],
      examTip: 'Paragraflarda "On the one hand... on the other hand..." ikilisi olarak da sıkça rastlanır.',
    ),

    // ---------------- 2. SEBEP & SONUÇ (CAUSE & EFFECT) ----------------
    Conjunction(
      id: 'conj_because',
      conjunction: 'because / since / as',
      meaning: '-dığı için, çünkü, -den dolayı',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. (Sebep bildirir)',
      synonyms: ['since', 'as', 'inasmuch as', 'seeing that', 'now that'],
      examples: [
        ExampleSentence(
          english: 'Because bacteria develop resistance against conventional antibiotics, researchers must engineer novel treatments.',
          turkish: 'Bakteriler geleneksel antibiyotiklere karşı direnç geliştirdiği için, araştırmacılar yeni tedaviler tasarlamak zorundadır.',
        ),
      ],
      examTip: '"Because of" isim alırken, "Because" mutlaka CÜMLE alır! Bu soru kalıbı istisnasız her YDS sınavında çıkar.',
    ),

    Conjunction(
      id: 'conj_in_that',
      conjunction: 'in that',
      meaning: 'çünkü, bakımından, -mesi yönüyle',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. Önündeki ifadenin nedenini veya hangi yönden öyle olduğunu açıklar.',
      synonyms: ['because', 'since', 'inasmuch as'],
      examples: [
        ExampleSentence(
          english: 'The cheetah is unique among big cats in that it relies on supreme acceleration rather than stealth.',
          turkish: 'Çita, gizlilik yerine üstün hızlanmasına dayanması yönüyle (çünkü öyle olduğundan) büyük kediler arasında eşsizdir.',
        ),
      ],
      examTip: 'Cümle başında pek kullanılmaz; iki cümle arasında "çünkü / şu bakımdan ki" anlamında Dil Sınavı\'nin en seçkin bağlaçlarındandır.',
    ),

    Conjunction(
      id: 'conj_now_that',
      conjunction: 'now that',
      meaning: '-dığına göre, mademki, artık ... olduğuna göre',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. Yeni gerçekleşmiş bir durumun doğurduğu sonucu bağlar.',
      synonyms: ['since', 'seeing that', 'as'],
      examples: [
        ExampleSentence(
          english: 'Now that high-speed rail lines are operational, travel time between major metropolises has been halved.',
          turkish: 'Artık hızlı tren hatları faaliyete geçtiğine göre, büyük metropoller arasındaki seyahat süresi yarıya indi.',
        ),
      ],
      examTip: 'Genellikle "Present" veya "Present Perfect" zamanlarla birlikte kullanılır.',
    ),

    Conjunction(
      id: 'conj_therefore',
      conjunction: 'therefore / thus / hence / consequently',
      meaning: 'bu yüzden, dolayısıyla, sonuç olarak, bundan dolayı',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Geçiş Kelimesi (Transition) / Zarf',
      grammarRule: 'İki cümle arasına noktalama işaretleriyle gelir (; therefore, / . Thus,). Ardından SONUÇ gelir.',
      synonyms: ['as a result', 'as a consequence', 'that is why', 'which is why', 'accordingly', 'thereby'],
      examples: [
        ExampleSentence(
          english: 'The reservoir levels dropped to historic lows; therefore, municipal authorities imposed mandatory water rationing.',
          turkish: 'Baraj seviyeleri tarihi dip seviyelere geriledi; bu yüzden belediye yetkilileri zorunlu su kısıtlaması getirdi.',
        ),
      ],
      examTip: '"Thus + Ving" (Böylelikle ... yaparak) yapısı YDS cümle tamamlama ve çeviride en sık karşılaşılan kalıptır.',
    ),

    Conjunction(
      id: 'conj_as_a_result',
      conjunction: 'as a result / as a consequence',
      meaning: 'sonuç olarak, bunun neticesinde',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Bağlaç / Prepositional Phrase',
      grammarRule: '; as a result, + Cümle. (Eğer "as a result of" olursa + İSİM alır!)',
      synonyms: ['consequently', 'therefore', 'in consequence'],
      examples: [
        ExampleSentence(
          english: 'Deforestation stripped the mountains of soil cover; as a result, catastrophic mudslides occurred during the monsoon.',
          turkish: 'Ormansızlaşma dağları toprak örtüsünden yoksun bıraktı; sonuç olarak muson yağmurlarında feci çamur kaymaları yaşandı.',
        ),
      ],
      examTip: '"as a result" = sonuç olarak (cümle). "as a result of" = -in sonucu olarak (isim öbeği).',
    ),

    Conjunction(
      id: 'conj_thereby',
      conjunction: 'thereby',
      meaning: 'böylece, bu suretle, bu yolla',
      category: 'Sebep & Sonuç (Cause & Effect)',
      type: 'Zarf',
      grammarRule: 'Genellikle ", thereby + Ving" şeklinde fiilimsiyle kullanılır.',
      synonyms: ['thus', 'by that means', 'in this way'],
      examples: [
        ExampleSentence(
          english: 'The hybrid engine recaptures energy during braking, thereby improving fuel efficiency considerably.',
          turkish: 'Hibrit motor frenleme sırasında enerjiyi geri kazanır, böylece yakıt verimliliğini önemli ölçüde artırır.',
        ),
      ],
      examTip: 'Arkasına doğrudan fiilin "-ing" hali (Ving) gelmesi Sınav sorularında en belirleyici ipucudur.',
    ),

    // ---------------- 3. KOŞUL & ŞART (CONDITION) ----------------
    Conjunction(
      id: 'conj_provided_that',
      conjunction: 'provided that / providing that',
      meaning: 'şartıyla, koşuluyla (= if)',
      category: 'Koşul & Şart (Condition)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. Type 1 veya Type 0 koşul cümleleri kurar.',
      synonyms: ['on condition that', 'as long as', 'so long as', 'only if', 'if'],
      examples: [
        ExampleSentence(
          english: 'You may access the restricted research archive provided that you strictly adhere to copyright regulations.',
          turkish: 'Telif hakkı kurallarına kesinlikle uymanız koşuluyla kısıtlı araştırma arşivine erişebilirsiniz.',
        ),
      ],
      examTip: 'Sınavda doğrudan "if" yerine geçer. Seçeneklerde "if" yoksa ilk aranacak kelimedir.',
    ),

    Conjunction(
      id: 'conj_as_long_as',
      conjunction: 'as long as / so long as',
      meaning: '-dığı sürece, -dığı müddetçe',
      category: 'Koşul & Şart (Condition)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır. Bir durum devam ettiği müddetçe geçerli koşulu anlatır.',
      synonyms: ['so long as', 'provided that', 'on condition that'],
      examples: [
        ExampleSentence(
          english: 'As long as global carbon emissions continue unabated, ocean acidification will accelerate.',
          turkish: 'Küresel karbon salımları hız kesmeden sürdüğü müddetçe, okyanus asitlenmesi hızlanacaktır.',
        ),
      ],
      examTip: 'Zaman uyumu kuralına tabidir: As long as + Present, Future / Modal.',
    ),

    Conjunction(
      id: 'conj_unless',
      conjunction: 'unless',
      meaning: '-mezse / -mazsa, -medikçe (= if not)',
      category: 'Koşul & Şart (Condition)',
      type: 'Bağlaç',
      grammarRule: '+ Olumlu yapıda Tam Cümle alır, ancak anlamı olumsuzdur. (unless it rains = yağmur yağmazsa)',
      synonyms: ['if ... not', 'except if'],
      examples: [
        ExampleSentence(
          english: 'Unless urgent fiscal measures are adopted, inflation will erode consumer purchasing power.',
          turkish: 'Acil mali tedbirler benimsenmezse, enflasyon tüketicinin alım gücünü kemirecektir.',
        ),
      ],
      examTip: 'Kendi cümlesinde "not" bulunmaz (anlamı kendisi olumsuz yapar). Diğer temel cümle genellikle olumsuz veya uyarı taşır.',
    ),

    Conjunction(
      id: 'conj_otherwise',
      conjunction: 'otherwise / or else',
      meaning: 'aksi takdirde, yoksa',
      category: 'Koşul & Şart (Condition)',
      type: 'Geçiş Kelimesi (Transition) / Zarf',
      grammarRule: 'Genellikle buyruk, tavsiye veya modal içeren cümleden sonra gelir (; otherwise,).',
      synonyms: ['or else', 'if not'],
      examples: [
        ExampleSentence(
          english: 'Patients must complete the entire antibiotic regimen; otherwise, resistant strains can proliferate.',
          turkish: 'Hastalar antibiyotik tedavisinin tamamını bitirmelidir; aksi takdirde dirençli suşlar çoğalabilir.',
        ),
      ],
      examTip: 'Kendinden sonraki cümlede sıklıkla "would / could / might" gibi varsayım modalları kullanılır.',
    ),

    Conjunction(
      id: 'conj_on_condition_that',
      conjunction: 'on condition that',
      meaning: 'şartıyla, koşuluyla',
      category: 'Koşul & Şart (Condition)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle (S + V) alır.',
      synonyms: ['provided that', 'providing that', 'as long as'],
      examples: [
        ExampleSentence(
          english: 'The loan was granted on condition that the company invest exclusively in clean energy.',
          turkish: 'Kredi, şirketin yalnızca temiz enerjiye yatırım yapması koşuluyla verildi.',
        ),
      ],
      examTip: 'Hukuki, diplomatik ve ekonomik metinlerde "provided" yerine resmi üslupta tercih edilir.',
    ),

    // ---------------- 4. EK & PARALELLİK (ADDITION) ----------------
    Conjunction(
      id: 'conj_furthermore',
      conjunction: 'furthermore / moreover',
      meaning: 'dahası, ayrıca, dahası ve üstelik',
      category: 'Ek & İlave (Addition)',
      type: 'Geçiş Kelimesi (Transition)',
      grammarRule: '; furthermore, + Tam Cümle. (Aynı yöndeki argümanı güçlendirir)',
      synonyms: ['moreover', 'in addition', 'additionally', 'what is more', 'besides'],
      examples: [
        ExampleSentence(
          english: 'Regular aerobic exercise strengthens cardiovascular health; furthermore, it boosts mental cognitive stamina.',
          turkish: 'Düzenli aerobik egzersiz kardiyovasküler sağlığı güçlendirir; dahası, zihinsel bilişsel dayanıklılığı artırır.',
        ),
      ],
      examTip: 'Paragraf sorularında önceki fikirle AYNI YÖNDE (olumluya olumlu, olumsuza olumsuz) ek argüman sunar.',
    ),

    Conjunction(
      id: 'conj_in_addition',
      conjunction: 'in addition / additionally',
      meaning: 'ayrıca, buna ek olarak',
      category: 'Ek & İlave (Addition)',
      type: 'Geçiş Kelimesi / Zarf',
      grammarRule: '; in addition, + Cümle. (Eğer "in addition to" olursa + İSİM / Ving alır!)',
      synonyms: ['moreover', 'furthermore', 'besides', 'additionally'],
      examples: [
        ExampleSentence(
          english: 'The university built a state-of-the-art laboratory; in addition, it funded ten international doctoral scholarships.',
          turkish: 'Üniversite son teknoloji bir laboratuvar inşa etti; buna ek olarak, on uluslararası doktora bursunu finanse etti.',
        ),
      ],
      examTip: '"in addition" = ayrıca (Cümle). "in addition to" = -e ilaveten (İsim). Çok sık sorulan edat ayrımıdır.',
    ),

    Conjunction(
      id: 'conj_besides',
      conjunction: 'besides',
      meaning: 'ayrıca, bunun yanında; edat olarak: -den başka, -in yanı sıra',
      category: 'Ek & İlave (Addition)',
      type: 'Bağlaç / Preposition',
      grammarRule: 'Zarf olarak cümle başına (; besides,); edat olarak isim önüne (+ noun) gelebilir.',
      synonyms: ['as well as', 'in addition to', 'moreover'],
      examples: [
        ExampleSentence(
          english: 'Besides reducing operational expenditure, automation minimized manufacturing errors.',
          turkish: 'Otomasyon, operasyonel harcamaları azaltmanın yanı sıra üretim hatalarını da en aza indirdi.',
        ),
      ],
      examTip: '"beside" (yanında, kenarında) ile "besides" (ayrıca, yanı sıra) karıştırılmamalıdır!',
    ),

    // ---------------- 5. ZAMAN & SÜREÇ (TIME) ----------------
    Conjunction(
      id: 'conj_by_the_time',
      conjunction: 'by the time',
      meaning: '-dığı zamana kadar, -e kadar',
      category: 'Zaman (Time)',
      type: 'Zaman Bağlacı',
      grammarRule: 'By the time + V2 (Past), Subject + had V3 (Past Perfect) VEYA By the time + V1 (Present), Subject + will have V3 (Future Perfect).',
      synonyms: ['before', 'until'],
      examples: [
        ExampleSentence(
          english: 'By the time firefighters arrived at the scene, the blazing inferno had been brought under control by locals.',
          turkish: 'İtfaiyeciler olay yerine vardığında, alev alev yanan yangın yerel halk tarafından kontrol altına alınmıştı bile.',
        ),
      ],
      examTip: 'YDS/YÖKDİL Tense (Zaman) sorularının en net şablonudur: Yanında Past varsa ana cümlede MUTLAKA "had + V3" aranır!',
    ),

    Conjunction(
      id: 'conj_as_soon_as',
      conjunction: 'as soon as / once',
      meaning: 'yapar yapmaz, -ince, -den hemen sonra',
      category: 'Zaman (Time)',
      type: 'Zaman Bağlacı',
      grammarRule: '+ Tam Cümle alır. İki olayın peş peşe, anında gerçekleştiğini belirtir.',
      synonyms: ['once', 'the moment', 'immediately after'],
      examples: [
        ExampleSentence(
          english: 'As soon as the earthquake tremors ceased, rescue teams mobilized toward the collapsed buildings.',
          turkish: 'Deprem sarsıntıları durur durmaz, kurtarma ekipleri çöken binalara doğru harekete geçti.',
        ),
      ],
      examTip: '"Once" da tıpkı "as soon as" gibi zaman bağlacı olarak "-ince / yapar yapmaz" anlamında çokça kullanılır.',
    ),

    Conjunction(
      id: 'conj_until',
      conjunction: 'until / till',
      meaning: '-e kadar (Sürenin bitimine işaret eder)',
      category: 'Zaman (Time)',
      type: 'Bağlaç / Preposition',
      grammarRule: '+ Cümle veya + İsim/Zaman ifadesi alır. O zamana kadar eylemin devam ettiğini bildirir.',
      synonyms: ['up to the time that', 'by'],
      examples: [
        ExampleSentence(
          english: 'The archeologists continued the excavation until heavy winter snowfalls halted all field activities.',
          turkish: 'Arkeologlar, yoğun kış kar yağışları tüm saha faaliyetlerini durdurana kadar kazıya devam ettiler.',
        ),
      ],
      examTip: '"By" bir anı (deadline) belirtirken, "Until" o ana kadar sürecin sürdüğünü belirtir.',
    ),

    // ---------------- 6. AMAÇ & SONUÇ (PURPOSE) ----------------
    Conjunction(
      id: 'conj_so_that',
      conjunction: 'so that / in order that',
      meaning: '-sın diye, -ebilmek amacıyla',
      category: 'Amaç (Purpose)',
      type: 'Bağlaç',
      grammarRule: '+ Tam Cümle alır. Genellikle cümlesinde "can / could / may / might / will / would" modalları barındırır.',
      synonyms: ['in order that', 'so as to (+ V1)', 'in order to (+ V1)'],
      examples: [
        ExampleSentence(
          english: 'Engineers insulated the spacecraft walls so that sensitive instruments could withstand cosmic radiation.',
          turkish: 'Mühendisler, hassas aletler kozmik radyasyona dayanabilsin diye uzay aracının duvarlarını izole etti.',
        ),
      ],
      examTip: 'Kendinden sonra modal (can/could) içeren tam cümle arar. "so that + S + could + V1" kalıbı altın kuraldır.',
    ),

    Conjunction(
      id: 'conj_lest',
      conjunction: 'lest / for fear that',
      meaning: '-mesin diye, korkusuyla, olmasın diye',
      category: 'Amaç (Purpose)',
      type: 'Bağlaç',
      grammarRule: '+ Cümle (genellikle yalın fiil veya should + V1) alır. Cümle olumsuz anlam taşır ama "not" almaz.',
      synonyms: ['for fear that', 'in order that ... not'],
      examples: [
        ExampleSentence(
          english: 'Diplomats held secret talks behind closed doors lest public outcry jeopardize the negotiations.',
          turkish: 'Diplomatlar, kamuoyu tepkisi müzakereleri tehlikeye atmasın diye kapalı kapılar ardında gizli görüşmeler yaptı.',
        ),
      ],
      examTip: 'C1 seviye seçkin bağlaçtır; kendisinden sonra fiil genellikle YALIN halde kullanılır (subjunctive).',
    ),

    // ---------------- 7. AÇIKLAMA & VURGU (CLARIFICATION) ----------------
    Conjunction(
      id: 'conj_in_fact',
      conjunction: 'in fact / as a matter of fact / actually / indeed',
      meaning: 'aslında, doğrusunu söylemek gerekirse, hatta, gerçekten de',
      category: 'Vurgu & Açıklama (Clarification)',
      type: 'Zarf / Geçiş İfadesi',
      grammarRule: 'Önceki cümlenin ardına gelerek durumu daha da pekiştirir veya beklenenin aksini ortaya koyar.',
      synonyms: ['actually', 'indeed', 'as a matter of fact', 'in reality'],
      examples: [
        ExampleSentence(
          english: 'The species was thought to be extinct; in fact, a small thriving population was discovered on a remote island.',
          turkish: 'Türün neslinin tükendiği sanılıyordu; aslında, ücra bir adada gelişmekte olan küçük bir popülasyon keşfedildi.',
        ),
      ],
      examTip: 'Paragrafta yaygın bir yanlış algıyı düzeltmek ("It was widely believed..., in fact...") için başvurulur.',
    ),

    Conjunction(
      id: 'conj_that_is',
      conjunction: 'that is / namely / that is to say',
      meaning: 'yani, diğer bir deyişle, açıkçası',
      category: 'Vurgu & Açıklama (Clarification)',
      type: 'Geçiş İfadesi',
      grammarRule: 'Bir kavramı veya tanımı daha anlaşılır kılmak için kullanılır.',
      synonyms: ['namely', 'that is to say', 'in other words'],
      examples: [
        ExampleSentence(
          english: 'The animal is nocturnal; that is, it hunts and remains active exclusively during nighttime hours.',
          turkish: 'Hayvan gececildir; yani yalnızca gece saatlerinde avlanır ve aktif kalır.',
        ),
      ],
      examTip: 'Teknik bir terim açıklandığında şıklarda "namely" veya "that is" aranmalıdır.',
    ),
  ];
}
