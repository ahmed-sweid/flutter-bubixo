import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/tokens/app_colors.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../../../core/theme/tokens/app_typography.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key, this.lessonIndex = 0});

  final int lessonIndex;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int? _selectedAnswer;
  bool _showAnswer = false;

  static const _lessons = <_LessonContent>[
    _LessonContent('Alfabe ve Telaffuzun Temelleri', 8,
      'İngilizce alfabe 26 harften oluşur; Türkçedeki ç, ğ, ı, ö, ş, ü yoktur, buna karşılık q, w, x vardır. İngilizce yazıldığı gibi okunmaz. Yeni kelimeleri sesleriyle birlikte öğren.',
      [('A — apple','“Epıl” gibi başlar (elma).'),('E — egg','Kısa e sesi (yumurta).'),('I — ice','“Ays” diye okunur (buz).'),('W — water','“Uotır” (su); w sesinde dudaklar yuvarlanır.'),('TH — thank you','TH sesinde dilin ucu dişlerin arasına hafifçe gelir.')],
      'TH sesi Türkçede yoktur. “Think”, “three” ve “thank you” derken dilinin ucunu dişlerinin arasına hafifçe getir.',
      'İngilizcede olup Türkçe alfabede olmayan harf hangisi?', ['ş','w','ö','ç'], 1, 'q, w ve x İngilizcede var, Türkçede yok.'),
    _LessonContent('Selamlaşma ve Tanışma', 10,
      'İngilizcede selamlaşma günün saatine göre değişir. Tanışma kalıplarını öğren, kendi bilgilerini yerleştir ve konuşmaya başla.',
      [('Hello! / Hi!','Merhaba! / Selam!'),('Good morning.','Günaydın; öğlene kadar kullanılır.'),('Good afternoon.','Tünaydın; öğleden sonra kullanılır.'),('My name is Ali. What is your name?','Benim adım Ali. Senin adın ne?'),('Nice to meet you!','Tanıştığımıza memnun oldum!')],
      '“Good night” selamlaşma değil, vedadır. Akşam biriyle karşılaşırken “Good evening” kullan.',
      'Sabah 09.00’da birine ne dersin?', ['Good night','Good morning','Good evening','Goodbye'], 1, 'Öğlene kadar “Good morning” kullanılır.'),
    _LessonContent('am / is / are — Olmak Fiili', 12,
      'İngilizcede “to be” fiili özneye göre değişir: I → am, he/she/it → is, you/we/they → are.',
      [('I am a student.','Ben bir öğrenciyim.'),('You are my friend.','Sen benim arkadaşımsın.'),('He is a doctor.','O doktordur.'),('We are at home.','Biz evdeyiz.'),('Are you ready? — Yes, I am.','Hazır mısın? — Evet, hazırım.')],
      'Konuşmada kısaltmalar yaygındır: I am → I’m, he is → he’s, we are → we’re.',
      '“Ben mutluyum” nasıl denir?', ['I is happy','I am happy','I are happy','Me happy'], 1, 'I öznesi daima am ile kullanılır.'),
    _LessonContent('Sayılar, Günler ve Saat', 12,
      'Sayılar, randevular ve saatler günlük hayatta sık kullanılır. 13–19 sayılarında “-teen”, 20–90 aralığında “-ty” sonuna dikkat et.',
      [('one, two, three, four, five','1, 2, 3, 4, 5'),('thirteen — thirty','13 ile 30; vurgu farklıdır.'),('a hundred / a thousand','Yüz / bin.'),('Monday, Tuesday, Wednesday','Pazartesi, salı, çarşamba.'),('It is half past two.','Saat 2.30.')],
      'İngilizcede gün adlarının ilk harfi büyük yazılır: Monday, Friday.',
      '“Thirteen” ile “thirty” arasındaki fark nedir?', ['Aynı sayı','13 ve 30','30 ve 13','3 ve 13'], 1, 'Thirteen = 13, thirty = 30.'),
    _LessonContent('Ailem ve Sahiplik: my, your, have got', 11,
      'Aileni anlatırken sahiplik sıfatları ve “have got” kalıbı işe yarar. My = benim, your = senin, his = onun (erkek), her = onun (kadın).',
      [('mother, father, sister, brother','Anne, baba, kız kardeş, erkek kardeş.'),('This is my family.','Bu benim ailem.'),('My mother’s name is Fatma.','Annemin adı Fatma.'),('I have got two brothers.','İki erkek kardeşim var.'),('I haven’t got a pet.','Evcil hayvanım yok.')],
      'His/her seçerken sahip olan kişiye bak: Ali’nin annesi → his mother; Ayşe’nin arabası → her car.',
      '“Benim adım” nasıl denir?', ['me name','my name','I name','mine name'], 1, 'My, “benim” anlamına gelir.'),
    _LessonContent('Günlük Rutin — Geniş Zaman', 13,
      'Alışkanlıkları Present Simple ile anlatırız. He/she/it öznelerinde olumlu cümlede fiile genellikle -s eklenir: I work, she works.',
      [('I get up at seven o’clock.','Saat yedide kalkarım.'),('I have breakfast with my family.','Ailemle kahvaltı ederim.'),('I go to work by bus.','İşe otobüsle giderim.'),('She works in a hospital.','O bir hastanede çalışır.'),('She doesn’t like coffee.','O kahve sevmez.')],
      'Doesn’t geldiğinde fiil yalın kalır: “She doesn’t like coffee”, likeS değil.',
      '“He ___ in a bank.”', ['work','works','working','is work'], 1, 'He/she/it ile olumlu geniş zamanda fiile -s gelir.'),
    _LessonContent('Restoranda: Sipariş ve Rica', 11,
      'Restoranda kibarca sipariş vermek için “Can I have…?” ve “I would like…” kalıplarını kullan.',
      [('A table for two, please.','İki kişilik bir masa, lütfen.'),('Can I see the menu, please?','Menüyü görebilir miyim, lütfen?'),('I would like a soup and a salad.','Bir çorba ve salata istiyorum.'),('Can I have a glass of water?','Bir bardak su alabilir miyim?'),('The bill, please.','Hesap, lütfen.')],
      '“I want” doğrudur ama doğrudan gelebilir. Daha kibar olmak için “I’d like” veya “Can I have” de.',
      'Menüyü kibarca nasıl istersin?', ['Give me the menu','Can I see the menu, please?','Menu!','I want menu now'], 1, '“Can I…?” ve “please” kibar rica için kullanılır.'),
    _LessonContent('Yol Sorma ve Yön Tarifi', 11,
      'Yol sorarken “Where is…?”; tarif verirken “turn left”, “turn right” ve “go straight” ifadelerini öğren. “There is/are” bir şeyin varlığını anlatır.',
      [('Excuse me, where is the bus station?','Affedersiniz, otobüs durağı nerede?'),('Go straight ahead.','Düz devam edin.'),('Turn left at the traffic lights.','Trafik ışıklarından sola dönün.'),('It is next to the pharmacy.','Eczanenin yanında.'),('There are two banks on this street.','Bu caddede iki banka var.')],
      'Yol sormadan önce “Excuse me” diyerek kibarca dikkat çekebilirsin. “Sorry” özür içindir.',
      'Yabancıya yol sormadan önce ne denir?', ['Sorry','Excuse me','Hello you','Hey'], 1, 'Dikkat çekmek için “Excuse me” kullanılır.'),
    _LessonContent('Alışveriş: Fiyat Sorma ve Beden', 10,
      'Fiyat sormak için “How much is it?” kalıbını, kıyafet denemek için “Can I try it on?” ifadesini kullan.',
      [('How much is this?','Bu ne kadar?'),('How much are these shoes?','Bu ayakkabılar ne kadar?'),('That is too expensive!','Bu çok pahalı!'),('Do you have a cheaper one?','Daha ucuzu var mı?'),('Can I try it on?','Deneyebilir miyim?')],
      'Satıcı yardım teklif edince “I’m just looking, thank you” diyerek kibarca sadece baktığını söyleyebilirsin.',
      '“Bu ne kadar?” nasıl sorulur?', ['How many is this?','How much is this?','What money?','How this cost?'], 1, 'Fiyat sorusu: “How much is this?”'),
    _LessonContent('Geçmişten Bahsetme: was / were', 12,
      'Geçmişteki durumları anlatmak için am/is yerine was, are yerine were kullanılır. Yesterday ve last week gibi zaman ifadeleri yardımcı olur.',
      [('I was at home yesterday.','Dün evdeydim.'),('You were late this morning.','Bu sabah geç kaldın.'),('She was very tired last night.','Dün gece çok yorgundu.'),('We were in Antalya last summer.','Geçen yaz Antalya’daydık.'),('It wasn’t expensive.','Pahalı değildi.')],
      'How was your weekend? sorusuna “It was great!” gibi geçmiş zamanla cevap verebilirsin.',
      '“I ___ at home yesterday.”', ['were','was','am','is'], 1, 'I öznesi için am’in geçmişi olan was kullanılır.'),
  ];

  _LessonContent get _lesson => _lessons[widget.lessonIndex.clamp(0, _lessons.length - 1).toInt()];

  @override
  Widget build(BuildContext context) {
    final lesson = _lesson;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.transparent,
        title: Text('Ders ${widget.lessonIndex + 1}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxxl),
        children: [
          Text(lesson.title, style: AppTypography.displaySm),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            const Icon(Iconsax.clock, size: 16, color: AppColors.bodyMid),
            const SizedBox(width: AppSpacing.xs),
            Text('${lesson.minutes} dakika', style: AppTypography.bodySm),
            const SizedBox(width: AppSpacing.md),
            const Icon(Iconsax.book_1, size: 16, color: AppColors.bodyMid),
            const SizedBox(width: AppSpacing.xs),
            Text('${lesson.examples.length} örnek', style: AppTypography.bodySm),
          ]),
          const SizedBox(height: AppSpacing.xl),
          Text('Konu özeti', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.sm),
          Text(lesson.intro, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.xl),
          Text('Örnekleri incele', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.md),
          ...lesson.examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(example.$1, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(example.$2, style: AppTypography.bodySm),
              ]),
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: const Color(0xFFF1ECFF), borderRadius: BorderRadius.circular(13)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Iconsax.lamp_on, color: AppColors.accentPurple, size: 19),
                const SizedBox(width: AppSpacing.sm),
                Text('Öğrenme ipucu', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text(lesson.tip, style: AppTypography.bodySm),
            ]),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Kendini dene', style: AppTypography.displayXs),
          const SizedBox(height: AppSpacing.sm),
          Text(lesson.question, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          ...lesson.options.asMap().entries.map((entry) {
            final index = entry.key;
            final selected = _selectedAnswer == index;
            final correct = index == lesson.answerIndex;
            final color = _showAnswer && correct
                ? const Color(0xFFE1F5E8)
                : _showAnswer && selected
                    ? const Color(0xFFFCE8E6)
                    : selected
                        ? const Color(0xFFF1ECFF)
                        : AppColors.canvas;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _showAnswer ? null : () => setState(() => _selectedAnswer = index),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.accentPurple : AppColors.hairline)),
                  child: Row(children: [
                    Expanded(child: Text(entry.value, style: AppTypography.bodyMd)),
                    if (_showAnswer && correct)
                      const Icon(Iconsax.tick_circle, color: Color(0xFF16834A), size: 19),
                  ]),
                ),
              ),
            );
          }),
          if (_showAnswer) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_selectedAnswer == lesson.answerIndex ? 'Doğru! ${lesson.explanation}' : 'Doğru cevap: ${lesson.options[lesson.answerIndex]}. ${lesson.explanation}',
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMid)),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => setState(() { _selectedAnswer = null; _showAnswer = false; }),
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Tekrar dene'),
            ),
          ] else
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _selectedAnswer == null ? null : () => setState(() => _showAnswer = true),
              child: const Text('Cevabı kontrol et'),
            )),
        ],
      ),
    );
  }
}

class _LessonContent {
  const _LessonContent(this.title, this.minutes, this.intro, this.examples, this.tip, this.question, this.options, this.answerIndex, this.explanation);
  final String title;
  final int minutes;
  final String intro;
  final List<(String, String)> examples;
  final String tip;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}
