# <p align="center">💰 FinTrack</p>

<p align="center">
A modern, offline-first personal finance manager built with Flutter.
</p>

<p align="center">
<img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter">
<img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart">
<img src="https://img.shields.io/badge/Platform-Android-success">
<img src="https://img.shields.io/badge/License-MIT-green">
</p>

<p align="center">
<a href="https://github.com/vachaspatimishraa/fintrack/releases/latest/download/app-release.apk">
    <img src="https://img.shields.io/badge/Download-APK-success?style=for-the-badge&logo=android&logoColor=white" alt="Download APK">
</a>
</p>

---

# 📱 About

FinTrack is a modern personal finance application designed to help users manage their income, expenses, accounts, and financial activities with a beautiful Material 3 interface.

The app is **offline-first**, meaning everything works without an internet connection. Whenever internet becomes available, data is securely synchronized with Supabase.

---

# ✨ Features

## 💳 Account Management

- Create unlimited accounts
- Cash, Bank, Wallet & Card support
- Archive accounts
- Delete & restore accounts
- Account balance tracking

---

## 💸 Transaction Management

- Add Income
- Add Expenses
- Edit Transactions
- Delete Transactions
- Transaction Categories
- Payment Methods
- Notes
- Receipt Support
- Search Transactions
- Filter Transactions

---

## ☁ Cloud Sync

- Google Sign-In
- Secure Authentication
- Supabase Cloud Backup
- Automatic Sync
- Offline First
- Conflict Resolution
- Restore Data on Login

---

## 📊 Reports

- Income Summary
- Expense Summary
- Balance Tracking
- Category Breakdown
- Account Analytics

---

## 📤 Export

- Export to Excel
- Export to PDF
- Share Reports

---

## 🎨 Personalization

- Material 3 Design
- Dynamic Colors
- Light Theme
- Dark Theme
- Multiple Languages
- Adjustable Font Size

---

# 🏗 Architecture

```
Flutter
     │
Riverpod
     │
Repository Pattern
     │
────────────────────────
│                      │
Isar Database      Supabase
(Local)            (Cloud)
```

---

# 🛠 Tech Stack

- Flutter
- Dart
- Riverpod
- Isar Database
- Supabase
- Google Authentication
- Material 3
- Dynamic Color
- Go Router
- Shared Preferences

---

# 📂 Project Structure

```
lib/

├── core/
├── features/
├── shared/
├── app/
├── main.dart
```

---

# 🚀 Getting Started

Clone the project

```bash
git clone https://github.com/vachaspatimishraa/fintrack.git
```

Move into project

```bash
cd fintrack
```

Install packages

```bash
flutter pub get
```

Create

```
.env
```

```
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
GOOGLE_WEB_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
```

Run

```bash
flutter run
```

---

# 🔐 Backend

Powered by

- Supabase Authentication
- Supabase Database
- Row Level Security (RLS)
- Google OAuth

---

# 📦 Releases

### [Download Latest APK](https://github.com/vachaspatimishraa/fintrack/releases/latest/download/app-release.apk)

---

# 📄 License

This project is released under the MIT License.

---

# 👨‍💻 Developer

**Vachaspati Mishra**

GitHub

https://github.com/vachaspatimishraa

---

<p align="center">

⭐ If you like this project, consider giving it a star.

</p>