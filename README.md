# Bubixo

Bubixo, Türkçe konuşan kullanıcılara İngilizce öğretmeyi hedefleyen, tamamen
yerel çalışan bir Flutter uygulamasıdır. Dersler, hikâyeler, kelime listeleri,
cümle kurma ve kelime oyunları cihazda saklanır; yalnızca çeviri özelliği uzak
servise gider.

## Navigasyon

Uygulama tek bir alt navigasyon çubuğuyla dört sekmeyi açar:

| Sekme | İçerik |
| --- | --- |
| Öğren | Önerilen sonraki adım, öğrenme akışı ve ilerleme özeti. Temel dersler buradan açılır. |
| Kelimeler | Sözlük, çeviri ve kaydedilen/tekrar listesi. |
| Hikâyeler | Seviyeye göre filtrelenen kısa hikâyeler; kelime chip'leri listeye eklenir. |
| Pratik | Cümle kurma, kelime oyunları ve dil bilgisi. |

## Mimari

```
lib/
  core/
    database/     Drift bağlantısı, elle yazılmış SQL şema, içerik seeder'ı
    services/     ses (TTS) ve çeviri servisi
    theme/        tasarım token'ları (renk, boşluk, tipografi)
  features/
    <alan>/data/          repository + modeller
    <alan>/presentation/  ekranlar ve cubit'ler
    shell/                alt navigasyon iskeleti
```

- **Durum yönetimi:** flutter_bloc Cubit deseni (`LearnCubit`, `LessonsCubit`,
  `StoriesCubit`, `WordsCubit`, `StoryVocabularyCubit`). Ekranlar yalnızca UI
  durumunu (`setState`) tutar; veri okuma/yazma cubit ve repository'lerde kalır.
- **Kalıcılık:** Drift (^2.35) ile SQLite. Şema `lib/core/database/database_schema.dart`
  içinde elle yazılmış SQL'dir; drift_dev/build_runner kullanılmadığı için kod
  üretimi adımı yoktur. `DatabaseBootstrap.initialize()` bağlantıyı bir kez açar
  ve `ContentSeeder` ile paketteki JSON içeriğini tablolara yazar.
- **İçerik okuma:** Ders, hikâye, dil bilgisi ve pratik repository'leri önce
  veritabanını okur; veritabanı yoksa (web) veya okuma başarısız olursa paket
  içindeki JSON asset'lerine düşer.
- **Kullanıcı verisi:** Kelime listeleri (kaydedilenler, tekrar, özel kelimeler)
  veritabanındadır. Ders/hikâye/pratik ilerlemesi ve son aktivite bilgileri
  hâlâ SharedPreferences'te tutulur (bkz. Bilinen eksikler).

## Veri kaynakları

| Kaynak | İçerik | Kayıt sayısı |
| --- | --- | --- |
| `assets/data/lessons.json` | Temel dersler, örnekler, mini sınavlar | 10 ders · 86 örnek · 50 soru |
| `assets/data/stories.json` | Hikâyeler ve kelime eşleşmeleri | 12 hikâye · 3 seviye |
| `assets/data/grammar.json` | Dil bilgisi konuları | 6 konu · 29 örnek · 18 soru |
| `assets/data/sentence_builder.json` | Cümle kurma alıştırmaları | 120 alıştırma · 3 seviye |
| `assets/data/game_words.json` | Kelime oyunu havuzu | 240 kelime · 12 tema |
| `assets/data/words.json` | Sözlük | 3000 madde |

## Çalıştırma

```bash
flutter pub get
flutter run
```

Veritabanı ilk açılışta oluşturulur ve içerik tohumlanır; ayrı bir migrasyon
komutu gerekmez. Web sürümü veritabanını kullanmaz, içerik asset'lerinden okur.

## Doğrulama

- `dart format` ve `flutter analyze` temiz (`flutter analyze` => No issues found).
- `flutter build bundle --debug` ile Dart derlemesi doğrulanır.
- İçerik sorguları, gerçek v1 şeması üzerinde `sqlite3` ile çalıştırılıp
  kolon/eşleşme hataları denendi.
- **Testler bu kapsamda çalıştırılmadı.** `test/widget_test.dart` ve
  `test/words_screen_test.dart`, `testWidgets` içinde gerçek (fake-async
  dışı) dosya I/O'sı yaptıkları için deadlock'a girer ve `flutter test`
  tamamlandığı görülmeden zaman aşımına uğrar; `flutter analyze` ve derleme
  doğrulaması bundan bağımsızdır.

## Bilinen eksikler

- Ders tamamlama, sınav denemeleri, hikâye okuma ve pratik oturum sayıları
  hâlâ SharedPreferences anahtarlarında (`bubixo.learning.*`,
  `bubixo.practice.*`, `bubixo.read_story_ids`) duruyor. Bu veriler için
  şemada `lesson_progress`, `lesson_quiz_attempts`, `story_progress`,
  `practice_sessions` ve `learning_stats` tabloları hazır; taşımak ek bir
  göç adımı ve doğrulama ister.
- Kelimeler sekmesi, özel kelime listesi için hem preferences hem veritabanı
  yazan eski okuma yolunu korur (`bubixo.custom_words` kurtarma kopyasıdır).
- Hikâye/pratik ekranlarında ses, cihazda uygun bir TTS motoru yoksa sessizce
  atlanır; hata durumu kullanıcıya gösterilmez.
