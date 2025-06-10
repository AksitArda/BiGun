# BiGun - Audio Story Sharing App

## Project Overview
BiGun, kullanıcıların sesli hikayeler paylaşabileceği modern bir sosyal medya uygulamasıdır. WhatsApp benzeri ses görselleştirmesi ve minimalist tasarımı ile kullanıcı dostu bir deneyim sunar.

## Project Structure
```
lib/
├── core/
│   ├── services/
│   │   └── audio_service.dart    # Ses yönetimi ve önbellek
│   └── theme/
│       └── app_theme.dart        # Tema yapılandırması
├── features/
│   ├── feed/
│   │   ├── repositories/
│   │   │   └── story_repository.dart  # Hikaye veri yönetimi
│   │   └── screens/
│   │       └── feed_screen.dart       # Ana feed ekranı
│   └── audio/
│       └── components/
│           ├── audio_story_card.dart  # Ses hikayesi kartı
│           └── record_button.dart     # Kayıt düğmesi
├── models/
│   └── story.dart                # Veri modelleri
└── main.dart                     # Uygulama giriş noktası
```

## Key Features

### 1. Ses Kaydı
- WhatsApp tarzı ses kaydı arayüzü
- Gerçek zamanlı ses dalgası görselleştirmesi
- Basılı tutarak kayıt yapma
- Otomatik dosya yönetimi ve izin kontrolü

### 2. Ses Oynatma
- Modern ses oynatıcı arayüzü
- WhatsApp tarzı dikey çubuk görselleştirme
- İlerleme çubuğu ve zamanlama
- Tıklayarak konumlandırma özelliği

### 3. Arayüz
- Koyu tema
- Modern, minimalist tasarım
- Akıcı animasyonlar
- Duyarlı düzen

## Technical Details

### Dependencies
```yaml
dependencies:
  flutter_bloc: ^8.1.4        # Durum yönetimi
  just_audio: ^0.10.4         # Ses oynatma
  record: ^6.0.0             # Ses kaydı
  cached_network_image: ^3.3.1 # Resim önbelleği
  equatable: ^2.0.5          # Veri karşılaştırma
  shared_preferences: ^2.2.2  # Yerel depolama
```

### Platform Support
- Android
- iOS
- Web (bazı sınırlamalarla)

## Best Practices

### 1. Kod Stili
- Anlamlı değişken ve fonksiyon isimleri
- Küçük ve odaklı fonksiyonlar
- Karmaşık mantık için yorumlar
- const yapıcıları kullanımı
- Flutter stil kılavuzuna uyum

### 2. Performans
- setState() çağrılarını minimize etme
- Uygun yerlerde const widget kullanımı
- Controller ve subscription temizliği
- Hesaplanan değerleri önbellekleme
- Yeniden oluşturma döngülerini optimize etme

### 3. Hata Yönetimi
- Platform izinlerini kontrol etme
- Kullanıcı geri bildirimi sağlama
- Dosya temizliği
- Kenar durumlarını ele alma

### 4. Test
- Widget testleri
- Birim testleri
- Platform özel davranış testleri
- Ses işleme kenar durumları

## Contributing

1. Projeyi fork edin
2. Feature branch oluşturun
3. Değişikliklerinizi yapın
4. Testleri güncelleyin/yazın
5. Pull request gönderin

## Development Setup

1. Flutter SDK'yı yükleyin
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Platform ayarlarını yapılandırın
5. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Troubleshooting

### Yaygın Sorunlar ve Çözümleri

1. Ses Kaydı İzinleri
   ```dart
   await Permission.microphone.request();
   ```

2. Ses Oynatma Hataları
   ```dart
   try {
     await player.setUrl(url);
   } catch (e) {
     print('Ses yükleme hatası: $e');
   }
   ```

3. Önbellek Yönetimi
   ```dart
   final cacheDir = await getTemporaryDirectory();
   await cacheDir.delete(recursive: true);
   ```

## Future Improvements

1. Kullanıcı Kimlik Doğrulama
2. Bulut Depolama
3. Sosyal Özellikler
4. Ses İşleme Geliştirmeleri
5. Çevrimdışı Destek
6. Bildirimler 