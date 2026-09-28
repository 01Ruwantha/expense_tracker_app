# <p align="center"><img src="https://github.com/01Ruwantha/expense_tracker_app/blob/main/assets/images/splash_logo_light.png?raw=true" alt="App Logo" width="120"/></p>
# <p align="center">Expense Tracker</p>
<p align="center">Smart spending, smarter saving.</p>

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Auth%20%7C%20Firestore-orange.svg)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5.1-purple.svg)](https://riverpod.dev)
[![Hive](https://img.shields.io/badge/Hive-2.2.3-yellow.svg)](https://docs.hivedb.dev/)

*A production-ready expense tracker app built with Flutter, Clean Architecture, and Riverpod state management.*

</div>

## 📹 Video
    
<p align="center">
  <!-- Replace with your actual demo GIF link -->
  <img 
  src="https://github.com/01Ruwantha/expense_tracker_app/blob/73ba64ec7d3e5caccf88c620cd24ac6bd0a8f207/assets/video/Expense_tracker.gif?raw=true" 
  alt="App Demo Video" 
  width="150" 
  height="300"
/>
</p>

## 📱 Screenshots

<div align="center">

| Splash Screen | Home | History |
|-------------|---------|--------------------|
| <img src="https://github.com/01Ruwantha/expense_tracker_app/blob/0a7514cd3adba4dbfb00388a0d751250cdfb5f56/assets/screenshots/splash_page.jpeg" alt="Splash" width="150" height="300"> | <img src="https://github.com/01Ruwantha/expense_tracker_app/blob/0a7514cd3adba4dbfb00388a0d751250cdfb5f56/assets/screenshots/home_page.jpeg" alt="home" width="150" height="300"> | <img src="https://github.com/01Ruwantha/expense_tracker_app/blob/ffd3947c64c2c40ed6635070b3b6d8fceaf4a6dd/assets/screenshots/history_page.jpeg" alt="history" width="150" height="300"> |

| Categories | Settings  |
|-------------|------------------|
| <img src="https://github.com/01Ruwantha/expense_tracker_app/blob/ffd3947c64c2c40ed6635070b3b6d8fceaf4a6dd/assets/screenshots/categories_page.jpeg" alt="Add Expense" width="150" height="300"> | <img src="https://github.com/01Ruwantha/expense_tracker_app/blob/ffd3947c64c2c40ed6635070b3b6d8fceaf4a6dd/assets/screenshots/settings_page.jpeg" alt="Settings" width="150" height="300">|

</div>

## ✨ Features

### 🎯 Core Features
- **💸 Expense Management** - Add, edit, and delete expenses with detailed notes, categories, and dates.
- **📊 Monthly Dashboard** - Get a clear overview of your monthly spending with budget progress bars and recent transactions.
- **📈 Category Analytics** - Visualize your spending habits with interactive donut charts, category breakdowns, and monthly insights.
- **🔍 Advanced History** - Search, filter by category, and filter by date (this month, last 7 days, custom range) to find any transaction instantly.
- **🎯 Monthly Budgeting** - Set a monthly budget target and track your progress with real-time visual indicators.
- **🌗 Light & Dark Mode** - Full theme support with a beautiful Material 3 design system, persisted locally via Hive.

### 🎨 User Experience
- **📱 Beautiful UI/UX** - Modern, intuitive interface built with the Stitch M3 design system.
- **✍️ Custom Typography** - Uses Google Fonts (`Manrope` for headlines/body and `JetBrains Mono` for numbers/currency).
- **⚡ Smooth Animations** - Elegant transitions and skeleton loaders for a polished feel.
- **📴 Offline Settings** - Theme preferences and budget settings persist locally using Hive.
- **📅 Smart Date Grouping** - Expenses automatically grouped into "Today", "Yesterday", and specific dates.

### 🔐 Authentication & Security
- **🔑 Secure Sign-in/Sign-up** - Firebase Authentication with Email/Password.
- **📧 Password Reset** - Built-in password reset flow via email.
- **👤 User Profiles** - Personalized experience with user display names and avatars.
- **🔒 Data Protection** - Secure Firestore rules ensuring users only access their own data.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.5.0 or higher)
- Dart (3.5 or higher)
- Firebase Account
- (optional, for Firebase CLI)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/01Ruwantha/expense_tracker_app.git
   cd expense_tracker_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```
3. **Set up Firebase**

  Create a Firebase project in the Firebase Console.
  Enable Email/Password Authentication.
  Enable Cloud Firestore database.
  Run the FlutterFire CLI to configure your app:
  ```bash
   flutterfire configure
   ```
   This will generate the lib/firebase_options.dart file.

4. **Set up App Icons & Splash Screen**
  ```bash
  flutter pub run flutter_launcher_icons
  flutter pub run flutter_native_splash:create
  ```
5. **Run the app**
 ```bash
  flutter run
  ```

### 🏗️ Architecture & Project Structure
This project follows Clean Architecture principles, separating the app into distinct layers (Data, Domain, Presentation) and features. State management is handled by Riverpod.
```
expense_tracker_app/
├── android/                    # Android specific files
├── ios/                        # iOS specific files
├── assets/                     # Images, icons, fonts
├── lib/
│   ├── core/                   # Shared components across features
│   │   ├── constants/          # App strings, colors
│   │   ├── errors/             # Failure classes, Either types
│   │   ├── providers/          # Global providers (Auth, Repos)
│   │   ├── theme/              # AppTheme, ThemeProvider
│   │   ├── utils/              # Formatters, ExpenseCategory
│   │   └── widgets/            # Reusable UI components
│   ├── features/               # Feature modules (Clean Architecture)
│   │   ├── auth/               # Authentication feature
│   │   │   ├── data/           # Repositories, Data sources
│   │   │   ├── domain/         # Entities, Repository interfaces
│   │   │   └── presentation/   # Views, Widgets, Controllers
│   │   ├── expenses/           # Expense management (CRUD)
│   │   ├── history/            # Expense history and filtering
│   │   ├── home/               # Dashboard and summary widgets
│   │   └── settings/           # App settings and preferences
│   ├── routing/                # GoRouter setup (app_router.dart)
│   └── main.dart               # App entry point
└── pubspec.yaml                # Dependencies
```
## 🛠️ Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| Flutter	| Cross-platform UI framework	| 3.5+ |
| Dart	| Programming language	| 3.5+ |
| Firebase Core	| Backend initialization	| ^3.6.0 |
| Firebase Auth	| Authentication	| ^5.3.1 |
| Cloud Firestore	| Real-time database	| ^5.4.3 |
| Riverpod	| State management	| ^2.5.1 |
| GoRouter	| Navigation routing	| ^14.3.0 |
| Hive	| Local database (Settings)	| ^2.2.3 |
| Dartz	| Functional programming (Either)	| ^0.10.1 |
| Google Fonts	| Typography	| ^6.2.1 |
| Intl	| Date & Currency formatting	| ^0.19.0 |
| Equatable	| Value equality	| ^2.0.5 |
| UUID	| Unique ID generation	| ^4.5.1 |

## 🎨 Design System & Theming
The app uses a custom Material 3 theme built from design tokens:

  Fonts: Manrope (Headings/Body) + JetBrains Mono (Numbers/Labels).
  Light Mode: Teal-based palette with soft, clean backgrounds.
  Dark Mode: Deep navy backgrounds with high-contrast teal accents.
  Persistence: Theme selection and monthly budget are saved locally using Hive.

## 🤝 Contributing
We welcome contributions! Please feel free to submit issues, fork the repository, and create pull requests.

1. Fork the project
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## 📞 Support
Having trouble? Contact us or create an issue:

- 📧 Email: [2000ruwantha@gmail.com](mailto:2000ruwantha@gmail.com)
- 🐛 [Bug Reports](https://github.com/01Ruwantha/expense_tracker_app/issues)
- 💡 [Feature Requests](https://github.com/01Ruwantha/expense_tracker_app/issues)
- 🔧 [Technical Support](https://github.com/01Ruwantha/expense_tracker_app/issues)

<div align="center">
<p align="center">
  <img 
  src="https://github.com/01Ruwantha/expense_tracker_app/blob/0a7514cd3adba4dbfb00388a0d751250cdfb5f56/assets/images/Expense_tracker_img.png" 
  alt="QuickSlice Post Image" 
  width="1080" 
  height="720"
/>
</p>
  
Made with ❤️ and ☕ by Ruwantha Madhushan

Track your expenses, master your finances!

</div>
