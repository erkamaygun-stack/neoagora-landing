# NeoAgora — Landing / Reklam Sitesi

Tek dosyadan ibaret, statik tanıtım + kayıt sayfası. Atölye 28 Haziran'da başlayana kadar yayında kalacak — sonra kapatılır.

## İçindekiler

- `index.html` — tüm site (HTML + CSS + JS, tek dosya).
- `supabase-migration.sql` — kayıt tablosu için SQL. Bir kez çalıştırılır.
- `README.md` — bu dosya.

---

## 1) Önce Supabase'i hazırla

Mevcut **neoagora-app** projesinin kullandığı Supabase projesinin aynısını kullanıyoruz. Yeni proje açmaya gerek yok.

Adımlar:

1. https://supabase.com/dashboard'a gir.
2. NeoAgora projesini seç (ana app'in bağlı olduğu).
3. Sol menüden **SQL Editor** → **New query**.
4. `supabase-migration.sql` dosyasının tüm içeriğini yapıştır → **Run** bas.
5. Sol menüden **Table Editor** → `registrations` tablosunun listede olduğunu gör.

Bu kadar. Tablo + RLS + index'ler oluştu. Anonim kullanıcılar artık form üzerinden kayıt ekleyebilir, ama hiç kimse başkalarının kayıtlarını OKUYAMAZ.

---

## 2) `index.html`'i kişiselleştir

Editörle aç (`code index.html` veya `nano index.html`), aşağıdaki üç yeri doldur:

### a) Supabase anahtarları

`<script>` bloğunun en üstünde (~satır 750 civarı):

```js
const SUPABASE_URL = 'https://YOUR-PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR-ANON-KEY-HERE';
```

`neoagora-app/.env.local`'den kopyala:
- `NEXT_PUBLIC_SUPABASE_URL`  → `SUPABASE_URL` yerine
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` → `SUPABASE_ANON_KEY` yerine

Bu anahtarlar zaten `anon` (public) — sızdırma riski yok. RLS politikaları zaten sınırlamaları kuruyor.

### b) Fiyat

Aynı blokta:

```js
const PRICE_TL = '—'; // örn. '2.400'
```

`'—'` yerine net fiyatı yaz (string olarak): `'2.400'`, `'1.850'` vs.

### c) İletişim & sosyal medya (footer)

`<footer>` içinde (en altta):
- `iletisim@neoagora.com` → gerçek e-posta
- `https://instagram.com/neoagora` → gerçek Instagram

### (opsiyonel) Eğitmen fotoğrafı

Şu an Ece Hoca yerine büyük italik bir "E" görünüyor. Gerçek fotoğrafı eklemek için `index.html` içinde `font-headline italic text-6xl text-primary">E<` arat ve onun yerine:

```html
<img src="ece-hoca.jpg" alt="Ece Hoca" class="hex w-full h-full object-cover" />
```

`ece-hoca.jpg`'i `index.html` ile aynı klasöre koy.

---

## 3) Yerelde dene

Hiçbir build adımı yok. İki kolay yol:

```bash
# Yöntem 1 — Python varsa (Mac/Linux'ta default)
python3 -m http.server 8000
# → http://localhost:8000 adresini aç
```

```bash
# Yöntem 2 — Node varsa
npx serve .
# → terminalin verdiği adresi aç
```

Form submit'i Supabase'e gerçekten yazar; anahtarları doldurmadıysan inline uyarı görürsün.

---

## 4) Yayınla (deploy)

Üç ücretsiz seçeneğin var, en kolayından zoruna:

### A) Vercel (önerilen — saniyeler içinde)

1. https://vercel.com/new'e gir.
2. **"Continue with..."** yerine alt kısımdaki **"deploy a static folder"** seçeneğine tıkla.
3. Bu klasörü (`neoagora-landing/`) sürükle-bırak, ya da `vercel` CLI ile:

```bash
npm i -g vercel
cd neoagora-landing
vercel --prod
```

`https://neoagora-XXXX.vercel.app` gibi bir URL alırsın. İstersen Settings'ten kendi domain'ini bağla (örn. `neoagora.com.tr`).

### B) Netlify (drag & drop ile çok kolay)

1. https://app.netlify.com/drop'a git.
2. Klasörü tarayıcıya sürükle.
3. Bitti — geçici URL anında verilir.

### C) GitHub Pages

1. Yeni bir repo oluştur (`neoagora-landing`), `index.html`'i push et.
2. Settings → Pages → branch'i `main` olarak ayarla.
3. `https://kullaniciadin.github.io/neoagora-landing/` URL'inde yayınlanır.

---

## 5) Kayıtları nasıl görürsün?

Supabase Dashboard → **Table Editor** → `registrations` tablosu.

Filtreleme/sıralama:
- `status = 'pending'` — henüz IBAN gönderilmemiş yeni kayıtlar
- `created_at desc` — en yenilerden eskilere
- CSV export: tablonun sağ üstündeki üç nokta → "Export to CSV"

İleride bir admin paneli yapmak istersen `service_role` key kullanan ayrı bir Next.js sayfası hazırlanabilir.

---

## 6) Atölye başladıktan sonra (28 Haziran sonrası)

Site kapansın istiyorsan:

- **Vercel/Netlify**: Dashboard'dan deploy'u "pause" et veya domain bağlantısını kaldır.
- **GitHub Pages**: Repo Settings → Pages → "Disable".
- Alternatif: Sadece form'u kapat — `index.html` içindeki `<form>` elementini şu şekilde değiştir:
  ```html
  <div class="glass tech-notch p-12 text-center">
    <h3 class="font-headline italic text-3xl text-tertiary mb-4">Kayıtlar Kapandı</h3>
    <p class="text-text-dim">28 Haziran'da başlayan dönem dolmuştur. Bir sonraki dönem için takipte kal.</p>
  </div>
  ```

---

## 7) Reklam linki (UTM önerisi)

Sosyal medya / e-posta kampanyasında izlemek istersen URL'in sonuna UTM ekle:

```
https://neoagora.com/?utm_source=instagram&utm_medium=story&utm_campaign=launch_2026
```

Supabase'e ek bir alan eklemek istersen `notes` yerine `utm_source` kolonu açabilirsin (form gizli alan olarak `URLSearchParams`'tan alır).

---

## 8) Sık karşılaşılan sorunlar

| Sorun | Çözüm |
|---|---|
| Form submit'te "Failed to fetch" | Supabase URL yanlış yazılmış. Sondaki `/`'ı silmeyi unutma. |
| "Bu e-posta ile zaten kayıt var" | E-posta unique. SQL'de istersen `unique` kısıtını kaldırabilirsin. |
| Form gönderdim ama tabloda görünmüyor | RLS. SQL migration'ı tam çalıştığından emin ol. |
| Sayfa Tailwind yüklemiyor | İnternet kesik veya CDN engelli. Tailwind CDN'den okumaya çalışıyor. |
| Mobilde fontlar küçük | iOS Safari bazen `min-text-size` uygular. `viewport` meta tag'i zaten doğru, başka bir şey gerekmez. |

---

## 9) İletişim

Bu landing'de bir sorun olursa Cowork modunu açıp düzeltme isteyebilirsin. Sayfa minimal tutuldu — performansı yüksek, mobilde de hızlı açılır.

İyi atölyeler.
