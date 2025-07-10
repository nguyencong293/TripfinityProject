# flutter-mobile/Dockerfile
# Custom Flutter image with Dart >=3.8.1
FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set Flutter version (update as needed)
ENV FLUTTER_VERSION=3.22.1

# Download and set up Flutter
RUN git clone https://github.com/flutter/flutter.git /opt/flutter -b stable && \
    /opt/flutter/bin/flutter --version

ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    curl -o sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip sdk.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm sdk.zip && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "platforms;android-35" "build-tools;35.0.1"

WORKDIR /app

# Copy pubspec & get deps
COPY pubspec.* ./
RUN flutter pub get

# Copy source & build
COPY . .

# Build Android APK (SDK v35.0.1 included)
RUN flutter build apk --release