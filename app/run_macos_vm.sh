#!/bin/bash
# Script to run Flutter app on macOS VM (VMware/Parallels) without Metal support
# Use this script when running on virtualized macOS

echo "Running Flutter app with software rendering (for VM without Metal)..."
flutter run -d macos --enable-software-rendering
