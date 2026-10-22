# Bubixo → Flutter: Veri Aktarımı ve Entegrasyon Planı

> Amaç: Mevcut Bubixo web projesindeki ders, kelime, gramer, hikâye, alıştırma, ses ve çeviri kaynaklarını Flutter uygulamasında yeniden kullanmak için uygulanabilir bir yol tanımlamak. Bu belge bir uygulama planıdır; Flutter dönüşümünün veya veri dönüştürme işleminin tamamlandığı anlamına gelmez.

## 1. Temel karar

Bubixo'nun mevcut eğitim içeriğinin çoğu bir içerik API'sinden gelmiyor; depodaki JavaScript dosyalarında tanımlanıyor. Ses ve cümle çevirisi gibi bazı özellikler uzak servislerden yararlanıyor. Öğrenci ilerlemesi ise web sürümünde tarayıcı localStorage alanında tutuluyor.

İlk Flutter sürümü için önerilen yaklaşım:

1. Yerel eğitim içeriklerini incele ve şemalarını belgele.
2. Verileri kayıpsız biçimde JSON'a dönüştür.
3. JSON dosyalarını Flutter uygulamasının asset'leri olarak yükle.
4. Ses ve çeviri servislerini ayrı veri kaynağı/repository katmanları üzerinden kullan.
5. Öğrenme ilerlemesini Flutter'da ayrı bir yerel depolama katmanına taşı.
6. Daha sonra gerçekten gerekirse merkezi içerik API'si ve hesap tabanlı senkronizasyon ekle.

**İçerik aktarımı ile uygulama davranışlarının taşınması farklı işlerdir.** JSON, metin ve yapılandırılmış veriyi taşır; arama, seviye filtresi, tekrar algoritması, ses eşleştirmesi, cevap kontrolü ve gezinme davranışları Flutter'da ayrıca uygulanmalıdır.

## 2. Mevcut veri kaynakları

| İçerik / özellik | Mevcut kaynak | Flutter'da önerilen karşılık |
|---|---|---|
| Temel dersler | data.js — UNITS | lessons.json + ders modeli |
| Kelime sözlüğü | data2.js — WORDS | words.json + kelime modeli |
| Gramer konuları | data2.js — TENSES ve ilişkili tanımlar | grammar.json + gramer modeli |
| Hikâyeler | data5.js — STORIES | stories.json + hikâye/cümle modelleri |
| Cümle kurma alıştırmaları | data6.js — BUILDER | sentence_builder.json + alıştırma modeli |
| Kelime oyunları | data7.js — GAMEWORDS | game_words.json + oyun kelimesi modeli |
| Hazır sesler ve eşleştirmeler | ses-icerik.js, ses.js, ses indeksi ve api.bubixo.com/audio/… | Ses manifesti + AudioRepository |
| Cümle çevirisi | https://api.bubixo.com/text-tools/translate | TranslationRepository üzerinden HTTP istemcisi |
| Kelime/ifade karşılıkları | Yerel sözlük ve gramer eşleştirmeleri | Flutter'da aynı davranışın yeniden uygulanması |
| Öğrenme ilerlemesi | localStorage anahtarı bx-eng | Yerel ProgressRepository |
| Çeviri geçmişi | localStorage anahtarı bx-eng-ceviri | Yerel çeviri geçmişi deposu |

Kaynak dosyalar ve servis davranışları için ayrıntılı mevcut durum belgesi: [Veri ve İçerik Kaynakları](BUBIXO-VERI-VE-ICERIK-KAYNAKLARI.md).

## 3. Önerilen Flutter asset yapısı

İlk sürümde içerik API'si kurmak yerine, sabit içerikleri uygulama paketine eklemek basit ve güvenilir bir başlangıçtır:

    assets/
    └── data/
        ├── lessons.json
        ├── words.json
        ├── grammar.json
        ├── stories.json
        ├── sentence_builder.json
        └── game_words.json

    lib/
    ├── core/
    │   ├── network/
    │   └── storage/
    └── features/
        ├── learning/
        │   ├── data/
        │   └── presentation/
        ├── words/
        │   ├── data/
        │   └── presentation/
        ├── practice/
        │   ├── data/
        │   └── presentation/
        └── discover/
            ├── data/
            └── presentation/

Bu bir başlangıç örneğidir; gerçek dosya ve klasör adları, Flutter projesinin mevcut mimarisiyle uyumlu hale getirilmelidir. Domain katmanı kullanılmayan bir mimaride sırf bu belge nedeniyle yeni katman eklemek gerekmez.

### pubspec.yaml kaydı

    flutter:
      assets:
        - assets/data/

Asset kaydının girintilerini koru ve dosyaların Flutter projesinde gerçekten bulunduğunu doğrula.

## 4. JSON'a dönüştürme kuralları

Dönüştürme işlemi, mevcut JavaScript verisini yüzeysel olarak kopyalamak değil; anlamını ve gerekli alanlarını korumak zorundadır.

1. **Önce şemayı çıkar.** Her dizideki nesnelerin alanlarını, alan türlerini, isteğe bağlı alanları ve birbirlerine olan bağlantılarını incele.
2. **Veri kaybını önle.** Alan adlarını, metinleri, noktalama işaretlerini, seviye etiketlerini, sıralamayı, cevapları, açıklamaları ve ses eşleştirmelerinde kullanılan tam metinleri koru.
3. **JavaScript ifadelerini ayıkla.** JSON; yorumları, fonksiyonları ve JavaScript'e özgü ifadeleri doğrudan desteklemez. Belirsiz değerleri sessizce değiştirme.
4. **Unicode'u koru.** Türkçe karakterler, apostroflar ve İngilizce özel karakterler doğru kodlanmalı.
5. **Kimlikleri kararlı tut.** İçeriklerde doğal ve güvenilir bir kimlik yoksa dönüştürme sırasında kararlı ID üret; her çalıştırmada değişen rastgele ID kullanma.
6. **Kaynak doğrulamasını ayır.** Verinin depoda bulunması, özgün yazarı veya lisansını kanıtlamaz. İçerik kaynağı ve yeniden kullanım izni ayrıca kontrol edilmelidir.
7. **Üretilen dosyaları doğrula.** Kayıt sayısını kaynakla karşılaştır; JSON parse testi ve örnek kayıt karşılaştırması yap.

Önerilen dosya isimleri örnektir. Gerçek alanlar kaynak şeması incelenmeden varsayılmamalıdır.

## 5. Flutter'da asset okuma örneği

Basitleştirilmiş bir JSON okuyucu:

    import 'dart:convert';
    import 'package:flutter/services.dart';

    Future<List<Map<String, dynamic>>> loadJsonList(
      String assetPath,
    ) async {
      final jsonString = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        throw const FormatException('Beklenen JSON üst düzey listesi.');
      }

      return decoded
          .map((item) {
            if (item is! Map) {
              throw const FormatException('Liste içinde nesne bekleniyordu.');
            }
            return Map<String, dynamic>.from(item);
          })
          .toList(growable: false);
    }

Kullanım:

    final words = await loadJsonList('assets/data/words.json');

Bu genel örnek, üretim kodundaki son çözüm olmak zorunda değildir. Gerçek alanları doğruladıktan sonra Word, Lesson, Story gibi güçlü tipli modeller ve bunları kullanan veri kaynakları oluşturulmalıdır. Hatalı kayıtları sessizce atmak yerine anlaşılır hata üretmek tercih edilir.

## 6. Veri katmanı ve sorumluluklar

- **Asset data source:** Paket içindeki JSON dosyalarını okur.
- **Local content repository:** Modelleri döndürür; içerik listelerini, kimlikleri ve filtreleme davranışlarını tek noktada yönetir.
- **Audio repository/service:** Hazır ses manifestini çözümler, uzaktaki sesi oynatır ve gerekirse önbellek davranışını yönetir.
- **Translation repository/service:** Mevcut çeviri endpoint'ine istek gönderir, hata ve erişilemezlik durumlarını yönetir.
- **Progress repository:** Ders tamamlanması, kelime tekrarları, hikâye durumu ve günlük seri gibi öğrenci durumunu kaydeder.
- **Presentation/controller:** Ekranın yükleniyor, başarı, boş ve hata durumlarını yönetir; dosya yolu veya HTTP ayrıntılarıyla doğrudan uğraşmaz.

Basit içerikler için ayrı bir backend zorunlu değildir. Ancak ekranlar JSON okuma, HTTP isteği yapma ve ilerleme kaydetme ayrıntılarını birbirine karıştırmamalıdır.

## 7. Ses entegrasyonu

Web sürümündeki SpeechSynthesis API'si Flutter'da doğrudan kullanılamaz; Flutter tarafında desteklenen bir metinden-sese çözümü veya mevcut MP3 dosyaları gerekir.

Önerilen sıra:

1. Ses manifestinin yapısını ve metin-ses eşleşme kuralını incele.
2. MP3 URL'lerinin Flutter istemcisinden erişilebilir olduğunu ve sunucu erişim kurallarını doğrula.
3. Hazır MP3 varsa onu oynat.
4. Gerekliyse ve izin verilen şekilde önbelleğe al.
5. Hazır ses yoksa platformun desteklediği TTS çözümünü yedek olarak değerlendir.
6. Çevrimdışı desteği ayrı ayrı test et; tüm seslerin otomatik çevrimdışı olacağını varsayma.

Metinlerdeki boşluk, apostrof veya noktalama değişiklikleri manifest eşleştirmesini etkileyebilir. Ses dosyalarını yeniden adlandırmadan ya da metinleri topluca normalleştirmeden önce bu bağımlılık doğrulanmalıdır.

## 8. Çeviri servisi ve güvenlik

Mevcut web istemcisi https://api.bubixo.com/text-tools/translate adresini kullanıyor. Flutter'da aynı servisi kullanmadan önce şu noktalar doğrulanmalıdır:

- Endpoint'in mobil istemciler için kullanımına izin veriliyor mu?
- İstek ve yanıt gövdeleri tam olarak nedir?
- Kimlik doğrulama veya erişim token'ı gerekiyor mu?
- Kota, hız sınırı, hata yanıtı ve zaman aşımı davranışı nedir?
- İstekler hangi verileri gönderiyor ve sunucu bunları nasıl işliyor?
- Servisin kullanım şartları ve gizlilik açıklaması nedir?

**Gizli API anahtarlarını veya sunucu sırlarını Flutter uygulamasına gömme.** Mobil uygulama içindeki değerler çıkarılabilir. Gizli anahtar gerektiren bir işlem varsa, uygun kimlik doğrulama ve kötüye kullanım kontrolleri olan sunucu tarafı bir aracı kullanılmalıdır. Mevcut endpoint'in sunucu kodu bu repoda bulunmadığı için gerçek sunucu güvenliği ve veri saklama politikası bu belgeyle doğrulanmış sayılmaz.

Yerel kelime eşleştirmesi ile cümle çevirisi farklı işlevlerdir. Flutter dönüşümünde ikisini tek bir çeviri API'si gibi ele almadan önce web sürümündeki mevcut davranış korunmalıdır.

## 9. Kullanıcı ilerlemesini taşımak

Web sürümündeki localStorage kayıtları Flutter'da otomatik olarak bulunmayacaktır. İlerleme modelini yeniden tanımlamak gerekir:

- tamamlanan dersler ve test sonuçları;
- öğrenilen/tekrar edilecek kelimeler ve tekrar tarihleri;
- hikâye ilerlemesi;
- oyun sonuçları;
- günlük seri için yerel tarih mantığı;
- çeviri geçmişi, ürün kapsamına dahilse.

Bunlar için yerel bir veritabanı veya uygun kalıcı depolama seçilebilir. Seçim veri hacmine, sorgu gereksinimlerine ve mevcut Flutter proje tercihine bağlıdır. Sadece küçük ayarlar için ağır bir veritabanı kurmak zorunlu değildir.

Web ve Flutter ilerlemesini birleştirmek istenirse bu ayrı bir göç/senkronizasyon tasarımıdır; hesap, veri şeması, çakışma çözümü ve gizlilik gerektirir.

## 10. Yerel JSON mu, içerik API'si mi?

| Ölçüt | Paket içindeki JSON | Merkezi içerik API'si |
|---|---|---|
| İnternet olmadan ilk yükleme | Uygun | Önbellek yoksa uygun değil |
| Yeni içeriği hemen yayımlama | Uygulama güncellemesi gerekir | Sunucu tarafında yayımlanabilir |
| İlk uygulama maliyeti | Daha düşük | Backend ve bakım gerekir |
| İçeriği merkezi yönetme | Daha sınırlı | Daha uygun |
| İçerik sürümü ve senkronizasyon | Uygulama sürümüyle gelir | Sürümleme tasarımı gerekir |
| Ağ hatalarına bağımlılık | İçerik okumada düşük | İçerik isteklerinde daha yüksek |

**Önerilen başlangıç:** Dersler, kelimeler, gramer, hikâyeler ve alıştırmalar için JSON asset'leri; çeviri ve mevcut hazır sesler için doğrulanmış uzak servisler; ilerleme için yerel kalıcı depolama. İleride içerik yönetimi veya cihazlar arası senkronizasyon ihtiyacı netleşirse API/CMS eklenebilir.

## 11. Aşamalı uygulama planı

### Aşama 1 — Kaynakları inceleme
- [ ] Her JavaScript veri dosyasının tam şemasını çıkar.
- [ ] Verilerin boyutunu, kayıt sayısını ve referanslarını ölç.
- [ ] Ses manifestinin veri biçimini ve ses URL'lerini doğrula.
- [ ] Çeviri servisi istek/yanıt sözleşmesini incele.
- [ ] İçerik kaynakları ve lisansları için bilinmeyenleri listele.

### Aşama 2 — JSON dönüşümü
- [ ] Kaynak dosyalar için tekrarlanabilir bir dönüştürme betiği yaz.
- [ ] JSON çıktılarının şema ve kayıt sayısı kontrollerini ekle.
- [ ] Kaynak ve hedef örnek kayıtları karşılaştır.
- [ ] Dönüşümde kayıp veya değiştirilmiş içerik bulunmadığını doğrula.

### Aşama 3 — Flutter veri katmanı
- [ ] JSON asset kayıtlarını ekle.
- [ ] Doğrulanmış şemalara göre modelleri oluştur.
- [ ] Asset data source ve repository katmanını kur.
- [ ] Yükleniyor, boş ve hata durumlarını test et.
- [ ] Arama ve seviye filtrelerinin mevcut web davranışını karşılaştır.

### Aşama 4 — Servisler ve kullanıcı durumu
- [ ] Ses oynatma ve yedek TTS davranışını uygula.
- [ ] Çeviri endpoint'ini doğrulanmış sözleşmeyle bağla.
- [ ] İlerleme ve kelime tekrar depolamasını ekle.
- [ ] Günlük seri tarih mantığını yerel takvimle test et.
- [ ] Çevrimdışı senaryoları test et.

### Aşama 5 — İçerik eşitliği ve regresyon
- [ ] Ders, kelime, gramer, hikâye ve alıştırma sayıları karşılaştırılır.
- [ ] Rastgele seçilen örnekler web sürümüyle karşılaştırılır.
- [ ] Ses eşleşmeleri ve çeviri hata durumları test edilir.
- [ ] Eski/eksik kayıtlar ve uygulama güncellemesi sonrası ilerleme kontrol edilir.

## 12. Tamamlanmış sayılma koşulları

Bu iş ancak şu koşullarda tamamlandı olarak işaretlenmelidir:

- Tüm kaynak veriler envanterlenmiş ve hedef şemaları belgelenmiş olmalı.
- Dönüşüm işlemi tekrar çalıştırılabilir olmalı.
- Kaynak/hedef kayıt sayıları ve örnek içerikler doğrulanmış olmalı.
- Flutter uygulaması gerçek veriyi asset/repository katmanından okumalı.
- Uzak servisler ve hata durumları gerçek cihazda veya uygun test ortamında denenmiş olmalı.
- İlerleme kalıcı olmalı ve yeniden açılışta korunmalı.
- Test edilmeyen özellikler tamamlandı gibi sunulmamalı.

---

**Durum:** Plan dokümante edildi. Bu belge tek başına Flutter uygulamasını oluşturmaz, JSON dosyalarını üretmez veya API'lerin mobil istemciden çalıştığını kanıtlamaz. Bunlar uygulama adımlarıdır ve ayrı ayrı gerçekleştirilip test edilmelidir.
