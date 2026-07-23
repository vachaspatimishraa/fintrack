<p align="center">
  <img src="assets/images/logo.png" alt="FinTrack Logo" width="150"/>
</p>

<h1 align="center">FinTrack</h1>

<p align="center">
A modern, offline-first personal finance management application built with Flutter.
</p>

<p align="center">
  <a href="https://github.com/vachaspatimishraa/fintrack/releases/latest">
    <img src="https://img.shields.io/badge/⬇️%20Download-Latest%20APK-2ea44f?style=for-the-badge" alt="Download APK"/>
  </a>
</p>

<p align="center">
  <a href="https://github.com/vachaspatimishraa/fintrack/releases/latest">
    <img src="https://img.shields.io/github/v/release/vachaspatimishraa/fintrack?style=for-the-badge&label=Latest%20Release" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android-success?style=for-the-badge&logo=android" />
</p>

---

# 📱 About

FinTrack is an offline-first personal finance manager designed to help you track income, expenses, accounts, and financial reports with a beautiful Material 3 interface.

Data is stored locally using **Isar** and can be synchronized securely with **Supabase**.

---

# ✨ Features

- 💰 Income & Expense Tracking
- 📂 Multiple Accounts
- 🏷 Custom Categories
- ☁️ Supabase Cloud Sync
- 📱 Offline-first Architecture
- 📊 Financial Reports
- 📄 PDF Export
- 📈 Excel Export
- 🔒 App Lock & Biometrics
- 🌙 Dark & Light Theme
- 🌍 English & Hindi Support
- 🔎 Transaction Search
- 📅 Monthly & Yearly Reports
- 🎨 Material 3 UI
- ⚡ Fast & Responsive

---

# 📸 Screenshots

> Add screenshots here.

| Dashboard | Reports | Accounts |
|-----------|---------|----------|
| Screenshot | Screenshot | Screenshot |

---

# 🛠 Tech Stack

| Technology | Usage |
|------------|------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Riverpod | State Management |
| Isar | Local Database |
| Supabase | Backend & Authentication |
| GoRouter | Navigation |
| Google Sign-In | Authentication |
| PDF | Report Generation |
| Excel | Spreadsheet Export |

---

# 📦 Installation

Clone the repository:

```bash
git clone https://github.com/vachaspatimishraa/fintrack.git

cd fintrack
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 🚀 Build

APK

```bash
flutter build apk --release --split-per-abi
```

App Bundle

```bash
flutter build appbundle --release
```

---

# 📂 Project Structure

```
lib/
 ├── core/
 ├── features/
 ├── shared/
 ├── l10n/
 ├── main.dart

assets/
android/
ios/
```

---

# 🏗 Architecture

```
Presentation
      │
 Riverpod
      │
 Repository
      │
 ┌───────────────┐
 │               │
Isar        Supabase
 │               │
 └───────────────┘
```

---

# 📥 Download

Download the latest APK from GitHub Releases:

<p align="center">
<a href="https://github.com/vachaspatimishraa/fintrack/releases/latest">
<img src="https://img.shields.io/badge/Download-Latest_APK-success?style=for-the-badge&logo=android"/>
</a>
</p>

---

# 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Push your branch
5. Open a Pull Request

---

# 📄 License

This project is licensed under the MIT License.

---

<p align="center">

Made with ❤️ using Flutter

</p>