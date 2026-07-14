# 💰 FinTrack

<div align="center">

<img src="assets/images/logo.png" alt="FinTrack Logo" width="140"/>

### Smart Personal Finance Manager built with Flutter

Track expenses • Manage accounts • Backup securely • Beautiful Material 3 UI

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3FCF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📥 Download

<a href="https://github.com/vachaspatimshraa/fintrack/releases/latest/download/app-release.apk">
    <img src="https://img.shields.io/badge/⬇️%20Download%20APK-Latest%20Release-success?style=for-the-badge" />
</a>

> **Replace the above GitHub Release URL with your Play Store link after publishing.**

---

</div>

# ✨ Features

### 💳 Account Management

- Create unlimited accounts
- Cash, Bank, Wallet, Card support
- Edit & Archive accounts
- Automatic balance tracking

---

### 💸 Transaction Management

- Income & Expense tracking
- Categories
- Payment methods
- Notes & descriptions
- Receipt attachment support
- Search & Filters

---

### ☁️ Cloud Backup

- Google Sign In
- Secure Supabase Authentication
- Automatic Account Backup
- Automatic Transaction Backup
- Sync across multiple devices
- Offline-first architecture

---

### 📊 Dashboard

- Total Balance
- Income Summary
- Expense Summary
- Recent Transactions
- Monthly Overview

---

### 🎨 Material You

- Material 3 Design
- Dynamic Colors (Android 12+)
- Dark Mode
- Light Mode
- Adaptive UI
- Responsive Layout

---

### 🔐 Security

- Google Authentication
- Secure Storage
- User-specific Cloud Data
- Row Level Security (RLS)
- Offline Data Protection

---

# 📱 Screenshots

> Add screenshots here

| Dashboard | Accounts | Transactions | Settings |
|-----------|----------|--------------|----------|
| ![](screenshots/home.png) | ![](screenshots/accounts.png) | ![](screenshots/transactions.png) | ![](screenshots/settings.png) |

---

# 🚀 Tech Stack

## Frontend

- Flutter
- Dart
- Riverpod
- Material 3

## Local Database

- Isar Database

## Backend

- Supabase
- PostgreSQL
- Authentication
- Row Level Security

## State Management

- Riverpod

## Routing

- GoRouter

## Other Packages

- Google Sign-In
- Flutter Secure Storage
- Shared Preferences
- Flutter Local Notifications
- Dynamic Color
- Image Picker
- File Picker
- Excel
- PDF
- Share Plus

---

# 📂 Project Structure

```
lib
├── core
├── features
│   ├── accounts
│   ├── transactions
│   ├── dashboard
│   ├── settings
│   ├── authentication
│   └── splash
├── shared
└── main.dart
```

---

# ⚡ Getting Started

## Clone

```bash
git clone https://github.com/vachaspatimishraa/FinTrack.git
```

```
cd FinTrack
```

---

## Install

```bash
flutter pub get
```

---

## Configure Environment

Create a `.env` file.

```env
SUPABASE_URL=YOUR_SUPABASE_URL

SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

GOOGLE_WEB_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID

GOOGLE_IOS_CLIENT_ID=
```

---

## Run

```bash
flutter run
```

---

# 📦 Build APK

```bash
flutter build apk --release
```

---

# 🍎 Build iOS

```bash
flutter build ios
```

---

# ☁️ Backend

FinTrack uses **Supabase** for:

- Authentication
- Cloud Sync
- PostgreSQL Database
- Row Level Security
- Multi-device Backup

---

# 🔄 Synchronization

✔ Offline First

✔ Automatic Sync

✔ Multi-device Backup

✔ Secure Authentication

✔ Last Sync Tracking

---

# 🤝 Contributing

Contributions are welcome!

1. Fork the repository

2. Create your feature branch

```bash
git checkout -b feature/new-feature
```

3. Commit changes

```bash
git commit -m "Add new feature"
```

4. Push

```bash
git push origin feature/new-feature
```

5. Open a Pull Request

---

# ⭐ Support

If you like this project, please consider giving it a ⭐ on GitHub.

It helps the project grow and motivates further development.

---

# 👨‍💻 Developer

**Vachaspati Mishra**

GitHub: https://github.com/vachaspatimishraa

---

# 📄 License

This project is licensed under the MIT License.

---

<div align="center">

### Made with ❤️ using Flutter & Supabase

</div>