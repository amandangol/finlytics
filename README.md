# Finlytics: Your Comprehensive Personal Finance Companion 💰

## 🌟 Overview

Finlytics is an advanced, AI-powered Flutter application designed to transform personal finance management. By combining cutting-edge technology with intuitive design, Finlytics offers users a holistic solution for tracking, analyzing, and optimizing their financial health.

https://github.com/user-attachments/assets/723b1df5-e924-466a-b42b-364ec4419759


https://github.com/user-attachments/assets/64ed372e-d5ad-4653-b226-b3253d275837


https://github.com/user-attachments/assets/b576f56d-478a-4a25-af6b-eb409ddcf700

## 🚀 Key Features

### 1. Comprehensive Financial Dashboard
- **Interactive Financial Insights**
  - Multiple visualization options for comprehensive financial analysis
  - Dynamic transaction filtering across various time periods
  - Detailed performance metrics and visual representations

    https://github.com/user-attachments/assets/92ddb1ae-e387-4a84-95cf-5d94b2c3c168

### 2. Advanced Expense Tracking
- **Seamless Transaction Management**
  - Add, edit, and delete transactions with ease
  - Multi-account support
  - Detailed transaction categorization
- **Smart Validation**
  - Intelligent expense validation
  - Real-time balance checks
  - Overdraft prevention mechanisms

    https://github.com/user-attachments/assets/06b4c561-ac97-4453-a1b4-af5fe06c1a71

### 3. Powerful Data Visualization
- **Advanced Charting Capabilities**
  - Income vs. Expense Bar Chart
  - Monthly Transactions Line Chart
  - Category Breakdown Visualization
- **Interactive Features**
  - Real-time chart updates
  - Color-coded metrics for instant comprehension
  - Responsive design across devices

    https://github.com/user-attachments/assets/2962c3b4-2832-4279-91a7-10e212f034f2

### 4. AI-Powered Financial Assistant
- **Gemini AI Integration**
  - Personalized financial advice
  - Intelligent transaction analysis
  - Spending pattern recommendations
- **Predictive Insights**
  - Potential future expense forecasting
  - Savings optimization suggestions
  - Comprehensive financial health assessment

    https://github.com/user-attachments/assets/bab5b96b-a2e0-4219-b935-304701fe799a

### 5. Currency Format Customization  
- **Personalized Currency Display**  
  - View balances and transactions in your preferred currency format  
  - Support for various regional number and currency formats

    https://github.com/user-attachments/assets/10a1e82f-f98d-4151-b825-257b461bcd65

- **Enhanced Financial Reports**  
  - Tailored reporting with customizable currency display options  
  - Consistent formatting for improved readability  

- **User-Friendly Settings**  
  - Easy-to-configure currency format preferences  

### 6. Secure Authentication & Privacy
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
