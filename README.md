# 💰 FinTrack

<div align="center">

<img src="assets/images/logo.png" alt="FinTrack Logo" width="120"/>

### Smart Personal Finance Manager

Track income, expenses, budgets, accounts, and reports with a beautiful, fast, and privacy-focused Flutter application.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-40C4FF)
![Isar](https://img.shields.io/badge/Isar-Database-00C853)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E)

</div>

---

# 📖 Overview

FinTrack is a modern Flutter-based personal finance application designed to help users manage their money efficiently. It provides a clean Material 3 interface, offline-first architecture, secure local storage, cloud synchronization, detailed reports, and customizable settings.

The application follows **Clean Architecture**, **MVVM**, and **Riverpod** for maintainable and scalable development.

---

# ✨ Features

## 💳 Account Management

- Create unlimited accounts
- Optional opening balance
- Multiple account types
- Automatic balance calculation
- Account-wise transaction history

---

## 💸 Transactions

- Income & Expense tracking
- Attach receipt images
- Transaction notes
- Duplicate transactions
- Edit/Delete transactions
- Undo delete
- Payment methods
- Category management
- Search transactions
- Filter by date
- Filter by account
- Filter by category

---

## 📊 Dashboard

- Total Balance
- Total Income
- Total Expenses
- Recent Transactions
- Account Overview
- Quick Actions

---

## 📈 Reports

Generate reports in

- PDF
- Excel

Reports include

- Income
- Expense
- Category-wise summary
- Account summary
- Monthly reports
- Custom date range

---

## 🌙 Appearance

- Light Theme
- Dark Theme
- AMOLED Theme
- Material 3 Design
- Dynamic Colors
- Display Density
- Text Scaling

---

## 🌍 Localization

Supports

- English
- Hindi

Designed to support additional languages easily.

---

## 💱 Currency Support

Currently supported

- ₹ Indian Rupee
- $ US Dollar
- Many More 

Currency updates throughout the application.

---

## 🔐 Security

- App Lock
- Device PIN / Pattern / Password
- Fingerprint Authentication
- Face Unlock (Supported Devices)
- Secure Storage

---

## ♿ Accessibility

- High Contrast Mode
- Reduce Motion
- Haptic Feedback
- Text Scaling
- Touch Target Size
- Keyboard Navigation
- Screen Reader Support

---

## ☁ Backup & Sync

- Local Storage using Isar
- Cloud Sync using Supabase
- Manual Backup
- Restore Backup

---

## 📱 Platform Support

- Android ✅

Future Support

- iOS
- Windows
- macOS
- Linux
- Web

---

# 🏗 Architecture

```
lib/
│
├── core/
│   ├── constants/
│   ├── database/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── accounts/
│   ├── transactions/
│   ├── dashboard/
│   ├── reports/
│   ├── settings/
│   ├── splash/
│   └── onboarding/
│
├── shared/
│
└── main.dart
```

---

# 🛠 Tech Stack

| Technology | Usage |
|------------|-------|
| Flutter | UI Framework |
| Dart | Programming Language |
| Riverpod | State Management |
| Isar | Local Database |
| Supabase | Cloud Backend |
| Flutter Local Notifications | Notifications |
| Local Auth | Biometric Authentication |
| Image Picker | Receipt Images |
| Share Plus | Share Transactions |
| PDF | PDF Reports |
| Excel | Excel Export |

---

# 📸 Screens

- Splash
- Onboarding
- Dashboard
- Accounts
- Transactions
- Transaction Details
- Add Transaction
- Reports
- Settings
- Appearance
- Accessibility
- Security
- Language
- Currency
- Backup

---

# 🚀 Getting Started

## Clone

```bash
git clone https://github.com/yourusername/fintrack.git
```

```bash
cd fintrack
```

---

## Install Packages

```bash
flutter pub get
```

---

## Generate Isar Files

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Run

```bash
flutter run
```

---

# 📂 Project Structure

```
lib
├── core
├── features
│   ├── accounts
│   ├── transactions
│   ├── dashboard
│   ├── reports
│   ├── settings
│   └── splash
├── shared
└── main.dart
```

---

# 🎨 Design Principles

- Material Design 3
- Responsive UI
- Offline First
- Accessibility Friendly
- Dark Mode
- Smooth Animations
- Production Ready Architecture

---

# 🔒 Privacy

- Data stored locally
- Secure authentication
- Optional cloud synchronization
- No unnecessary permissions
- User-controlled backups

---

# 🧪 Testing

Run tests

```bash
flutter test
```

Analyze code

```bash
flutter analyze
```

Format code

```bash
dart format .
```

---

# 📌 Roadmap

- Investment Tracking
- Budget Planner
- Recurring Transactions
- Goals & Savings
- OCR Receipt Scanner
- AI Spending Insights
- Bank Synchronization
- Widgets
- Wear OS Support

---

# 🤝 Contributing

1. Fork the repository
2. Create a feature branch

```bash
git checkout -b feature/your-feature
```

3. Commit your changes

```bash
git commit -m "Add new feature"
```

4. Push

```bash
git push origin feature/your-feature
```

5. Open a Pull Request

---

# 👨‍💻 Developer

**Vachaspati Mishra**

Flutter Developer

Built with ❤️ using Flutter.
