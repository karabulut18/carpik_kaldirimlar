# Çarpık Kaldırımlar 📝

A modern, social blogging platform built with **Flutter Web** and **Firebase**.

![Status](https://img.shields.io/badge/Status-Active-success)
![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange)

## 🌟 Features

### 📖 Content
- **Rich Text Editing**: Write posts using Markdown (Bold, Italic, Headers, Links, etc.).
- **Poetry Support**: Special handling for soft line breaks to preserve poem formatting.
- **Link Previews**: Automatically generates rich social cards for links shared in posts.
- **View Counts**: Tracks unique readership per post (Authors excluded from their own count).
- **Featured Posts**: Admins can highlight special posts on the home page.
- **Tags & Categories**: Organize content for easier discovery.

### 🔍 Discovery
- **Explore Page**: Browse all posts in a clean grid layout.
- **Instant Search**: Client-side filtering by Title or Author as you type.
- **Navigation**: Clean, routing-based navigation structure (GoRouter).

### 💬 Social
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

## 📂 Project Structure

A quick guide to navigating the codebase:

```
lib/
├── models/         # Data classes (Post, Comment, User, Report)
├── services/       # Business logic & Firebase interactions (AuthService, PostService)
├── views/          # Full-screen pages (HomeView, PostDetailView, LoginView)
├── widgets/        # Reusable UI components
│   ├── post_card.dart          # The main feed item
│   ├── comment_card.dart       # Interactive comment item
│   ├── link_preview_card.dart  # Social preview for external links
│   └── ...
├── utils/          # Helpers (Exception extraction, Date formatting)
└── main.dart       # App entry point & Router configuration
```

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Web Target)
- **Language**: Dart
- **Backend / DB**: [Firebase Firestore](https://firebase.google.com/docs/firestore)
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Markdown**: [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- **Link Previews**: [any_link_preview](https://pub.dev/packages/any_link_preview)

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
    ```bash
    firebase deploy --only firestore:rules
    ```

5.  **Run**
    ```bash
    flutter run -d chrome
    ```

## 📄 License

MIT License.
