# flutter-mobile/Dockerfile
# Use Flutter stable image with Android SDK
# Note: tag '3.32.5-stable' may not exist; use 'stable' to get latest stable
FROM cirrusci/flutter:stable
WORKDIR /app
# Copy pubspec & get deps
COPY pubspec.* ./
RUN flutter pub get
# Copy source & build
COPY . .
# Build Android APK (SDK v35.0.1 included)
RUN flutter build apk --release