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
- **Featured Posts**: Admins can highlight special posts on the home page.
- **Tags & Categories**: Organize content for easier discovery.

### 🔍 Discovery
- **Explore Page**: Browse all posts in a clean grid layout.
- **Instant Search**: Client-side filtering by Title or Author as you type.
- **Navigation**: Clean, routing-based navigation structure (GoRouter).

### 💬 Social (New!)
- **Advanced Comments**: 
  - **Nested Replies**: Threaded conversations (Max depth 1).
  - **Tagging**: Reply to users with auto-generated `@username` tags.
  - **Status**: "Replying to..." context visible in profile tracking.
- **Likes**: Interactive like buttons for both Posts and Comments.
- **Reporting**: Community moderation tools to report inappropriate content.

### 👤 Profile Hub
- **Public Profiles**: View any user's bio and published posts.
- **Personal Dashboard**: 
  - **My Posts**: Manage your published content.
  - **My Comments**: Track and manage your discussions across the platform.
- **Customization**: Editable Bio with Markdown support.

### 🛡️ Admin Panel
- **Role-Based Access**: Secure Admin Panel accessible only to users with `role: 'admin'`.
- **User Management**: View all users, ban/unban capabilities.
- **Content Moderation**: Delete any post or comment to maintain community standards.
- **Strict Authorization**: Server-side security rules prevent unauthorized role escalation.

### 🛡️ Security Architecture
- **Firestore Rules**: Comprehensive RBAC (Role-Based Access Control) for all collections.
- **Data Integrity**: 
  - Comments can only be deleted by their author or an admin.
  - User profiles can only be edited by the owner.
- **Input Sanitization**: Markdown link sanitization to prevent XSS.

### � Agentic Workflow
- **Memory Log**: Automated session logging to track project evolution (`memory/current_log.md`).
- **Smart Context**: Powered by Google Gemini 2.0 Flash for context-aware development.

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

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    - Create a project on Firebase Console.
    - Run `flutterfire configure` to generate `lib/firebase_options.dart`.
    - Enable **Authentication** (Email/Password).
    - Enable **Firestore Database**.
    - **Indexes**: Create required composite indexes (links provided in debug console).

4.  **Security Rules**
    - Deploy `firestore.rules` to secure your database.

5.  **Run**
    ```bash
    flutter run -d chrome
    ```

## 📄 License

MIT License.
