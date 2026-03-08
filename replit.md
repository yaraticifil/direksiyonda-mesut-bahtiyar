# Driver App

## Overview
A Flutter web application for driver management with Firebase integration. Built with Flutter 3.32 / Dart 3.8 using the GetX state management framework.

## Recent Changes
- 2026-02-11: Initial import setup for Replit environment
  - Installed Flutter via Nix
  - Fixed duplicate `checkAuthAndRedirect` method in auth_controller.dart
  - Fixed duplicate Firestore query in driver_controller.dart
  - Downgraded google_fonts to ^6.3.2 for Dart 3.8 compatibility
  - Created missing assets/images and assets/icons directories

## Project Architecture
- **Framework**: Flutter 3.32 (Dart 3.8)
- **State Management**: GetX
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Structure**:
  - `lib/main.dart` - Entry point
  - `lib/controllers/` - GetX controllers (auth, driver, admin)
  - `lib/models/` - Data models (Driver, Payout)
  - `lib/views/` - Screen widgets organized by feature
  - `lib/routes/` - GetX routing configuration
  - `lib/bindings/` - GetX dependency bindings
  - `lib/widgets/` - Reusable UI components
  - `web/` - Web platform files

## Configuration
- Firebase config in `lib/firebase_options.dart` (placeholder keys - needs real Firebase project)
- Runs on port 5000 for web development
- Workflow: `flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0`

## User Preferences
- None recorded yet
