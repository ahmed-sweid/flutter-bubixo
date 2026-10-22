# Bubixo — Ürün ve Fikir Odaklı Derin Analiz

> **Belge türü:** Ürün stratejisi, öğrenme deneyimi, UX ve geliştirme fikirleri  
> **İncelenen sürüm:** `ux/four-tab-navigation` dalındaki mevcut web/PWA kodu ve içerik dosyaları  
> **Amaç:** Hemen yeni özellik eklemek değil; Bubixo'nun neye dönüşmesi gerektiğini, hangi sorunları çözmesi gerektiğini ve hangi fikirlerin gerçekten değer üreteceğini belirlemek.

---

## 0. Bu belgenin nasıl okunması gerekiyor?

Bu analizde üç tür ifade birbirinden ayrılır:

- **Mevcut durum:** Kodda, içerik dosyalarında veya sayfa metinlerinde görülebilen özellikler.
- **Ürün yorumu:** Mevcut tasarımın kullanıcıya ne hissettirebileceği veya hangi sorunu doğurabileceği hakkındaki değerlendirme. Gerçek kullanıcı testi yapılmadığı için bunlar doğrulanmış kullanıcı bulguları değildir.
- **Öneri:** Henüz var olduğu varsayılmayan, gelecekte değerlendirilebilecek fikir.

Bu ayrım önemli. Bir özelliğin kodda bulunması, kullanıcının onu kolayca anladığı veya öğrenmeye katkı sağladığı anlamına gelmez. Aynı şekilde iyi bir fikir, sırf kulağa hoş geldiği için geliştirme listesine alınmamalıdır.

## 1. Yönetici özeti

Bubixo'nun en değerli yanı tek bir egzersiz türüne sıkışmamasıdır. Üründe A1–A2 düzeyine yönelik Türkçe anlatımlar, yapılandırılmış öğrenme yolu, sesli kelime sözlüğü, kelime tekrar sistemi, gramer anlatımları, cümle kurma etkinlikleri, hikâyeler, oyunlar ve telaffuz çalışmaları bulunuyor. Öğrenme ilerlemesi tarayıcıdaki `localStorage` üzerinden saklanıyor; PWA katmanı çevrimdışı çalışma ve kuruluma yönelik davranışlar içeriyor.

Bu bileşim iyi bir temel. Ancak çok sayıda öğrenme aracına sahip olmak kendi başına bütünlüklü bir öğrenme deneyimi yaratmaz. Ürünün temel sorusu şu olmalı:

**Kullanıcı bugün Bubixo'yu açtığında, seviyesine ve önceki çalışmalarına uygun bir sonraki adımı ne kadar kolay buluyor; o adımı bitirdiğinde ne öğrendiğini ve yarın neden geri gelmesi gerektiğini anlıyor mu?**

Bubixo'nun gelişim fırsatı, yeni bölümler eklemekten önce mevcut parçaları tek bir anlaşılır öğrenme döngüsünde birleştirmektir:

1. Kullanıcıya anlamlı bir başlangıç noktası sun.
2. Kısa ve net bir çalışma yaptır.
3. Öğrenilen şeyi hatırlamasını veya kullanmasını iste.
4. Sonucu anlaşılır biçimde geri bildir.
5. Öğrenilenleri uygun zamanda tekrar gündeme getir.
6. Bir sonraki oturumu kolayca başlat.

Bu döngü sağlamlaşırsa sözlük, hikâye, gramer ve oyunlar birbirinden kopuk araçlar olmaktan çıkar; aynı öğrenme amacına hizmet eden farklı yollar olur.

### Stratejik karar

Bubixo'yu “çok sayıda ücretsiz İngilizce materyali sunan site” olarak bırakmak yerine, **Türkçe konuşan başlangıç düzeyindeki öğrencinin günlük İngilizce öğrenme alışkanlığı kurmasına yardım eden, ses ve bağlamı merkeze alan sade bir öğrenme ortamı** olarak konumlandırmak daha güçlü bir yön olabilir.

Bu konumlandırma bir öneridir; kullanıcı araştırması ve ürün testleriyle doğrulanmalıdır.

---

## 2. Ürünün mevcut temeli

### 2.1. Öğrenme yolu

Kodda A1'den A2'ye ilerleyen beş bölümlü bir öğrenme yolu, bölüm içi etkinlikler ve devam etme mantığı bulunuyor. Ana ekranda önceki çalışmaya devam etme veya ilk derse başlama gibi durumlara göre farklı içerik üretilebiliyor.

**Değeri:** Başlangıç düzeyindeki öğrencinin “Nereden başlamalıyım?” sorusunu azaltabilir. Öğrenci her seferinde kendisi bir içerik seçmek zorunda kalmaz.

**Risk:** Öğrenme yolu, içeriklere açılan bir menüden ibaret kalırsa rehberlik etkisi zayıflar. Kullanıcı hangi etkinliğin neden sırada olduğunu, ne kadar süreceğini ve bitirince ne kazanacağını anlamalıdır.

### 2.2. Kelime sözlüğü ve tekrar

İçerik dosyalarında yaklaşık 3000 kelimelik sözlük iddiası, seviyelere göre gruplama, arama, ses oynatma ve kelime tekrarına ilişkin durumlar bulunuyor. Tekrar mantığı kelimeleri “Yeni”, “Öğreniliyor”, “Tekrar zamanı” ve “Öğrenildi” gibi durumlarla takip ediyor.

**Değeri:** Kelime öğrenmeyi tek seferlik okumadan çıkarıp zaman içinde tekrar edilen bir faaliyete dönüştürme potansiyeli var.

**Risk:** 3000 kelime sayısı ürünün kapasitesini anlatır ama öğrencinin gerçek ilerlemesini anlatmaz. Kullanıcı uzun bir liste karşısında nereden başlayacağını bilemeyebilir. Ayrıca bir kelimeyi bir kez doğru yanıtlamak, onu kalıcı olarak öğrendiğini kesin biçimde göstermez.

### 2.3. Gramer ve cümle kurma

Gramer verileri açıklamalar, örnekler ve sorular içeriyor. Cümle kurma etkinliklerinde kullanıcı Türkçe cümleden hareketle İngilizce kelimeleri doğru sıraya yerleştiriyor ve sonrasında kural açıklaması görebiliyor.

**Değeri:** Pasif okuma yerine öğrenciden bir işlem yapmasını ister. Cümle sırası gibi Türkçe ile İngilizce arasında farklılık gösteren konularda bu yaklaşım yararlı olabilir.

**Risk:** Kelimeleri doğru sıraya koymak, öğrencinin aynı yapıyı yardımsız biçimde yeni bir cümlede kullanabildiği anlamına gelmez. Etkinlikler giderek daha serbest üretime geçiş sağlamalıdır.

### 2.4. Hikâyeler ve dinleme

Hikâye içeriklerinde İngilizce cümleler, Türkçe karşılıklar ve bazı içeriklerde kelime/ifade düzeyinde eşleştirmeler bulunuyor. Mevcut ses sistemi kayıtlı ses varlıklarını kullanıyor; içerik metninin ses dosyasıyla birebir eşleşmesi teknik açıdan önem taşıyor.

**Değeri:** Kelimeyi tek başına değil, anlamlı bağlamda görme ve dinleme imkânı verir. Öğrenci dilbilgisi yapısını gerçek bir metnin içinde gözlemleyebilir.

**Risk:** İngilizce cümlenin hemen altında sürekli Türkçe karşılık bulunması, öğrencinin anlamı kendisinin çıkarmasını denemeden çeviriye yönelmesine neden olabilir. Bunun gerçekten yaşanıp yaşanmadığı test edilmelidir; çözüm Türkçeyi tamamen kaldırmak değil, gerektiğinde açılan bir yardım hâline getirmeyi denemek olabilir.

### 2.5. Oyunlar ve telaffuz

Kelime oyunları kısa oturumlara uygun şekilde tasarlanmış. Telaffuz ve dinleme tarafında mevcut cümleleri sesli dinleme, sesle takip etme ve belirli senaryolara dayalı pratikler bulunuyor. Kodda “AI ile konuşma pratiği” yönünde bir arayüz/iskelet de var; ancak serbest, gerçek bir AI sohbeti tamamlanmış özellik olarak kabul edilmemeli. İlgili kodda henüz tamamlanması gereken noktalar işaretlenmiş.

**Değeri:** Aynı öğrenme malzemesine farklı biçimlerde dönmeyi sağlar ve monotonluğu azaltabilir.

**Risk:** Oyunlar yalnızca doğru cevabı bulma eğlencesi sunarsa öğrenme hedefinden kopabilir. Konuşma pratiği ise arayüzde bulunmasıyla gerçek, güvenilir konuşma değerlendirmesi sunması arasında büyük fark olan bir alandır.

### 2.6. PWA ve yerel ilerleme

Uygulama, ilerlemeyi tarayıcıdaki `localStorage` içinde tutuyor. PWA katmanı servis çalışanı, önbellek, çevrimdışı bilgilendirme ve kurulum deneyimi için kod içeriyor.

**Değeri:** Hesap açmadan hızlı başlama, hafif çalışma ve bazı içeriklere çevrimdışı erişim ürünün erişilebilirliğini artırabilir.

**Risk:** Yerel kayıt, aynı tarayıcı/cihaz dışında ilerlemenin otomatik olarak taşınacağı anlamına gelmez. Tarayıcı verisi silinirse veya cihaz değişirse ilerleme kaybolabilir. Çevrimdışı çalışmanın hangi içeriklerde gerçekten mümkün olduğu da cihaz ve ağ koşullarında test edilmelidir.

---

## 3. Ürünün çözmesi gereken asıl kullanıcı problemi

Başlangıç düzeyindeki İngilizce öğrencisi çoğu zaman materyal eksikliğinden değil, **materyali doğru sırayla kullanma, öğrendiğini hatırlama ve devamlılık kurma** zorluğundan dolayı ilerlemekte zorlanır.

Bubixo'nun çözmeye odaklanabileceği sorunlar:

1. **Başlangıç belirsizliği:** “Bugün ne çalışayım?”
2. **Aşırı seçenek:** “Sözlük mü, gramer mi, hikâye mi, oyun mu?”
3. **Pasif tanıma ile gerçek hatırlama arasındaki fark:** “Kelimeyi görünce biliyorum ama kendim söyleyemiyorum.”
4. **Bağlam eksikliği:** “Kelimenin anlamını biliyorum ama cümlede nasıl kullanıldığını bilmiyorum.”
5. **Tekrar zamanını kaçırma:** “Daha önce çalıştığım kelimeleri ne zaman tekrar etmeliyim?”
6. **İlerlemeyi anlayamama:** “Bugün yaptığım çalışma beni gerçekten ileri götürdü mü?”
7. **Ara verdikten sonra geri dönememe:** “Bir süredir kullanmadım; yeniden nereden başlamalıyım?”
8. **Hata yapma kaygısı:** “Yanlış cevabı neden verdiğimi bilmiyorum.”
9. **Düşük algılanan değer:** “Ücretsiz ve içerik dolu ama düzenli kullanmaya değer mi?”

Bu problemler, ürünün bütün fikirlerini değerlendirmek için bir filtre olarak kullanılmalı. Yeni özellik bunlardan birini belirgin biçimde çözmüyorsa önceliği düşük olabilir.

---

## 4. Önerilen ürün ilkeleri

### İlke 1 — Her ekranın birincil amacı olsun

Ekran, bütün özellikleri aynı anda sergilemek zorunda değil. Kullanıcıya tek bir temel eylem önerilmeli; ikincil seçenekler erişilebilir kalmalı ama yarışmamalıdır.

### İlke 2 — İçeriği değil, bir sonraki adımı öne çıkar

“3000 kelimelik sözlük” bir kaynak özelliğidir. “Bugün daha önce çalıştığın 6 kelimeyi tekrar et, sonra 4 yeni kelime öğren” ise eyleme dönük bir öneridir. İkinci yaklaşım, sistem bunu güvenilir biçimde hesaplayabildiği sürece daha yardımcı olabilir.

### İlke 3 — Kullanıcıya nedenini açıkla

Bir etkinlik önerildiğinde kısa bir gerekçe verilebilir: “Bu kelimeler tekrar zamanı geldiği için” veya “Bu alıştırma az önce öğrendiğin cümle sırasını pekiştiriyor.” Açıklama uzun bir öğretmen konuşmasına dönüşmemeli.

### İlke 4 — Hata, bir sonraki öğrenme fırsatıdır

Yanlış cevaba yalnızca kırmızı işaret koymak yerine, doğru cevabı ve kısa nedenini göster. Ardından kullanıcıya aynı kuralı farklı bir örnekte yeniden deneme fırsatı sun.

### İlke 5 — Hatırlamayı görünür kıl

İlerleme yalnızca tamamlanan ders veya açılan kelime sayısıyla ölçülmemeli. Kullanıcının daha önce öğrendiği bir şeyi zaman geçtikten sonra yardımsız hatırlayıp hatırlayamadığı da değerlendirilmelidir.

### İlke 6 — Sade arayüz, basit öğrenme demek değildir

Görsel arayüz sade olabilir; fakat arka plandaki öğrenme mantığı düşünülmüş olmalıdır. Öğrenciyi gereksiz ayarlarla yormadan seviye, tekrar ve ilerleme için yeterli kararlar alınabilir.

### İlke 7 — Özellik sayısından çok bütünlük

Aynı kelime sözlükte, hikâyede, dinleme etkinliğinde ve cümle kurma alıştırmasında karşılaşılabiliyorsa bunların birbirini desteklemesi gerekir. Dört bağımsız araçtan çok, birbirini besleyen dört temas noktası daha değerlidir.

---

## 5. Dört ana sekmenin ürün içindeki rolü

Bu bölüm, dört sekmeli bilgi mimarisini temel alır: **Öğren, Kelimeler, Pratik, Keşfet.** Sekmelerin amacı birbirinin aynısı olan dört içerik listesi yaratmak değil, kullanıcıya farklı türde dört soru için net yanıt vermektir.

### 5.1. Öğren — “Şimdi ne yapmalıyım?”

Bu, ana çalışma alanı ve karar yükünü azaltan ekran olmalıdır.

**Önerilen içerik sırası:**

1. Kaldığı yerden devam et veya ilk çalışma çağrısı.
2. Bugün için tek bir ana öneri.
3. Tekrar zamanı gelen kelimeler varsa kısa bir hatırlatma.
4. Öğrenme yolundaki mevcut bölüm ve bir sonraki kilometre taşı.
5. İsteğe bağlı alternatifler: kısa çalışma, hikâye veya serbest keşif.

**Önemli davranışlar:**

- Devam düğmesi kullanıcıyı tam olarak kaldığı anlamlı yere götürmeli; genel bir ana sayfaya atmamalı.
- İlerleme bilgisi yalnızca yüzde veya rozet olmamalı; bir sonraki adımın ne olduğunu anlatmalı.
- Kullanıcı bir süredir gelmediyse suçlayıcı “serini kaybettin” dili yerine yumuşak bir yeniden başlama önerisi sunulmalı.
- Bir oturum tamamlandığında ekranda sıradaki eylem belirgin olmalı; kullanıcı ana sekmeler arasında amaçsızca dolaşmak zorunda kalmamalı.

**Kaçınılması gerekenler:**

- Aynı ekranda çok sayıda eşit ağırlıklı kart.
- Kullanıcının zaten bildiği bilgileri tekrar tekrar gösteren geniş istatistik alanları.
- Gerçek öğrenme verisiyle desteklenmeyen tahminler veya yapay başarı mesajları.

### 5.2. Kelimeler — “Hangi kelimeleri öğreniyorum ve hangilerini hatırlamam gerekiyor?”

Bu sekme bir sözlükten daha fazlası olabilir: kişisel kelime defteri ve tekrar alanı.

**Önerilen bilgi mimarisi:**

- Bugünkü tekrarlar
- Öğrenmekte olduğum kelimeler
- Kaydettiklerim
- Sözlükte ara
- Seviyeye göre keşfet

Bu bölümler ilk ekranda beş büyük kart olmak zorunda değil. Üstte basit bir filtre veya kısa özetle erişilebilir hâle getirilebilir.

**Bir kelimenin detayında faydalı olabilecekler:**

- İngilizce kelime ve doğal ses kaydı.
- Türkçe anlam.
- Kelimenin geçtiği kısa ve anlaşılır örnek cümle.
- Cümleyi dinleme.
- Kişisel kaydetme ve tekrar durumu.
- Gerekiyorsa bir kullanım notu; her kelimeye gereksiz açıklama eklenmemeli.

**Fikir — Kelimeyi bağlamıyla kaydet:** Kullanıcı hikâyede veya cümle alıştırmasında karşılaştığı kelimeyi kaydettiğinde, kelimeyle birlikte o cümle de saklanabilir. Böylece kişisel kelime listesi yalnızca çevirilerden oluşmaz.

**Fikir — Tek dokunuşla hatırlama:** Tekrar ekranında önce İngilizce kelimeyi veya anlamı gösterip diğer tarafı kullanıcının isteğiyle açmak denenebilir. Kullanıcı yanıtını değerlendirdikten sonra tekrar aralığı güncellenebilir.

**Dikkat:** Kaydedilen her kelimeyi otomatik olarak “öğrenildi” saymamak gerekir. Kaydetmek ilgi göstergesidir; hatırlamak ise ayrı bir davranıştır.

### 5.3. Pratik — “Öğrendiğimi kullanarak pekiştirebilir miyim?”

Pratik alanı farklı etkinliklerin toplandığı yer olabilir: gramer, cümle kurma, dinleme ve telaffuz, kelime oyunları ve hikâyeler.

Buradaki kritik tasarım kararı, her etkinliğin aynı derecede önemliymiş gibi görünmemesidir. Etkinlik türleri açık ve kısa açıklamalarla ayrılmalı:

- **Gramer:** Bir yapıyı anla ve örneklerde tanı.
- **Cümle kur:** Kelimeleri doğru sıraya yerleştir, sonra yeni örneği dene.
- **Dinleme ve telaffuz:** Sesi dinle, ayrıntıya dikkat et ve tekrar et.
- **Hikâyeler:** Kelimeleri cümle ve olay bağlamında gör.
- **Kelime oyunları:** Kısa, hafif bir pekiştirme oturumu yap.

**Fikir — Pratiği öğrenme yoluna bağla:** Öğrenci yeni bir gramer konusunu bitirdiyse ilgili cümle kurma alıştırması önerilebilir. Hikâyede tekrar tekrar karşılaştığı kelimeler, kelime tekrar sistemine eklenebilir.

**Fikir — Etkinlik öncesi süre beklentisi:** “Yaklaşık 3 dakika” gibi süre bilgileri yalnızca gerçek kullanımda makul olduğu doğrulanırsa gösterilmeli. Süre, kullanıcıyı başlatmaya yardımcı olur; kesin söz gibi sunulmamalı.

### 5.4. Keşfet — “Başka ne öğrenebilirim?”

Keşfet, Öğren ekranının kopyası olmamalıdır. Öğren kişiye uygun sıradaki eylemi sunarken Keşfet merakı destekleyebilir.

Olası içerikler:

- Günün cümlesi.
- Kısa tematik kelime grupları.
- Seviyeye uygun bir hikâye.
- Önceden öğrenilen bir konuyu farklı örnekle görme.
- Belirli bir ilgi alanına yönelik kelimeler.
- Kullanıcının henüz denemediği etkinlik türleri.

**Fikir — Merak köprüsü:** Kullanıcı günün cümlesini açtığında yalnızca cümleyi okuyup çıkmak yerine kelimeleri dinleyebilir, cümleyi kaydedebilir veya benzer bir cümleyi kurabilir. Keşif, öğrenmenin başka bir parçasına doğal bir geçit oluşturur.

**Dikkat:** Günlük içerik, sırf her gün değişsin diye düşük kaliteli veya rastgele içerik üretmemeli. İçerik seçimi seviye ve öğrenme hedefiyle uyumlu olmalı.

---

## 6. En güçlü ürün fikri: tek bir öğrenme döngüsü

Bubixo'nun birçok mevcut parçasını bir araya getirebilecek ana fikir budur.

### Örnek oturum: 8–10 dakika

1. **Başlangıç:** Öğren ekranı, bugün tekrar zamanı gelen kelimelerden küçük bir grup önerir.
2. **Hatırlama:** Kullanıcı önce anlamı veya kelimeyi kendisi hatırlamaya çalışır.
3. **Ses:** Kelimeyi dinler ve telaffuzunu fark eder.
4. **Bağlam:** Kelimenin geçtiği kısa bir cümleyi görür veya dinler.
5. **Kullanım:** Aynı yapıyla bir cümle kurar ya da basit bir soruya cevap verir.
6. **Geri bildirim:** Sistem doğru cevabı ve gerekliyse kısa açıklamayı gösterir.
7. **Kapanış:** Kullanıcı ne üzerinde çalıştığını ve sonraki öneriyi görür.

Bu akışın her adımının her oturumda bulunması zorunlu değil. Ama ürünün parçaları arasında bağlantı kurulması, kullanıcının bir faaliyetten diğerine anlamlı bir nedenle geçmesini sağlar.

### Neden bu fikir diğerlerinden daha önemli?

Çünkü yeni bir oyun veya yeni bir içerik kategorisi eklemeden mevcut içeriğin değerini artırabilir. Ayrıca kullanıcının ürüne geri gelme nedeni yalnızca “yeni şeyler var” olmaz; “önceki öğrendiklerimi pekiştireceğim ve bir sonraki adıma geçeceğim” hâline gelir.

---

## 7. Öncelikli yeni fikirler

Aşağıdaki fikirler geliştirme kararı değildir. Önce küçük prototip veya ölçümle doğrulanması gereken ürün hipotezleridir.

### Fikir A — Bugünün net hedefi

**Sorun:** Kullanıcı açılışta çok fazla seçenek arasında karar vermek zorunda kalabilir.

**Çözüm:** Öğren ekranında tek bir öneri: “Bugün 5 kelimeyi tekrar et ve kısa bir dinleme yap.” İçerik, gerçek ilerleme durumundan hesaplanmalı.

**Başarı işareti:** Ana ekrandan ilk etkinliğe geçiş oranının artması; kullanıcının başlangıçta daha az geri dönüp sekmeler arasında dolaşması.

**Zorluk:** Düşük–orta. Öneri kuralları ve ilerleme verisinin güvenilirliği gerekir.

### Fikir B — Kelimeleri farklı günlerde hatırlama

**Sorun:** Kelimeyi aynı oturumda doğru yapmak, uzun süre sonra hatırlamakla aynı değildir.

**Çözüm:** Mevcut tekrar mantığını anlaşılır bir hatırlama deneyimiyle güçlendirmek. Yanıt zorluğu, ipucu kullanımı ve doğru hatırlama gibi durumlar dikkatle modellenebilir.

**Başarı işareti:** Aradan zaman geçtikten sonra doğru hatırlama oranı; tekrar oturumlarını tamamlama.

**Zorluk:** Orta. Tekrar aralıkları iyi tasarlanmalı, fakat öğrenciye karmaşık ayarlar yüklenmemeli.

### Fikir C — Kelime + cümle + ses bağlantısı

**Sorun:** Sözlükte öğrenilen kelime, başka bir yerde bağlamsız kalabilir.

**Çözüm:** Kelimeyi örnek cümlesiyle kaydetme ve cümleden ilgili kelimeye ulaşma. Aynı kelime hikâyede görülünce kişisel kelime defterinde bağlamını korumak.

**Başarı işareti:** Kaydedilen kelimelerin tekrar edilme oranı ve kullanıcıların kelime detayından ses/cümle açma oranı.

**Zorluk:** Orta. Veri bağlantıları ve içerik eşleştirmeleri gerekir.

### Fikir D — Hata sonrası ikinci deneme

**Sorun:** Yanlış cevap yalnızca başarısızlık olarak kalabilir.

**Çözüm:** Kısa açıklamadan sonra aynı beceriyi ölçen farklı bir örnek sun. Aynı soruyu ezberletmek yerine benzer kuralı yeniden kullandır.

**Başarı işareti:** İlk hatadan sonra ikinci soruda doğru yanıt oranı; açıklamadan sonra etkinliği bırakma oranı.

**Zorluk:** Orta. İyi yazılmış alternatif sorular gerekir.

### Fikir E — Ara verdikten sonra kolay geri dönüş

**Sorun:** Öğrenme alışkanlığı kesildiğinde kullanıcı hangi aşamada olduğunu unutabilir.

**Çözüm:** Suçluluk hissettirmeyen bir geri dönüş ekranı: “Kaldığın yer burada. İstersen kısa bir tekrar ile devam edelim.” Gerektiğinde eski ilerlemeyi koru ve düşük eforlu bir başlangıç sun.

**Başarı işareti:** Uzun aradan sonra geri dönenlerin ilk etkinliği başlatma ve tamamlama oranı.

**Zorluk:** Düşük–orta.

### Fikir F — İlerlemeyi daha anlamlı gösterme

**Sorun:** Ders tamamlama sayısı tek başına gerçek beceri gelişimini açıklamaz.

**Çözüm:** Birkaç basit ve dürüst gösterge: tamamlanan öğrenme oturumları, tekrar edilen kelimeler, daha sonra hatırlanan kelimeler ve öğrenme yolundaki sıradaki bölüm.

**Başarı işareti:** Kullanıcının ilerlemeyi anlama becerisi; istatistik ekranının kullanımı.

**Zorluk:** Orta. Ölçümlerin tanımları net olmalı. Veri yoksa gösterge uydurulmamalı.

### Fikir G — Kısa ve uzun oturum seçimi

**Sorun:** Kullanıcı her gün uzun bir çalışma için hazır olmayabilir.

**Çözüm:** “Kısa çalışma” ve “Tam çalışma” gibi iki basit yol. Kısa çalışma tekrar ve tek bir pratik; tam çalışma ise daha kapsamlı bir döngü içerebilir.

**Başarı işareti:** Başlama oranı, tamamlanma oranı ve haftalık geri dönüş.

**Zorluk:** Orta. Kısa yolun öğrenme hedefi gerçekçi olmalı; yalnızca daha az içerik gösteren bir kısayol olmamalı.

### Fikir H — Yardımın aşamalı açılması

**Sorun:** Türkçe çeviri veya ipucu sürekli görünürse kullanıcı İngilizceyi bağımsız anlamayı denemeyebilir.

**Çözüm:** Önce dinle/oku, sonra kelime ipucu, en son tam çeviri gibi isteğe bağlı yardım katmanları. Başlangıç düzeyindeki kullanıcıyı zor durumda bırakmamak için tam yardım her zaman ulaşılabilir olmalı.

**Başarı işareti:** İpuçsuz anlama oranı ve etkinlik terk oranı birlikte değerlendirilir. İpuçlarının azalması tek başına başarı değildir; kullanıcı zorlandığı için bırakıyorsa bu kötü sonuçtur.

**Zorluk:** Orta.

---

## 8. Öğrenme bilimi açısından dikkat edilmesi gerekenler

Bu bölüm klinik veya akademik bir değerlendirme değil; ürün tasarımına yön verebilecek genel öğrenme ilkelerinin uygulanmasına dair öneridir.

### 8.1. Aralıklı tekrar

Bir kelimeyi aralıklarla yeniden hatırlamaya çalışmak, onu aynı anda defalarca okumaktan daha yararlı olabilir. Bubixo'daki kelime tekrar sistemi bu yaklaşım için temel sunuyor.

**Ürün sonucu:** Tekrar kuyruğu kullanıcı için görünür ve yönetilebilir olmalı. Biriken tekrarlar korkutucu bir borç gibi gösterilmemeli; kısa oturumlara bölünebilmelidir.

### 8.2. Aktif hatırlama

Cevabı görmek ile cevabı kendin üretmek farklı deneyimlerdir.

**Ürün sonucu:** Uygun yerlerde önce hatırlama denemesi, sonra cevap ve geri bildirim sun. Ancak tüm ekranları sınava dönüştürme; bazen rahat okuma ve dinleme de gereklidir.

### 8.3. Bağlam içinde öğrenme

Kelimeyi bir cümle, hikâye veya gerçekçi durum içinde görmek, kullanımını anlamaya yardımcı olabilir.

**Ürün sonucu:** Sözlük, hikâyeler ve cümle kurma arasında bağlantılar oluştur. Bağlamın düzeye uygun olmasına dikkat et.

### 8.4. Anlaşılır girdi ve zorluk ayarı

Metin çok kolaysa yeni şey öğretmeyebilir; çok zorsa kullanıcı sürekli çeviriye ihtiyaç duyabilir.

**Ürün sonucu:** Seviye etiketleri yalnızca içerik listesi filtresi olmamalı. Metinler, kelime yoğunluğu ve gramer karmaşıklığı bakımından da gözden geçirilmeli. Zorluk kullanıcıya göre ayarlanacaksa bunun için gerçek veriye ihtiyaç vardır.

### 8.5. Üretim ve geri bildirim

Bir cümleyi anlamak, onu kendi başına kurabilmekle aynı değildir.

**Ürün sonucu:** Cümle sıralama gibi kontrollü etkinlikler, zaman içinde boşluk doldurma ve kısa bağımsız cevaplar gibi daha serbest etkinliklere bağlanabilir.

### 8.6. Telaffuzda güvenilir geri bildirim

Sesi dinletmek telaffuza maruz kalmayı sağlar; ancak tek başına öğrencinin kendi telaffuzunun doğru olup olmadığını ölçmez.

**Ürün sonucu:** Gerçek konuşma tanıma veya telaffuz değerlendirmesi eklenirse teknik kapsamı, mahremiyeti, dil desteği ve hata payı ayrıca tasarlanmalı. Böyle bir sistem yoksa özellik “telaffuz değerlendirmesi” diye tanıtılmamalı; “dinle ve tekrar et” olarak açıklanmalı.

---

## 9. Kullanıcı yolculukları: tasarımın cevaplaması gereken sorular

### Yolculuk 1 — İlk kez gelen kullanıcı

1. Bubixo'nun kime ve hangi seviyeye hitap ettiğini hemen anlayabiliyor mu?
2. Üyelik gerekip gerekmediğini ve ilerlemenin nasıl saklandığını biliyor mu?
3. Seviye seçimi gerekiyorsa bunu zorlanmadan yapabiliyor mu?
4. İlk etkinliğe kaç karar vererek ulaşıyor?
5. İlk birkaç dakikada İngilizce bir şeyi gerçekten dinleyip, anlayıp veya kullanabiliyor mu?
6. Oturum bittiğinde sonraki adımı biliyor mu?

**Öneri:** İlk kullanımda uzun bir tanıtım turu zorunlu kılma. Doğrudan kısa, düşük riskli bir ilk öğrenme deneyimi sun; ek açıklamalar gerektiğinde açılabilsin.

### Yolculuk 2 — Her gün geri gelen kullanıcı

1. Son kaldığı yere kolayca dönebiliyor mu?
2. Bugünkü tekrar ile yeni ders arasındaki farkı anlıyor mu?
3. Etkinlikler birbirine bağlanıyor mu?
4. Günlük hedef tamamlandığında anlamlı bir kapanış var mı?
5. Uygulamadan çıkarken sonraki sefer nereden başlayacağını biliyor mu?

**Öneri:** Günlük akışı birkaç temel duruma göre tasarla: yeni başlayan, devam eden, tekrarları birikmiş, kısa zaman ayırabilen ve uzun aradan sonra dönen kullanıcı.

### Yolculuk 3 — Bir kelimeyi öğrenmek isteyen kullanıcı

1. Arama sonuçları açık ve anlaşılır mı?
2. Kelimenin anlamını ve sesini kolayca buluyor mu?
3. Kelimeyi örnek cümlede görebiliyor mu?
4. Kaydettiği kelimeyi daha sonra nerede bulacağını biliyor mu?
5. Sistem kelimeyi ne zaman tekrar etmesi gerektiğini açıklıyor mu?

**Öneri:** Arama ve tekrar aynı sekmede bulunabilir; ama sözlükte gezinmekle kişisel tekrar yapmak görsel olarak ayırt edilmeli.

### Yolculuk 4 — Hikâye okumak isteyen kullanıcı

1. Hikâyenin seviyesi ve yaklaşık uzunluğu anlaşılır mı?
2. Ses, metin ve çeviri kontrolleri kolay bulunuyor mu?
3. Kullanıcı cümle cümle ilerleyebiliyor mu?
4. Bilmediği kelimeyi kaydedebiliyor mu?
5. Hikâyeyi bitirdiğinde ilgili kelimeleri veya bir sonraki hikâyeyi bulabiliyor mu?

**Öneri:** Hikâyeyi tamamlamak, kullanıcıyı rastgele bir ana ekrana döndürmemeli; hikâyede karşılaşılan kelimeler veya benzer seviyedeki bir sonraki içerik gibi ilgili bir devam sunmalı.

### Yolculuk 5 — Uzun aradan sonra dönen kullanıcı

1. Önceki ilerlemesi korunuyor mu?
2. Sistem onu yargılamadan karşılıyor mu?
3. Birikmiş tekrarlar yönetilebilir mi?
4. İlk oturum kısa tutulabiliyor mu?
5. Kullanıcı yeniden alışkanlık kurmak için somut bir başlangıç buluyor mu?

**Öneri:** “Kaçırdığın günleri telafi et” yaklaşımından kaçın. Hedef geriye dönük borcu kapatmak değil, yeniden öğrenmeye başlamaktır.

---

## 10. Görsel tasarım ve etkileşim değerlendirmesi

Bubixo için mevcut tasarım yönergesi beyaz zemin, koyu metin, ince sınırlar, ölçülü vurgu renkleri ve gölgesiz/az gölgeli yüzeyler gibi sakin bir görsel dil tanımlıyor. Bu dili korumak doğru bir kısıt olabilir; her yeni fikri yeni kartlar, renkler veya gösterişli bileşenlerle çözmek gerekmiyor.

### Güçlü olabilecek yaklaşım

- Birincil eylemi tipografi ve boşlukla belirginleştirmek.
- Her yerde aynı kart desenini kullanmak yerine, içeriğin türüne göre doğru düzeni seçmek.
- Durumları yalnızca renkle anlatmamak; metin ve simge desteği vermek.
- Dokunma alanlarını mobil kullanım için yeterli tutmak.
- Yüklenme, boş durum, hata ve çevrimdışı durumları da tasarlamak.
- Ana sekmelerin anlamını ve aktif durumunu tutarlı göstermek.

### Kontrol edilmesi gereken riskler

- CSS dosyalarında tekrarlanan seçiciler, görünümün farklı ekranlarda hangi kurala bağlı olduğunu anlamayı zorlaştırabilir. Bunları hemen topluca silmek yerine gerçek ekran görüntüleri ve regresyon testleriyle aşamalı ele almak gerekir.
- İkonlar yalnızca estetik unsur değildir; gezinme ve eylem anlamını taşır. Resmî bir ikon setine geçilecekse ikonların çizgi kalınlığı kadar anlamı, erişilebilir adı ve tüm ekranlardaki tutarlılığı da kontrol edilmelidir.
- Bir simgenin tek başına anlaşılır olduğu varsayılmamalı. Özellikle ana gezinmede metin etiketleri korunmalıdır.
- Büyük başlıklar ve istatistikler görsel hiyerarşi kurabilir; ancak asıl eylemi aşağı itiyorsa sadeleştirilmelidir.
- Sadece masaüstünde güzel görünen düzen yeterli değildir. Mobil ekran, uzun metin, büyük yazı boyutu ve klavye açılması gibi durumlar test edilmelidir.

**Önemli sınır:** Bu belge, gerçek cihazlarda yapılmış görsel kullanılabilirlik testi değildir. Görsel problemler hakkındaki ifadeler denetlenmesi gereken hipotezlerdir.

---

## 11. İçerik kalitesi ve pedagojik tutarlılık

İyi bir arayüz, tutarsız veya yanlış içeriği telafi edemez. Bubixo'nun içeriği ürünün merkezinde olduğu için içerik denetimi ayrı bir iş akışı olmalıdır.

### Denetlenecek başlıklar

1. **Seviye tutarlılığı:** A1 olarak etiketlenen içerik gereksiz biçimde zor kelime ve yapılarla dolu mu?
2. **Çeviri doğallığı:** Türkçe karşılıklar doğal mı, bağlama uygun mu?
3. **Örnek doğruluğu:** İngilizce cümleler dilbilgisi ve kullanım bakımından doğru mu?
4. **Ses-metni eşleşmesi:** Oynatılan ses ekrandaki metinle gerçekten aynı mı?
5. **Kelime-örnek ilişkisi:** Kelime için verilen örnek, yaygın ve anlaşılır bir kullanımı gösteriyor mu?
6. **Tekrar ve çakışma:** Aynı içerik gereksiz yere tekrarlanıyor mu; tekrar varsa öğrenme amacı belli mi?
7. **Yönergeler:** Öğrenci ne yapacağını ve yanlış cevap verdiğinde nasıl geri döneceğini anlıyor mu?
8. **Kültürel doğallık:** İsimler, durumlar ve örnekler öğrencinin anlayabileceği doğal senaryolar mı?
9. **Erişilebilirlik:** Sesin yanında metin var mı; ses oynatılamadığında alternatif bulunuyor mu?
10. **İddialar:** Site tanıtımında belirtilen içerik sayıları ve ücretsiz/çevrimdışı özellikler mevcut sürümde gerçekten doğrulanabiliyor mu?

### Fikir — İçerik kalite kontrol listesi

Her içerik birimi için küçük bir editoryal kontrol kullanılabilir: seviye, dil doğruluğu, ses eşleşmesi, çeviri, öğrenme amacı ve ilgili kelimeler. Bu süreç kullanıcıya yeni karmaşıklık yüklemez; ürünün güvenilirliğini artırır.

---

## 12. Ölçüm: Başarıyı nasıl anlayacağız?

İlk aşamada çok sayıda analitik araç veya karmaşık dashboard gerekli değil. Önce ürünün öğrenme deneyimini değerlendirecek birkaç tanım üzerinde anlaşılmalı.

### Ürün hunisi

1. **Başlangıç:** Ana ekrandan bir öğrenme etkinliğine geçiş.
2. **Etkinleştirme:** İlk anlamlı etkinliği tamamlama.
3. **Devam:** Aynı oturumda ikinci ilgili etkinliğe geçme.
4. **Geri dönüş:** Başka bir günde yeniden çalışma.
5. **Hatırlama:** Önceki kelimeyi veya yapıyı belirli bir süre sonra doğru kullanma.

### Önerilen ölçümler

- İlk etkinliğe geçiş oranı.
- İlk etkinliği tamamlayanların oranı.
- Oturum başına tamamlanan anlamlı öğrenme adımı.
- Kelime tekrarlarını tamamlama oranı.
- Zaman aralığı sonrası doğru hatırlama oranı.
- Bir hikâyeden kelime kaydetme oranı.
- Hata sonrası açıklamayı okuyup ikinci denemeye geçenlerin oranı.
- Bir haftada en az iki ayrı gün öğrenme etkinliği yapanların oranı.

Bu metriklerin tümü ilk sürümde izlenmek zorunda değil. Önce yerel verinin neyi güvenilir biçimde ölçebildiği belirlenmeli.

### Gizlilik ilkesi

İlerleme şu anda yerel saklama mantığına dayanıyor. Kullanıcı davranışını sunucuya gönderen analiz sistemi eklenirse hangi verilerin toplandığı, neden gerekli olduğu, nasıl saklandığı ve kullanıcıya nasıl açıklandığı ayrıca kararlaştırılmalıdır. Analitik eklemek, varsayılan olarak her etkileşimi izlemek anlamına gelmemeli.

---

## 13. Teknik yapı ve ürün güvenilirliği

Bu bölüm mimariyi baştan yazma önerisi değildir. Öncelik, mevcut yapıyı güvenilir kılmak ve sonraki geliştirmeleri daha az riskli hâle getirmektir.

### 13.1. İlerleme verisinin tekliği

Mevcut kodda eski ilerleme alanları ile öğrenme yolu katmanının durumları birlikte ele alınıyor; açıklamalarda yeni alanların eski alanlarla uyumlu çalışmasına yönelik korumalar belirtilmiş.

**Risk:** İlerleme iki yerde tutuluyor veya farklı yorumlanıyorsa kullanıcı bir ekranda tamamladığı şeyi başka ekranda tamamlanmamış görebilir.

**Öneri:** Her öğrenme durumu için tek bir doğruluk kaynağı tanımla. Geçiş döneminde kopyalama veya uyumluluk varsa bunun ne zaman ve hangi yönde gerçekleştiğini belgele. Eski kullanıcı verisi için geçiş testi yaz.

### 13.2. Yerel kayıt ve veri kaybı

**Risk:** Tarayıcı verisi silindiğinde ilerleme kaybolabilir; cihazlar arası senkronizasyon yoksa başka cihazda aynı duruma otomatik geçilemez.

**Öneri:** Önce veri kaybı senaryosunu kullanıcıya açıkça anlat. Daha sonra kullanıcı kontrollü dışa aktarma/yedekleme gibi hafif bir çözüm değerlendirilebilir. Hesap ve sunucu senkronizasyonu ancak gerçek ihtiyaç ve bakım kapasitesi varsa düşünülmeli.

### 13.3. Ses varlıkları

Ses dosyaları ve metin eşleşmesi kritik. İçerik metnindeki küçük bir değişiklik bile hash tabanlı ses bulmayı etkileyebilir.

**Öneri:** İçerik değişikliklerinde ses eşleşmesini otomatik kontrol eden bir doğrulama adımı oluştur. Eksik ses, yanlış dosya veya metin eşleşmezliği sessizce geçilmemeli.

### 13.4. PWA ve çevrimdışı kullanım

**Öneri:** En az şu senaryolar test edilmeli:
- İlk açılış çevrimiçiyken.
- İlk kurulumdan sonra çevrimdışıyken.
- Yeni sürüm yayımlandığında.
- Önbellekte olmayan bir ses dosyası gerektiğinde.
- Kullanıcı çevrimdışıyken ilerleme kaydettiğinde.
- Güncelleme bildirimi geldiğinde.

Çevrimdışı desteğin kapsamı doğrulanmadan “her şey çevrimdışı çalışır” gibi geniş iddialar kullanılmamalı.

### 13.5. Büyük dosyalar ve CSS tekrarları

`app.js`, `yol.js`, `kurs.css` ve `yol.css` önemli miktarda davranış ve stil içeriyor. Tek dosyada çok sayıda sorumluluk bulunması, hata ayıklamayı ve görsel değişikliklerin etkisini tahmin etmeyi zorlaştırabilir.

**Öneri:** Büyük çaplı yeniden yapılandırma yerine önce davranış testleri ekle; ardından tekrar eden CSS kurallarını küçük gruplar hâlinde birleştir. Her değişiklikten sonra aynı ekran görüntülerini karşılaştır. Görsel regresyon riski nedeniyle “temiz görünüyor” diye toplu silme yapılmamalı.

### 13.6. README ve geliştirme belgeleri

Mevcut README oldukça kısa. Projeye yeni bir geliştirici katılacaksa dosya yapısı, yerel çalıştırma, içerik ekleme, ses sistemi, PWA ve test yöntemi açıklanmalı.

**Öneri:** README bir ürün tanıtım metni değil, projeyi güvenli biçimde çalıştırıp değiştirmeye yarayan pratik bir rehber olsun.

---

## 14. Dört sekme dışındaki fikirler: şimdi mi, sonra mı?

### Şimdi değerlendirilmeye değer

- Ana ekrandaki öneri mantığını ve devam etme akışını doğrulamak.
- Kelime, örnek cümle ve ses arasındaki ilişkiyi güçlendirmek.
- Hata sonrası açıklama ve ikinci denemeyi iyileştirmek.
- Boş durumları, yüklenme durumlarını ve çevrimdışı davranışları test etmek.
- İçerik ve ses eşleşmesi için kalite kontrol eklemek.
- Yerel ilerleme davranışını açık ve güvenilir hâle getirmek.

### İlk iyileştirmelerden sonra

- Kısa/tam çalışma seçenekleri.
- Uzun aradan sonra geri dönüş akışı.
- Öğrencinin yanlış yaptığı konuya göre pratik önerileri.
- Daha anlamlı ilerleme özeti.
- Kelime defterinde bağlamlı kayıtlar.
- İsteğe bağlı ipucu ve çeviri katmanları.

### Ancak ihtiyaç doğrulanırsa

- Gerçek AI konuşma asistanı.
- Bulut hesabı ve cihazlar arası senkronizasyon.
- Kapsamlı kişiselleştirme veya adaptif seviye motoru.
- Kullanıcılar arası sosyal özellikler, liderlik tabloları veya rekabet.
- Yeni büyük içerik kütüphaneleri.
- İleri düzey konuşma/telaffuz puanlama sistemi.

Bu son gruptaki fikirler etkileyici görünebilir ama bakım, maliyet, mahremiyet ve hata riski getirir. Temel öğrenme döngüsü net değilken bunlara yatırım yapmak doğru olmayabilir.

---

## 15. Önerilen yol haritası

### Aşama 1 — Güvenilir temel

**Amaç:** Mevcut deneyimin doğru çalıştığından emin olmak.

- Dört sekmenin her birini mobil ve masaüstünde test et.
- Her ana ekrandan ayrıntı ekranına ve geri dönüşü kontrol et.
- Tarayıcı geri/ileri davranışını test et.
- İlerleme kaydetme ve yeniden yükleme senaryolarını kontrol et.
- Ses-metni eşleşmesini örneklemle ve otomatik kontrolle doğrula.
- PWA kurulumu ve çevrimdışı senaryolarını gerçek cihazda test et.
- Kritik hataları önceliklendir; yeni özellik eklemeyi geçici olarak durdur.

**Bitti sayılma koşulu:** Temel kullanıcı yolculukları tanımlı cihazlarda tekrarlanabilir biçimde çalışıyor ve bilinen kritik sorunlar kayıt altına alınmış.

### Aşama 2 — Ana öğrenme deneyimi

**Amaç:** Kullanıcının doğru sonraki adımı bulmasını kolaylaştırmak.

- Öğren ekranındaki birincil eylemi doğrula.
- Devam etme durumlarının doğru hedefe yönlendirdiğini kontrol et.
- Bugünün hedefini gerçek tekrar/ilerleme verisine bağla.
- Boş ve ilk kullanım durumlarını tasarla.
- Her oturum sonunda doğal bir sonraki adım sun.

**Bitti sayılma koşulu:** Yeni kullanıcı ve devam eden kullanıcı, ek açıklamaya ihtiyaç duymadan bir sonraki anlamlı etkinliğe ulaşabiliyor.

### Aşama 3 — Öğrenme parçalarını birbirine bağlama

**Amaç:** Sözlük, ses, hikâye, gramer ve cümle kurmayı ortak bir akışa dönüştürmek.

- Kelimeden örnek cümleye ve sese geçiş.
- Hikâyeden kişisel kelime listesine kayıt.
- Gramer etkinliğinden ilişkili cümle pratiğine geçiş.
- Hata sonrası kısa açıklama ve farklı örnekle tekrar.
- Kelime tekrarının anlaşılır geri bildirimle sunulması.

**Bitti sayılma koşulu:** Kullanıcı bir etkinlikten diğerine yalnızca menü üzerinden değil, öğrenme bağlamını koruyarak geçebiliyor.

### Aşama 4 — Ölç, öğren ve iyileştir

**Amaç:** Fikirleri varsayımla değil, davranışla değerlendirmek.

- Birkaç temel metrik tanımla.
- Mümkünse kullanıcılarla görev temelli kullanılabilirlik testi yap.
- İlk etkinliğe geçiş, tamamlanma ve sonraki gün geri dönüşü incele.
- Çeviri yardımı, kısa çalışma ve öneri kartları gibi fikirleri küçük deneylerle karşılaştır.
- Sonuçlara göre öncelikleri değiştir.

**Bitti sayılma koşulu:** Hangi değişikliğin neyi iyileştirmeyi hedeflediği ve nasıl değerlendirileceği önceden belli.

---

## 16. Riskler ve özellikle kaçınılması gereken tuzaklar

### Tuzak 1 — Sürekli yeni özellik eklemek

Yeni özellik, mevcut özelliklerin kullanımını artırmıyorsa ürün karmaşıklığını büyütür.

### Tuzak 2 — Her şeyi kişiselleştirmeye çalışmak

Kişiselleştirme için güvenilir veri gerekir. Yeterli veri yokken “sana özel” öneriler yapmak sahte bir zekâ hissi yaratabilir.

### Tuzak 3 — Seriyi ana motivasyon kaynağı yapmak

Günlük seri alışkanlığı hatırlatabilir ama öğrenmenin kendisinin yerine geçmemeli. Kaçırılan günler suçluluk yaratmamalı.

### Tuzak 4 — İlerleme yüzdelerini öğrenmeyle eşitlemek

Dersin tamamlanması veya kelimenin açılması, kalıcı öğrenmenin kanıtı değildir. Göstergelerin ne anlama geldiği açık olmalı.

### Tuzak 5 — AI'ı ürünün merkezine erken yerleştirmek

AI konuşma özelliği dikkat çekici olabilir; fakat doğruluk, gecikme, maliyet, veri gizliliği ve öğrencinin seviyesine uygunluk sorunları vardır. Temel deneyimden önce geliştirilmesi şart değildir.

### Tuzak 6 — Büyük teknik temizlikle görsel regresyon yaratmak

Tekrarlanan CSS kurallarını tek seferde silmek veya büyük dosyaları aceleyle bölmek, mevcut davranışları bozabilir. Önce test, sonra küçük değişiklik gerekir.

### Tuzak 7 — Sadece tasarımcının gözünden değerlendirmek

Bir ekran geliştiriciye temiz görünebilir ama ilk kez kullanan biri için belirsiz olabilir. En azından birkaç gerçek kullanıcıya görev verip nerede duraksadığını izlemek gerekir.

---

## 17. Kullanıcı araştırması için küçük ama değerli test

Büyük bir araştırma projesi başlatmadan, 3–5 hedef kullanıcıyla kısa görev testi yapılabilir. Bu sayı istatistiksel genelleme için değil, belirgin kullanılabilirlik sorunlarını keşfetmek içindir.

Katılımcılardan şu görevleri yapmaları istenebilir:

1. Uygulamayı ilk kez aç ve bugün ne çalışacağını bul.
2. Bir kelime ara, sesini dinle ve tekrar etmek üzere kaydet.
3. Bir hikâye aç, bir cümleyi dinle ve anlamını bul.
4. Bir cümle kurma alıştırmasını tamamla.
5. Çalışmayı bitir ve bir sonraki adımın ne olacağını açıkla.
6. Ana ekrana dön ve kaldığın yeri yeniden bul.

**Gözlemlenecek şey:** Katılımcının söylediği “güzel” veya “kötü” yorumlarından çok, nerede durduğu, neyi yanlış anladığı, hangi düğmeyi aradığı ve görev sırasında hangi bilgiyi kaçırdığı.

Test sırasında çözümü hemen açıklamamak gerekir. Kullanıcının kendi başına ilerleyemediği anlar tasarım için en değerli sinyallerdir.

---

## 18. Tasarım kararları için açık sorular

Bu soruların yanıtı hemen verilmek zorunda değil. Her biri ürün yönünü etkiler:

1. Bubixo öncelikle **düzenli bir kurs** mu, yoksa **her gün kısa pratik yapılan bir araç** mı olmak istiyor? İkisini birleştirebilir, fakat hangisinin ana deneyim olduğu net olmalı.
2. Öğrenme yolu zorunlu sıralı mı olmalı, yoksa öğrenci istediği içeriğe serbestçe gidebilmeli mi?
3. Türkçe çeviri her zaman görünür mü olmalı, yoksa kullanıcı isteğiyle mi açılmalı?
4. Kelime tekrar sistemi kendi başına bir öğrenme modu mu, yoksa ana öğrenme yolunun parçası mı olmalı?
5. Ürünün ana başarı göstergesi ne: tamamlanan ders, hatırlanan kelime, düzenli geri dönüş veya kullanıcı memnuniyeti?
6. Kullanıcının ilerlemesi yalnızca cihazda mı kalmalı, yoksa ileride yedekleme/senkronizasyon ihtiyacı var mı?
7. Ses ve telaffuz tarafında ürünün gerçek vaadi ne olmalı: dinleme, taklit etme, konuşma üretme veya telaffuz değerlendirmesi?

Bu kararlar netleşmeden büyük özellik geliştirmek, sonradan yeniden tasarım ihtimalini artırır.

---

## 19. Sonuç: Bubixo'yu daha iyi yapan şey ne olmalı?

Bubixo'nun rekabet avantajı yalnızca ücretsiz olması veya çok sayıda kelime ve etkinlik içermesi olmamalı. Bu özellikler değerlidir ama kolayca bir listeye dönüşebilir.

Daha güçlü ürün fikri şu:

> **Bubixo, öğrencinin bugün ne yapacağını seçmesine yardım eden; kelimeyi ses ve bağlamla öğreten; öğrenileni uygun zamanda tekrar ettiren; hata yaptığında nedenini açıklayan ve her oturumdan sonra doğal bir sonraki adım sunan sade bir İngilizce öğrenme yol arkadaşı olsun.**

Bu vizyon için ilk yapılması gereken yeni bir AI asistanı veya yeni bir sekme eklemek değil. Önce temel yolculukların çalıştığını kanıtlamak, dört sekmenin görevlerini netleştirmek ve mevcut özellikleri ortak öğrenme döngüsüne bağlamak gerekir.

### Önerilen ilk üç öncelik

1. **Gerçek kullanıcı akışlarını ve teknik güvenilirliği test et.** Test edilmemiş bir deneyimi daha fazla özellik ekleyerek büyütme.
2. **Öğren ekranını karar vermeyi kolaylaştıran bir merkeze dönüştür.** Kullanıcı bir sonraki adımı hızlıca bulsun.
3. **Kelimeler, ses, hikâye ve pratik arasında bağ kur.** Böylece mevcut içeriklerin değeri artar ve öğrenme deneyimi daha bütünlüklü olur.

Görsel sadelik, mevcut tasarım diline bağlılık ve doğru içerik bu stratejinin temel kısıtları olarak korunmalı. Başarı; ekran sayısının, ikon sayısının veya eklenen özelliklerin artmasıyla değil, öğrencinin daha az kafa karışıklığıyla başlayabilmesi, öğrendiklerini daha sonra hatırlayabilmesi ve isteyerek geri dönebilmesiyle değerlendirilmelidir.
