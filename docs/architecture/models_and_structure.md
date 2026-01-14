# Project Architecture & Data Models 🏗️

This document outlines the high-level architecture, directory structure, and data models of the **Çarpık Kaldırımlar** project.

## 1. Directory Structure

The project follows a standard **Feature-Layer** architecture:

*   **`lib/models/`**: Pure Dart data classes defining the schema. Contains `fromJson`/`toJson` logic.
*   **`lib/services/`**: The Business Logic Layer. Handles interactions with Firebase (Firestore, Auth).
    *   *Examples*: `AuthService`, `PostService`.
*   **`lib/views/`**: Full-screen widgets (Pages). Maps one-to-one with Routes.
    *   *Examples*: `HomeView`, `PostDetailView`, `ProfileView`.
*   **`lib/widgets/`**: Reusable UI components used across multiple views.
    *   *Examples*: `PostCard`, `CommentCard`.
*   **`lib/router/`**: Navigation configuration using `go_router`.
*   **`lib/utils/`**: Helper functions and constants (e.g., Exception handlers).

## 2. Data Models (Firestore Schema)

### 👤 AppUser (`users` collection)
Represents a registered user.
*   `id`: Unique Firebase UID.
*   `username`: Unique handle (e.g., "saka") used for mentions and display.
*   `email`: User's email address.
*   `role`: Authorization role (`'user'` or `'admin'`).
*   `bio`: Markdown-supported biography.

### 📝 Post (`posts` collection)
Represents a blog post / article.
*   `id`: UUID.
*   `title` & `content`: Main content (Markdown).
*   `author` & `authorId`: Denormalized author info for quick display.
*   `category`: Post category (e.g., 'Genel', 'Teknoloji').
*   `tags`: List of string tags for lookup.
*   `likes`: List of User IDs who liked the post.
*   `viewCount`: Integer counter (incremented atomically).
*   `isFeatured`: Boolean flag for "Editor's Choice" display.

### 💬 Comment (`comments` collection)
**Design Decision:** Comments are stored in a **top-level collection**, NOT as a sub-collection of Posts. This allows efficient querying of "User's Comments" for the Profile view.
*   `postId`: Reference to the parent Post.
*   `authorId` & `authorName`: Denormalized author info.
*   `text`: Comment content.
*   `replyToId`: ID of the parent comment (if it is a reply).
*   `replyToUserName`: Username of the person being replied to (for UI context).
*   `depth`: Nesting level (Max depth 1 enforced by logic).

### 🚩 Report (`reports` collection)
Used for moderation.
*   `targetId`: ID of the Post or Comment being reported.
*   `type`: `'post'` or `'comment'`.
*   `reason`: User-selected reason (e.g., "Spam", "Harassment").
*   `status`: `'pending'`, `'resolved'`, etc.

## 3. State Management

The app uses the **Provider** pattern.
*   **Services** (e.g., `PostService`, `AuthService`) extend `ChangeNotifier`.
*   UI components listen to these Services via `context.watch<T>()` or `Consumer<T>` to rebuild when data changes.
*   Dependency Injection is handled at the root mapping providers to the widget tree.

## 4. Security & Testing
*   **Security**: Enforced via `firestore.rules`.
    *   Writes are strictly validated based on `request.auth.uid`.
    *   Role-based access (`isAdmin`) for sensitive operations.
*   **Testing**:
    *   **Unit**: Models and Services (`setPosts` injection pattern).
    *   **Widget**: Security UI (e.g., Delete buttons) and Rendering.
