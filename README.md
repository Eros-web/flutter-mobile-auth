# 🍔 Flutter Mobile Auth App

Sebuah aplikasi Flutter untuk keperluan e-commerce dengan fitur autentikasi Firebase, integrasi Firestore, dan state management menggunakan Provider. Dirancang modular dan mudah dikembangkan lebih lanjut.

## 🚀 Fitur Utama

- 🔐 Autentikasi pengguna menggunakan Firebase (email/password)
- 🔄 Manajemen data real-time dengan Cloud Firestore
- 🎨 UI responsif & terstruktur (berbasis folder modular)
- 📦 State management menggunakan Provider
- 🎁 Modul promo, keranjang belanja, histori pesanan, dan profil pengguna
- ☁️ Integrasi Firebase Cloud Functions dan API tambahan (`store_api`)

## 📁 Struktur Folder

```bash
lib/
├── component/        # Model data (FoodItem, Order, Voucher, dll.)
├── login-sigin/      # Halaman login & sign-up
├── page/             # Halaman-halaman utama (Home, Checkout, Profile, dll.)
├── provider/         # Provider untuk state management (CartProvider, AuthProvider, dll.)
├── services/         # Service layer (AuthService, FirestoreService, dll.)
└── main.dart         # Entry point aplikasi
