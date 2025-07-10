# flutter-mobile/Dockerfile
# Use cirrusci/flutter:latest (may support Dart >=3.8.1)
FROM cirrusci/flutter:latest
WORKDIR /app
# Copy pubspec & get deps
COPY pubspec.* ./
RUN flutter pub get
# Copy source & build
COPY . .
# Build Android APK (SDK v35.0.1 included)
RUN flutter build apk --release