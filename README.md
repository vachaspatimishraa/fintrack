# <p align="center">💰 FinTrack</p>

<p align="center">
  <img src="assets/images/logo.png" width="140" alt="FinTrack Logo">
</p>

<p align="center">
  <font size="6"><b>FinTrack</b></font><br>
  <i>A modern, secure, and offline-first personal finance manager.</i>
</p>

<p align="center">
  <a href="https://github.com/vachaspatimishraa/fintrack/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-success?style=for-the-badge&logo=android&logoColor=white" alt="Download APK">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart">
  <img src="https://img.shields.io/badge/Platform-Android-success">
  <img src="https://img.shields.io/badge/License-MIT-green">
</p>

---

# 📱 About

FinTrack is a premium personal finance application designed to give you complete control over your money. Built with **privacy and speed** in mind, it operates entirely offline, ensuring your financial data never leaves your device unless you choose to sync it.

---

# ✨ Features

- 📱 **Offline First**: All data is stored locally. No internet? No problem.
- ☁️ **Cloud Sync**: Securely backup and sync your data across devices using Supabase.
- 🔐 **App Lock**: Protect your financial records with Biometric (Fingerprint/Face) or Device PIN.
- 💳 **Multiple Accounts**: Manage separate wallets, bank accounts, and cards in one place.
- 💸 **Transaction Tracking**: Easy logging of income and expenses with detailed categories.
- 📊 **Smart Reports**: Visualize your spending patterns with elegant charts.
- 📄 **Professional Exports**: Generate beautiful PDF and Excel reports for your records.
- 🎨 **Material 3**: A modern UI that respects your system's dynamic color theme.
- 🌙 **Dark & AMOLED**: Stunning dark modes to save battery and reduce eye strain.

---

# 📥 Installation

1. **Visit Releases**: Click the **Download APK** button at the top or go to the [Releases](https://github.com/vachaspatimishraa/fintrack/releases) page.
2. **Download**: Download the APK file matching your device architecture (usually **arm64-v8a** for modern phones).
3. **Install**: Open the downloaded `.apk` file on your Android device.
4. **Allow Permissions**: If prompted, allow installation from unknown sources.

---

# 🏗 Architecture

FinTrack uses a robust repository pattern coupled with Riverpod for state management, ensuring a scalable and testable codebase.

```
Flutter (Presentation)
    │
Riverpod (State Management)
    │
Repositories (Data Layer)
    │
────────────────────────
│                      │
Isar Database      Supabase
(Local Storage)    (Cloud Backup)
```

---

# 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Database**: Isar (High performance, NoSQL)
- **Cloud Backend**: Supabase (Auth, DB, Storage)
- **Design**: Material 3 (Dynamic Color Support)

---

# 🚀 Developer

**Vachaspati Mishra**

GitHub: [vachaspatimishraa](https://github.com/vachaspatimishraa)

---

<p align="center">
  ⭐ If you find this project helpful, please give it a star!
</p>
