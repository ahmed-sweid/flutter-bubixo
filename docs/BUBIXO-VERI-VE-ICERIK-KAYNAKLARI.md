# Bubixo — Veri ve İçerik Kaynakları

> İnceleme kapsamı: `ux/four-tab-navigation` dalındaki istemci kodu. Bu belge, depoda görülebilen veri tanımlarını ve kodda açıkça kullanılan uzak servisleri ayırır. Sunucu tarafı kaynak kodu ve içeriklerin ilk yazım/üretim kayıtları depoda bulunmadığından, doğrulanamayan içerik kökenleri kesin bilgi gibi sunulmaz.

## Kısa cevap

Bubixo tek bir dış eğitim API'sinden beslenen bir uygulama değil. İçeriğin büyük bölümü JavaScript dosyalarıyla birlikte depoda geliyor; kullanıcının ilerlemesi tarayıcıda saklanıyor. Bazı özellikler Bubixo'nun kendi alan adındaki servislerden ses veya çeviri alıyor. Ses dosyası bulunamazsa tarayıcının konuşma sentezi kullanılabiliyor.

| Veri / özellik | Kaynak | Çalışma biçimi |
|---|---|---|
| Temel dersler | `data.js` içindeki `UNITS` | Sayfa yüklenirken yerel JavaScript verisi olarak okunur |
| Kelime sözlüğü ve gramer | `data2.js` içindeki `WORDS`, `TENSES` ve ilgili tanımlar | Yerel veri; sözlük araması ve alıştırmalar istemcide işlenir |
| Sesli hikâyeler | `data5.js` içindeki `STORIES` | Metin, Türkçe karşılık ve kelime eşleştirmeleri depodadır |
| Cümle kurma alıştırmaları | `data6.js` içindeki `BUILDER` | Yerel soru-cevap ve açıklama verisi |
| Kelime oyunları | `data7.js` içindeki `GAMEWORDS` | Yerel tema/kelime listesi; görsellerin çoğu emoji karakteriyle gösterilir |
| Hazır konuşma sesleri | `ses-icerik.js` ve `https://api.bubixo.com/audio/…` | Metin ve ses eşleştirmesi manifestte; MP3 dosyaları Bubixo API alan adından istenir |
| Ses yedeği | Tarayıcı `speechSynthesis` | Hazır MP3 bulunmadığında cihaz/tarayıcıdaki İngilizce ses kullanılır |
| Cümle çevirisi | `https://api.bubixo.com/text-tools/translate` | Uzak servis isteği; istemci kodu bunu Bubixo'nun mevcut çeviri servisi olarak tanımlar |
| Kelime altı karşılıkları | Yerel `WORDS` ve `GAMEWORDS` sözlükleri + küçük gramer eşleme tablosu | Cümle çevirisinden ayrı olarak, tarayıcıda yaklaşık eşleştirme yapılır |
| Öğrenci ilerlemesi | Tarayıcı `localStorage`, anahtar `bx-eng` | Kullanıcının cihazında/tarayıcısında tutulur; mevcut kodda hesap tabanlı ilerleme API'si yok |
| Çeviri geçmişi | Tarayıcı `localStorage`, anahtar `bx-eng-ceviri` | Son çeviriler yerelde saklanır |
| Çeviri paneli token/erişim kontrolü | Bubixo text-tools servisi | İstemci servisle erişim kontrolü yapar; sunucu uygulaması depoda yer almaz |
| Yazı tipi | Google Fonts, Inter | İnternet bağlantısı olduğunda Google Fonts'tan yüklenir |
| Kurs görselleri ve ikonlar | Depodaki statik varlıklar | HTML/CSS ve yerel dosyalar üzerinden yüklenir |

## 1. Depoda bulunan eğitim içeriği

### `data.js` — temel dersler

Dosya, `UNITS` dizisinde yapılandırılmış ders içeriğini tanımlar. Derslerde başlık, tahmini süre, Türkçe giriş/açıklama, İngilizce örnekler, telaffuz ipuçları ve çoktan seçmeli sorular bulunur. İçerik uygulama açılırken HTML içindeki script etiketiyle yüklenir; ders metinleri için her açılışta ayrı bir içerik API'sine başvurulduğu görülmüyor.

### `data2.js` — kelime sözlüğü ve gramer

Dosyada `WORDS` sözlük verisi ve `TENSES` gramer konuları bulunur. Sözlük girdileri İngilizce kelimeyi ve Türkçe karşılığını taşır; bazı özellikler bu veriden anlam, arama, tekrar ve yanlış cevap seçenekleri üretir. Projenin arayüzü yaklaşık 3.000 kelimelik sözlük olarak tanıtır.

Önemli ayrım: kodda sözlüğün uygulama içindeki biçimi görülebilir, ancak her kelimenin ilk olarak hangi sözlükten, kitaptan veya veri kümesinden alındığını kanıtlayan bir kaynakça/atıf listesi bu dosyalarda görünmüyor. Bu nedenle belirli bir yayın ya da sözlükten geldiğini varsaymamak gerekir.

### `data5.js` — sesli hikâyeler

`STORIES` dizisi hikâyelerin başlığını, Türkçe başlığını, seviyesini, giriş açıklamasını ve cümlelerini içerir. Cümlelerde İngilizce metin (`en`), Türkçe karşılık (`tr`) ve kelime/ifade düzeyindeki eşleşmeler (`w`) birlikte tanımlanır. Böylece hikâyede kelime kelime takip, yalnızca uzaktaki bir çeviri servisine bağlı olmadan yapılabilir.

### `data6.js` — cümle kurma

`BUILDER` dizisi Türkçe cümle anlamını, İngilizce hedef dizilimini, soru kategorisini, zorluk seviyesini, olası çeldiricileri ve cevap sonrası dilbilgisi açıklamasını içerir. Oyun, doğru cevabı bu yerel hedef metinle karşılaştırır; kodda bu alıştırmaların oluşturulması için zorunlu bir uzak API çağrısı görünmez.

### `data7.js` — kelime oyunları

`GAMEWORDS` dizisinde İngilizce kelime, Türkçe karşılık ve tema bilgisi bulunur. Dosyanın açıklaması, oyun sözlüğünün büyük bölümünün `data2.js` sözlüğüyle örtüşecek şekilde hazırlandığını belirtir. Görsel alanı yoksa oyunlarda emoji karakterleri kullanılabilir; bu, her kelime için ayrı bir fotoğraf API'si kullanıldığı anlamına gelmez.

### İçeriğin yazarı / ilk kaynağı

Depoda içerik verileri bulunuyor; fakat dosyalarda her ders, kelime, gramer açıklaması ve hikâye için sistematik kaynak URL'si, yayın adı, lisans veya üretim kaydı yok. Bu yüzden **“bütün içerik şu belirli kaynaktan alınmıştır”** demek mevcut kod kanıtlarıyla mümkün değil. İçeriklerin bir kısmı proje içinde yazılmış veya düzenlenmiş olabilir; bunun oranını ya da ilk kaynaklarını yalnızca bu dosyalardan kesinleştiremeyiz. Yayın öncesi içerik kaynağı ve lisans denetimi yapılması gerekir.

## 2. Sesler nereden geliyor?

Ses sistemi iki katmanlıdır.

### Hazır MP3 dosyaları

- `ses-icerik.js`, otomatik üretilmiş bir içerik manifestidir. Dosya başındaki açıklama, kaynağının `tools/icerik_kaynak.js` ve üreticisinin `tools/manifest_uret.js` olduğunu yazar. Bu kaynak/üretici dosyaları ilgili dalda mevcut değilse manifestin nasıl üretildiğini bütünüyle doğrulamak mümkün değildir.
- Manifest, İngilizce metinleri MP3 dosya adlarıyla eşleştirir ve `https://api.bubixo.com/audio/en/v1/` ile `v2/` köklerini tanımlar.
- `ses.js`, `audio/en/audio-index.json` indeksini almaya çalışır; metnin hash'i üzerinden ilgili sesin `c` veya `d` ses grubunda bulunup bulunmadığını kontrol eder. Eşleşme varsa MP3 çalar.
- `yol.js` açıklamasında hazır kurs seslerinin ElevenLabs MP3'leri olduğu belirtilir. Bu, istemci kodundaki açıklamaya dayalı bilgidir; MP3'lerin üretim kayıtları veya sağlayıcı hesabı bu depodan bağımsız olarak doğrulanmış değildir.

### Tarayıcı metinden sese (TTS)

Hazır ses bulunamazsa `ses.js`, `speechSynthesis` katmanını kullanarak tarayıcının kendi metinden-sese işlevine geri döner. `app.js` İngilizce bir ses seçmeye çalışır; mevcut sesler işletim sistemine, tarayıcıya ve yüklenmiş ses paketlerine göre değişebilir. Bu nedenle her cihazda aynı ses veya aynı telaffuz kalitesi garanti edilmez. TTS kullanılması, her cümle için ayrıca bir ses dosyası indirildiği anlamına gelmez.

### Çevrimdışı ses

PWA kodu, özellikle hikâye seslerini indirme ve önbelleğe alma akışı içerir. Açıklamada kelime sözlüğünün tamamının ses paketine dahil olmadığı belirtilir. Dolayısıyla çevrimdışı çalışma tüm seslerin ve tüm uzak servislerin çevrimdışı olduğu anlamına gelmez.

## 3. Çeviri nereden geliyor?

`ceviri.js` dosyasındaki açıklama, mevcut çeviri servisinin `https://api.bubixo.com/text-tools/translate` adresinde olduğunu ve bunun Bubixo'nun mevcut `bubixo-text-tools` servisi olduğunu söyler. İstemci, Türkçe → İngilizce ve İngilizce → Türkçe yönleriyle metin gönderir. Kurs içindeki kısa çeviri kutusu 300 karakterlik bir istemci sınırı uygular; dosya, servis tarafının daha uzun metinleri kabul edebildiğini de belirtir. Tam çevirmen bağlantısı `https://api.bubixo.com/ceviri/` adresidir.

İstemci kodu servisin OpenAI tabanlı olduğunu belirten bir yorum içerir (`gpt-5.6-luna` ifadesi). Ancak API sunucusunun kodu depoda bulunmadığından model, sistem talimatları, veri saklama politikası, istek günlükleri, sağlayıcıya gönderilen tam alanlar ve sunucu tarafındaki güvenlik/limitler yalnızca bu repodan bağımsız biçimde denetlenemez. Bu nedenle bu ayrıntılar için istemci yorumunu kesin bir sunucu denetimi gibi değerlendirmemek gerekir.

### Kelime altı çeviri farklı çalışır

Cümle çevirisi API'sinden farklı olarak, metnin altında kelime/ifade karşılıkları oluşturulurken `ceviri.js` önce `WORDS` ve `GAMEWORDS` listelerine, ardından küçük bir gramer eşleme tablosuna bakar. Bu işlem yaklaşık bir yerel eşleştirmedir; bağlamı anlayan tam bir dil modeli çevirisi değildir. Sözlükte bulunmayan kelimeler boş kalabilir veya tam bağlama uygun olmayan bir karşılık alabilir.

Çeviri panelinin son birkaç sonucu `bx-eng-ceviri` anahtarıyla yerel depoya yazılır. Kodda servis erişilemiyorsa çeviri düğmesinin gizlenebileceği de belirtilir.

## 4. Mikrofon ve konuşma özellikleri

Konuşma/telaffuz deneyiminde iki tarayıcı kabiliyeti söz konusu olabilir:

- **Metinden sese:** `SpeechSynthesis` / `SpeechSynthesisUtterance` ile metni sesli okuma; hazır MP3 mevcutsa ses katmanı onu seçebilir.
- **Sesi metne tanıma:** ilgili özellik, tarayıcının desteklediği konuşma tanıma API'sine bağlıdır. Tarayıcı desteği, mikrofon izni ve ağ gereksinimleri platforma göre değişebilir.

Bu kodlar tek başına, sunucuda eğitilmiş özel bir telaffuz modeli bulunduğunu veya kullanıcının konuşmasının bilimsel olarak puanlandığını kanıtlamaz. Rehberli konuşma senaryolarında tamamlanma/cevap kontrolleri bulunması, genel amaçlı ve sınırsız bir AI sohbet sistemiyle aynı şey değildir.

## 5. Kullanıcı verisi nerede tutuluyor?

`app.js`, uygulama durumunu `localStorage` içindeki `bx-eng` anahtarından okur/yazar. Ders sonuçları, öğrenilen kelimeler, hikâye durumu, oyun ve günlük seri gibi alanlar burada tutulur. `yol.js` de aynı depolama katmanı altında `S.yol` alanını kullanır. `ceviri.js` ise çeviri geçmişi için ayrı `bx-eng-ceviri` anahtarı kullanır.

Bunun sonuçları:
- Mevcut istemci uygulamasında ilerleme, varsayılan olarak kullanıcının o tarayıcısına/cihazına bağlıdır.
- Tarayıcı verisi silinirse veya kullanıcı farklı bir cihaza geçerse ilerleme otomatik olarak eşitlenmeyebilir.
- Repodaki `yol.js` açıklaması, hesap tabanlı `APIProgressStore` fikrini TODO olarak gösterir ve şu an sunucu tarafı ilerleme deposu olmadığını söyler.
- Çeviri özelliği ayrı bir uzak servisle çalışır; bu yüzden “ilerleme yerelde saklanıyor” ifadesi, uygulamanın hiçbir ağ isteği yapmadığı anlamına gelmez.

## 6. PWA, önbellek ve harici kaynaklar

- `sw.js` service worker üzerinden statik kaynakları ve desteklenen içerikleri önbelleğe alır; uzak API istekleri ile sıradan statik dosyalar aynı davranışta değildir.
- `pwa.js` çevrimdışı durumu gösterme, yeni sürüm bildirimi, kurulum daveti ve hikâye seslerini indirme arayüzünü yönetir.
- `index.html`, Inter yazı tipini Google Fonts üzerinden yükler. Ağ veya servis erişimi yoksa bu tür harici kaynaklar yüklenemeyebilir; tarayıcı yedek yazı tipi kullanabilir.
- Kursun temel ders ve alıştırma verileri depodaki JavaScript dosyalarında bulunduğundan, bu içerikler her görüntüleme için ayrıca bir içerik API'sinden alınmıyor.

## 7. Kaynak doğrulama sınırları ve yapılması gerekenler

Bu inceleme istemci kodunda görülen bağlantıları, veri yapılarını ve açıklamaları esas alır. Şu konular bu depodan tek başına kesinleştirilemez:

1. Her dersin, örnek cümlenin, kelime karşılığının ve hikâyenin ilk kaynağı/yazarı.
2. Her ses dosyasının üretim tarihi, üretim ayarları ve sağlayıcıya ait doğrulama kayıtları.
3. Çeviri sunucusunun gerçek model yapılandırması, saklama süresi, günlükleme ve gizlilik uygulaması.
4. Sunucu tarafında rate limit, kimlik doğrulama, kötüye kullanım koruması ve yedekleme politikaları.
5. Üçüncü taraf ses, font ve içeriklerin kullanım/lisans koşullarının proje için uygunluğu.

Ürün yayımlanmadan önce önerilen kayıt formatı: içerik kimliği, içerik türü, yazar/sağlayıcı, özgün kaynak URL'si veya üretim yöntemi, oluşturulma/güncellenme tarihi, lisans/izin durumu ve doğrulama notu. Kaynağı bilinmeyen içerikler, kaynak bilgisi bulunana kadar “kaynağı doğrulanmadı” olarak işaretlenmelidir.

## Kodda bakılacak yerler

- `index.html`: uygulamanın yüklediği script sırası ve Google Fonts bağlantısı.
- `data.js`: `UNITS` — dersler.
- `data2.js`: `WORDS` ve `TENSES` — sözlük ve gramer.
- `data5.js`: `STORIES` — hikâyeler.
- `data6.js`: `BUILDER` — cümle kurma.
- `data7.js`: `GAMEWORDS` — oyun kelimeleri.
- `ses-icerik.js`: hazır ses metni/dosya eşleştirmeleri ve ses sunucusu kökleri.
- `ses.js`: MP3 indeksi, hash eşleştirme ve TTS geri dönüşü.
- `ceviri.js`: uzak çeviri servisi ve yerel kelime altı eşleştirmeleri.
- `app.js`: yerel ilerleme deposu ve konuşma sentezi.
- `yol.js`: öğrenme yolu, ilerleme mantığı ve ses manifestinin yüklenmesi.
- `pwa.js`, `sw.js`: kurulum, önbellek, çevrimdışı davranış ve ses indirme.
