# Çarpık Kaldırımlar 📝

A modern, social blogging platform built with **Flutter Web** and **Firebase**.

![Status](https://img.shields.io/badge/Status-Active-success)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange)

## 🌟 Features

### 📖 Content
- **Rich Text Editing**: Write posts using Markdown (Bold, Italic, Headers, Links, etc.).
- **Poetry Support**: Special handling for soft line breaks to preserve poem formatting.
- **External Links**: Safe URL launching for external resources.
- **View Counts**: Track how many people read each post (Atomic increments).

### 🔍 Discovery
- **Explore Page**: Browse all posts in a clean grid layout.
- **Instant Search**: Client-side filtering by Title or Author as you type.

### 💬 Social
- **Comments**: Real-time comment system.
- **Likes**: interactive like button with counters.
- **Moderation**: 
  - Post Authors can delete *any* comment on their post.
  - Users can delete their *own* comments.

### 👤 User System
- **Profile**: customizable profile with Avatar (initials) and **Bio**.
- **Bio**: Supports Markdown formatting.
- **Auth**: Email/Password authentication (expandable to Google Auth).

### 🛡️ Admin Panel
- **Role-Based Access**: Secure Admin Panel accessible only to users with `role: 'admin'`.
- **User Management**: View all users, ban/unban capabilities (UI ready).
- **Dashboard**: Quick stats overview.
- **Strict Authorization**: Admins can moderations (delete) but cannot edit user content.

### 🛡️ Security Architecture
- **Firestore Rules**: Strict, role-based backend security policies.
- **Input Sanitization**: Markdown link sanitization to prevent XSS.
- **Authorization**: Double-verification (UI + Logic) for all write operations.
- **Data Integrity**: User roles are protected from client-side manipulation.

### 🧑‍💻 Developer Experience
- **Smart Logger**: An AI-powered CLI tool (`memory/logger.py`) that automatically generates semantic git commit messages and project log entries.
  - Powered by **Google Gemini 2.0 Flash**.
  - Context-aware: Reads your project history to match your logging style.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Web Target)
- **Language**: Dart
- **Backend / DB**: [Firebase Firestore](https://firebase.google.com/docs/firestore)
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Markdown**: [flutter_markdown](https://pub.dev/packages/flutter_markdown)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed.
- Firebase Account.

### Setup

1.  **Clone the repo**
    ```bash
    git clone https://github.com/karabulut18/carpik_kaldirimlar.git
    cd carpik_kaldirimlar
    ```

2.  **Install Favorites**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    - Create a project on Firebase Console.
    - Run `flutterfire configure` to generate `lib/firebase_options.dart`.
    - Enable **Authentication** (Email/Password).
    - Enable **Firestore Database**.

4.  **Security Rules**
    - **IMPORTANT**: Update your Firestore Rules to allow proper access.
    - Admins need `role: 'admin'` in their user document.

5.  **Environment Variables (Optional)**
    - To use the **Smart Logger**, create a `.env` file in the root:
      ```env
      GEMINI_API_KEY=your_api_key_here
      ```

6.  **Run**
    ```bash
    flutter run -d chrome
    ```

## 📸 Screenshots
*(Add screenshots here)*

## 📄 License

MIT License.
