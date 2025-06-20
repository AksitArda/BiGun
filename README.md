# Bi Gün ✍️🎧

![BiGun](https://github.com/user-attachments/assets/928744ec-b25b-43d4-bf2d-3f00d601003b)


“Bi Gün”, Instagram hikayelerine benzer bir sosyal medya uygulamasıdır. Ancak kullanıcılar yalnızca ses kaydı paylaşabilir. Uygulamanın ana akış (feed) sayfasında, insanların günlük olarak paylaştığı sesleri dinleyebilirsiniz. Paylaşılan içerikler 24 saat sonra otomatik olarak silinir.

## 🚀 Özellikler

- Kullanıcılar ses kaydı ekleyip paylaşabilir  
- Ana akış (feed) ekranında diğer kullanıcıların seslerini dinleyebilir  
- Paylaşılan ses içerikleri 24 saat sonra otomatik olarak silinir  

## 🛠️ Teknolojiler

- **Frontend:** Flutter  
- **Backend:** Express.js (Node.js)  
- **Veritabanı:** MongoDB  
- **Dosya Depolama:** Sunucuda `uploads/` klasörüne  
- **Kimlik Doğrulama:** JWT (JSON Web Token)

## ⚙️ Kurulum

### 1. Backend

```bash
npm install         # Gerekli bağımlılıkları kurar
cp .env.example .env
# .env dosyasını kendi ortam bilgilerinle doldur
npm start           # Sunucuyu başlatır
```

### 2. Frontend (Flutter)

```bash
flutter pub get     # Bağımlılıkları indirir
flutter run         # Uygulamayı başlatır
```

## 📁 Ortam Değişkenleri (`.env`)

Backend çalışabilmesi için proje kök dizininde `.env` dosyası oluşturulmalı ve aşağıdaki değişkenler doldurulmalıdır:

```env
PORT=5000
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-url>/bigun
JWT_SECRET=senin_jwt_secretin
NODE_ENV=development
```

## 🧪 API Yapısı

Uygulama, RESTful API mimarisi kullanır. JWT ile yetkilendirme yapılır. Aşağıda bazı temel endpoint örnekleri verilmiştir:

### 🔐 Auth

- `POST /register` — Yeni kullanıcı kaydı  
- `POST /login` — Giriş yapar, JWT token döner  
- `POST /logout` — Oturumu sonlandırır  
- `GET /me` — Giriş yapan kullanıcının bilgilerini getirir

### 📤 Ses Paylaşımı

- `POST /upload` — Ses dosyası yükler (multipart/form-data)  
- `GET /feed` — Güncel ses akışını getirir  
- `GET /:id` — Belirli bir ses gönderisini getirir  
- `DELETE /:id` — Kullanıcının kendi gönderisini siler  
- `GET /user/:userId` — Belirli bir kullanıcının tüm gönderilerini getirir  

### 🖼️ Profil Fotoğrafı

- `POST /upload-pp` — Profil fotoğrafı yükler

> Tüm isteklerde JWT token gereklidir (hariç: `/login`, `/register`).

## 🚧 Deployment

Proje şu anda geliştirme aşamasındadır. Henüz yayınlanmamıştır.

---
