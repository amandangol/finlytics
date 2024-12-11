# Finlytics: Your Comprehensive Personal Finance Companion 💰

## 🌟 Overview

Finlytics is an advanced, AI-powered Flutter application designed to transform personal finance management. By combining cutting-edge technology with intuitive design, Finlytics offers users a holistic solution for tracking, analyzing, and optimizing their financial health.

## 🚀 Key Features

### 1. Comprehensive Financial Dashboard
- **Interactive Financial Insights**
  - Multiple visualization options for comprehensive financial analysis
  - Dynamic transaction filtering across various time periods
  - Detailed performance metrics and visual representations

 <img src="https://github.com/user-attachments/assets/7b67f7d3-226f-4525-a9c1-93ce3cdee2f2" width="300"/> <img src="https://github.com/user-attachments/assets/74618e9d-550a-4673-9d3f-bb5d4411fcf2" width="300"/>

### 2. Advanced Expense Tracking
- **Seamless Transaction Management**
  - Add, edit, and delete transactions with ease
  - Multi-account support
  - Detailed transaction categorization
- **Smart Validation**
  - Intelligent expense validation
  - Real-time balance checks
  - Overdraft prevention mechanisms

### 3. Powerful Data Visualization
- **Advanced Charting Capabilities**
  - Income vs. Expense Bar Chart
  - Monthly Transactions Line Chart
  - Category Breakdown Visualization
- **Interactive Features**
  - Real-time chart updates
  - Color-coded metrics for instant comprehension
  - Responsive design across devices

### 4. AI-Powered Financial Assistant
- **Gemini AI Integration**
  - Personalized financial advice
  - Intelligent transaction analysis
  - Spending pattern recommendations
- **Predictive Insights**
  - Potential future expense forecasting
  - Savings optimization suggestions
  - Comprehensive financial health assessment

### 5. Secure Authentication & Privacy
- **Firebase-Powered Security**
  - Robust user authentication
  - Secure data storage
  - User-friendly login and signup processes

## 📊 Comprehensive Financial Metrics

Finlytics tracks and analyzes critical financial indicators:
- Total Income
- Total Expenses
- Net Balance
- Savings Rate
- Highest Income/Expense Categories
- Net Worth Analysis

## 🛠 Technical Architecture

### Technology Stack
- **Frontend Framework:** Flutter
- **Backend Services:**
  - Firebase Firestore (Data Persistence)
  - Firebase Authentication
  - Firebase Storage
- **AI Integration:** Google Gemini
- **Visualization:** FL Chart Library
- **Utilities:** Intl Package for Date Management

### Technical Highlights
- Cross-platform compatibility
- Responsive and adaptive UI
- Smooth animations and transitions
- Comprehensive error handling
- Gradient-based design system

## 📱 Core Functionalities

### Transaction Management
- Supports income and expense transactions
- Real-time balance validation
- Prevents potential overdrafts
- Animated, user-friendly interface

#### Transaction Input Fields
1. Amount (with numeric validation)
2. Detailed transaction description
3. Flexible date selection
4. Transaction type toggle
5. Category selection
6. Multi-account support

## 🔍 Unique Features

- Voice input for AI financial assistant
- Predefined financial query suggestions
- Profile customization
- Secure account management

## 🛠 Comprehensive Setup Guide

### 1. Prerequisites

#### Required Software
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio or Visual Studio Code
- Git
- Android SDK

#### Required Accounts
- Google Cloud Platform account
- Firebase account
- Google AI Studio account (for Gemini API)

### 2. Development Environment Setup

#### Install Flutter
1. Download Flutter SDK from official website:
   ```bash
   https://docs.flutter.dev/get-started/install
   ```

2. Add Flutter to system PATH
   ```bash
   export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/flutter/bin"
   ```

3. Verify Flutter installation
   ```bash
   flutter doctor
   ```

#### Install Android Studio or VS Code
- Install Flutter and Dart plugins

### 3. Firebase Setup

#### Create Firebase Project
1. Go to Firebase Console: https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: "Finlytics"
4. Enable Google Analytics (recommended)

#### Configure Firebase for Flutter
1. In Firebase Console, click "Add app"
2. Select Flutter/Android platform
3. Register app with package name (e.g., `com.finlytics.app`)
4. Download `google-services.json`
5. Place `google-services.json` in `android/app/` directory

#### Firebase Services to Enable
- Authentication
- Firestore Database
- Firebase Storage
- Firebase Cloud Messaging (optional)

### 4. Gemini API Key Configuration

#### Obtain Google AI Studio API Key
1. Visit: https://makersuite.google.com/app/apikey
2. Click "Create API Key"
3. Copy the generated API key

#### Create Environment Configuration
1. Create `.env` file in project root
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

2. Add to `.gitignore` to prevent accidental commits
   ```
   .env
   ```

3. Install `flutter_dotenv` package
   ```bash
   flutter pub add flutter_dotenv
   ```

4. Configure in `main.dart`
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   void main() async {
     await dotenv.load(fileName: ".env");
     runApp(MyApp());
   }
   ```

### 5. Project Dependencies

#### Install Dependencies
```bash
flutter pub get
```

#### Generate Required Files
```bash
flutter pub run build_runner build
```

### 6. Running the Application

#### Android Setup
1. Connect Android device or start emulator
2. Enable USB debugging on device
3. Run application:
   ```bash
   flutter run
   ```

### 7. Troubleshooting

#### Common Issues
- Ensure all Flutter dependencies are installed (use flutter doctor)
- Check Firebase configuration
- Verify API key permissions
- Update Flutter and Dart SDKs

#### Debugging
```bash
flutter doctor -v
```

### 9. Security Best Practices
- Never commit API keys or sensitive information
- Use environment variables
- Enable Firebase security rules
- Implement proper authentication

## 🔒 Recommended Firebase Security Rules

Add to `firestore.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /transactions/{transactionId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

## 📝 Notes
- Minimum Android version: 6.0
- Minimum iOS version: 12.0
- Stable internet connection required

**Happy Coding! 🚀**
