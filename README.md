# cce106_finance_project

A Flutter + Firebase starter with user authentication (login/register), configurable dashboard, and clean modern UI.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or newer)
- [Git](https://git-scm.com/)
- A code editor (VS Code, Android Studio, etc.)
- Web/Android/iOS enabled via Flutter tools

### 1. Clone the Repository
- Run:
  ```
  git clone https://github.com/LJPathay/CCE106_Project.git
  cd CCE106_Projec
  ```

### 2. Install Dependencies
 ```
  flutter pub get
 ```

### 3. Firebase Setup

Firebase is already pre-configured in `lib/firebase_options.dart` for web, Android, iOS, macOS, and Windows.

#### To update for YOUR OWN Firebase project:

- Go to [Firebase Console](https://console.firebase.google.com/), create your project.
- Run:
    ```
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
- Replace/add any required files like `google-services.json` (Android) or `GoogleService-Info.plist` (iOS).

### 4. Run the App


 ```
  flutter run
    or
 Web: 
flutter run -d chrome
Android:
flutter run -d android
iOS(on macOS):  
flutter run -d ios
 ```

### 5. Using the App

- Register a new account from the registration page.
- Login with your credentials.
- Upon successful login, a dashboard screen will confirm access.

### 6. Troubleshooting

- If Firebase throws initialization errors, verify your Firebase configuration.
- For pub errors, try `flutter clean` then `flutter pub get`.
- Confirm Flutter/Dart/Firebase package versions are up-to-date.

---

> **Resources**:  
> - [Flutter Documentation](https://docs.flutter.dev/)
> - [FlutterFire Setup](https://firebase.flutter.dev/docs/overview)
