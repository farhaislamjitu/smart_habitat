# Smart Habitat

A Flutter-based smart home monitoring and control application. Smart Habitat lets users track device status, control connected devices, view historical data, and receive real-time alerts — all from a single, unified dashboard.

## Features

- **Authentication** — Secure login and registration
- **Dashboard** — At-a-glance overview of your smart home
- **Device Control** — Manage and control connected devices remotely
- **Device Status** — Monitor single or multiple devices in real time
- **History** — Review past activity and sensor data
- **Alerts** — Get notified of important events
- **Profile & Settings** — Manage your account and app preferences

## Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase (Authentication, Database, Notifications)
- **Platforms:** Android, iOS, Web, Windows, macOS, Linux

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A configured Firebase project (`google-services.json` for Android / `GoogleService-Info.plist` for iOS)

### Installation

```bash
git clone https://github.com/farhaislamjitu/smart_habitat.git
cd smart_habitat
flutter pub get
flutter run
```

## Project Structure
lib/
├── screens/ # UI screens (auth, home, control, history, alerts, settings, profile)
├── services/ # Firebase & app services (auth, database, notifications, theme)
├── utils/ # Shared utilities and theming
└── main.dart # App entry point

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Firebase documentation](https://firebase.google.com/docs)

## License

This project currently has no license specified.
