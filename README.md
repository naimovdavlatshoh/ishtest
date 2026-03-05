# LinkedIn Clone - Flutter

LinkedIn-ning kichik versiyasi Flutter-da yaratilgan.

## 📱 Xususiyatlar

- ✅ **Autentifikatsiya** - Login va Registration
- ✅ **Feed** - Postlarni ko'rish, like, comment, share
- ✅ **Profile** - Foydalanuvchi profili, skills, experience
- ✅ **Chat** - Xabarlar ro'yxati va chat xonasi
- ✅ **Jobs** - Ish e'lonlari, saqlash va ariza yuborish

## 🏗️ Arxitektura

Loyiha **Feature-First** arxitektura asosida qurilgan:

```
lib/
├── main.dart
├── app/                    # App konfiguratsiyasi
├── core/                   # Umumiy resurslar
│   ├── config/            # Konfiguratsiya
│   ├── theme/             # Dizayn tizimi
│   ├── widgets/           # Qayta ishlatiladigan widgetlar
│   ├── utils/             # Yordamchi funksiyalar
│   └── mock/              # Mock ma'lumotlar
├── features/              # Asosiy funksiyalar
│   ├── auth/             # Autentifikatsiya
│   ├── feed/             # Yangiliklar feed
│   ├── profile/          # Profil
│   ├── chat/             # Xabarlar
│   └── jobs/             # Ish e'lonlari
├── shared/               # Umumiy modellar
└── l10n/                 # Lokallashtirish
```

## 🚀 Boshlash

### Talablar

- Flutter 3.0 yoki yuqori
- Dart 3.0 yoki yuqori

### O'rnatish

1. Repozitoriyani klonlash:
```bash
git clone <repository-url>
cd "ish ish"
```

2. Paketlarni o'rnatish:
```bash
flutter pub get
```

3. Ilovani ishga tushirish:
```bash
flutter run
```

## 📦 Paketlar

- **flutter_riverpod** - State management
- **go_router** - Navigatsiya
- **cached_network_image** - Rasm keshlash

## 🎨 Dizayn

Ilova LinkedIn-ning ranglar palitrasidan foydalanadi:
- Asosiy rang: `#0A66C2` (LinkedIn Blue)
- Orqa fon: `#F3F2EF`
- Matn: `#000000`, `#666666`

## 📝 Mock Ma'lumotlar

Hozircha ilova mock ma'lumotlar bilan ishlaydi:
- 5 ta foydalanuvchi
- 5 ta post
- 4 ta chat
- 5 ta ish e'loni

Keyinchalik real API bilan integratsiya qilish mumkin.

## 🔐 Autentifikatsiya

Demo maqsadida har qanday email va parol bilan kirish mumkin.

## 📱 Ekranlar

1. **Login/Register** - Kirish va ro'yxatdan o'tish
2. **Feed** - Yangiliklar tasmasi
3. **Profile** - Foydalanuvchi profili
4. **Chat List** - Xabarlar ro'yxati
5. **Chat Room** - Suhbat xonasi
6. **Jobs** - Ish e'lonlari

## 🛠️ Ishlab chiqish

### Yangi feature qo'shish

1. `features/` papkasida yangi papka yarating
2. Quyidagi strukturani yarating:
```
feature_name/
├── presentation/
│   └── screen_name.dart
├── widgets/
│   └── widget_name.dart
└── providers/
    └── provider_name.dart
```

### State Management

Loyiha **Riverpod** dan foydalanadi. Provider yaratish uchun:

```dart
final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});
```

## 📄 Litsenziya

MIT License

## 👨‍💻 Muallif

Flutter Developer
