# Driver App

A Flutter mobile application for driver management with Firebase integration.

## Features

### Driver Features
- **Registration**: Drivers can register with name and phone number
- **Status Management**: Three status levels - pending, approved, rejected
- **Waiting Screen**: Pending drivers see a waiting screen with status updates
- **Dashboard**: Approved drivers access a personalized dashboard
- **Payout System**: Manual payout request and tracking
- **Clean UI**: Simple and intuitive interface

### Admin Features
- **Hidden Login**: Admin access through hidden activation (tap logo 5 times)
- **Driver Management**: Approve or reject driver applications
- **Payout Management**: Process payout requests manually
- **Dashboard**: Overview of drivers and payouts
- **Real-time Updates**: Live status monitoring

## Technical Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Backend**: Firebase (Authentication, Firestore)
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage

## Project Structure

```
lib/
├── controllers/          # State management controllers
│   ├── auth_controller.dart
│   ├── driver_controller.dart
│   └── admin_controller.dart
├── models/              # Data models
│   ├── driver_model.dart
│   └── payout_model.dart
├── views/               # UI screens
│   ├── auth/           # Authentication screens
│   ├── driver/         # Driver screens
│   ├── admin/          # Admin screens
│   ├── payout/         # Payout screens
│   └── splash_screen.dart
├── widgets/            # Reusable UI components
│   ├── custom_button.dart
│   └── custom_text_field.dart
├── routes/             # App routing
│   └── app_pages.dart
├── bindings/           # Dependency injection
│   ├── auth_binding.dart
│   ├── driver_binding.dart
│   └── admin_binding.dart
├── main.dart           # App entry point
└── firebase_options.dart # Firebase configuration
```

## Product Documentation

- Turkish architecture and function list: [`docs/proje-mimari-fonksiyon-listesi.md`](docs/proje-mimari-fonksiyon-listesi.md)
- Investor/legal partner landing page: [`landing_page/index.html`](landing_page/index.html)

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase project
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd driver_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Database Structure

### Drivers Collection
```javascript
drivers/{driverId} {
  name: "John Doe",
  phone: "+1234567890",
  status: "pending|approved|rejected",
  createdAt: "2024-01-01T00:00:00.000Z",
  updatedAt: "2024-01-01T00:00:00.000Z"
}
```

### Admins Collection
```javascript
admins/{adminId} {
  email: "admin@example.com",
  createdAt: "2024-01-01T00:00:00.000Z"
}
```

### Payouts Collection
```javascript
payouts/{payoutId} {
  driverId: "driver123",
  amount: 100.50,
  description: "Weekly earnings",
  status: "pending|completed|rejected",
  createdAt: "2024-01-01T00:00:00.000Z",
  updatedAt: "2024-01-01T00:00:00.000Z",
  completedAt: "2024-01-02T00:00:00.000Z"
}
```

## Usage

### For Drivers
1. **Registration**: Open app → Register with name and phone → Create password
2. **Waiting**: If pending, wait for admin approval
3. **Dashboard**: Once approved, access dashboard with earnings and payout options
4. **Payouts**: Request payouts and track history

### For Admins
1. **Access**: Tap app logo 5 times on registration screen → Enter admin credentials
2. **Dashboard**: View overview of drivers and payouts
3. **Driver Management**: Approve/reject driver applications
4. **Payout Management**: Process payout requests

## Security Features

- Firebase Authentication for secure login
- Role-based access control (Driver/Admin)
- Input validation and sanitization
- Secure Firestore rules (configure as needed)

## Configuration

### Admin Setup
1. Create admin user in Firebase Authentication
2. Add admin document to `admins` collection with admin UID
3. Use admin credentials for hidden login

### Firestore Rules
Configure security rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Drivers can read/write their own documents
    match /drivers/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admins can read all drivers
    match /drivers/{userId} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Payouts access control
    match /payouts/{payoutId} {
      allow read, write: if request.auth != null && 
        (resource.data.driverId == request.auth.uid ||
         exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
    }
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository.