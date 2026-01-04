# Android (đã hoạt động)
flutter build apk --release

# iOS (cần macOS + Xcode)
cd ios && pod install && cd ..
flutter build ios --release

# Web
flutter run -d chrome --web-port=50077

# macOS (cần macOS)
cd macos && pod install && cd ..
flutter build macos --release

# Linux
flutter build linux --release

# Windows (cần Visual Studio với C++ workload)
flutter build windows --release