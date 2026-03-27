# Direksiyonda (Ortak Yol) Proje Mimari ve Fonksiyon Listesi

Bu belge, uygulamanın teknik kapasitesini, her bir fonksiyonun ne işe yaradığını ve mevcut özelliklerini detaylandırmak için hazırlanmıştır.

## 1) Uygulamanın Amacı ve İşleyişi

**Direksiyonda**, bağımsız sürücüleri (emekçileri) ve yolcuları yasal bir zeminde bir araya getiren bir platformdur.

Taşıma faaliyetini **şoförlü araç kiralama (Private Rental)** olarak tanımlar ve tüm süreci **Türk Borçlar Kanunu (TBK)** çerçevesinde belgeler.

## 2) Temel Fonksiyonlar ve Modüller

### A) Kimlik ve Yetkilendirme (Auth Module)

Bu modül, uygulamanın giriş kapısıdır ve güvenliği sağlar.

- `register_screen` / `register()`
  - TC No, telefon ve isimle kayıt.
  - Şifreli veri saklama.
- `login_screen` / `login()`
  - Kayıtlı kullanıcı girişi.
- `checkAuthAndRedirect()`
  - Kullanıcının rolüne (Sürücü, Yolcu, Admin) göre doğru ekrana yönlendirme.
- `logout()`
  - Güvenli çıkış ve yerel verilerin temizlenmesi.

### B) Sürücü Modülü (Driver Module)

Sürücülerin iş akışını ve hukuki korunmasını yönetir.

- `goOnline()` / `goOffline()`
  - Sürücünün haritada görünür hale gelmesi.
  - GPS konumunun her 50 metrede bir güncellenmesi.
- `_listenForRides()`
  - Arkada planda gelen yolculuk çağrılarını dinleme.
- `acceptRide()` / `rejectRide()`
  - Gelen bir çağrıyı kabul etme veya bir sonraki sürücüye paslama.
- `startRide()` / `completeRide()`
  - Yolculuk zaman sayacını başlatma ve bitirme.
- `reportPenalty()` (**Hukuki Kalkan**)
  - Haksız ceza veya polis çevirmesi durumunda tutanak fotoğrafı ve konumla anında merkeze bildirim yapma.
- `fetchPayouts()` / `requestPayout()`
  - Kazanılan parayı görme ve banka hesabına çekme talebi oluşturma.

### C) Yolcu Modülü (Passenger Module)

Yolcuların güvenli ve belgeli seyahat etmesini sağlar.

- `calculateFare()`
  - Mesafe, zaman ve araç segmentine (Geniş, Lüks) göre fiyat belirleme.
- `requestRide()`
  - Harita üzerinden varış noktası seçip araç kiralama talebi oluşturma.
- `_listenToRide()`
  - Sürücünün nerede olduğunu ve geliş süresini canlı takip etme.
- `PassengerLegalPassport` (**Hukuki Pasaport**)
  - Polis çevirmesinde gösterilecek “Kiracı Kimlik Kartı” ve yasal cevap rehberi.
- `cancelRide()`
  - Sürücü gelmeden önce talebi iptal etme.

### D) Yönetici Modülü (Admin Module)

Sistemin beynidir, tüm sistemi denetler.

- `fetchDrivers()` / `updateDriverStatus()`
  - Kaydolan sürücülerin belgelerini inceleyip onaylama veya reddetme.
- `fetchPayouts()` / `updatePayoutStatus()`
  - Bekleyen ödeme taleplerini onaylayıp sürücüye parasını gönderme.
- `fetchPenalties()`
  - Sürücülerden gelen haksız ceza raporlarını inceleme ve avukatlara paslama.
- `Audit Logs`
  - Tüm işlemlerin (kim, ne zaman, nerede) kaydını tutma.

## 3) Öne Çıkan Özellikler (Unique Features)

- **Bağlantı Kopmama Garantisi**
  - Firebase Firestore snapshots ile internet kopsa bile uygulama tekrar açıldığında yolculuk kaldığı yerden devam eder.
- **Adil Fiyatlandırma**
  - Piyasa şartlarına göre otomatik artan/azalan değil, adil ve sabit bir birim fiyat (**6 TL/km**) ve şeffaf platform komisyonu (**%12**).
- **Kişi Başı Maliyet Paylaşımı**
  - Eğer araçta birden fazla yolcu varsa, ücreti adil şekilde bölüştüren algoritma.
- **Hukuki Q&A**
  - Yolcuya polis karşısında haklarını koruması için hazır cevaplar sunan modül.

## 4) Teknik Altyapı

- **Altyapı:** %100 Firebase (Auth, Firestore, Storage)
- **Tasarım:** Koyu Mod (Night Ops), yüksek kontrast, sarı (Gold) vurgular
- **Harita:** Google Maps Flutter SDK (özel karanlık tema)
- **Konumlandırma:** Geolocator (yüksek hassasiyetli GPS)
