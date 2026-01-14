# Security Policy & Access Control 🛡️

This document explains the security model enforced by `firestore.rules`. The application uses a combination of **Authentication** (who you are) and **Authorization** (what you can do) to secure data.

## 1. Core Concepts

### Helper Functions
The rules rely on three core helper functions to abstract complex logic:
*   `isAuthenticated()`: Checks if `request.auth` is not null.
*   `isOwner(userId)`: Verifies the requester's UID matches the target `userId`.
*   `isAdmin()`: **High-Cost Check**. exacts a document read from `users/{uid}` to check if `role == 'admin'`.

## 2. Collection Rules

### 👤 Users (`/users/{userId}`)
*   **Read**: Public. Anyone can view profiles (needed for attributing posts/comments).
*   **Write**:
    *   **Owner**: You can edit your own profile (Bio, Name).
    *   **Admin**: Admins can ban users or edit profiles (moderation).

### 📝 Posts (`/posts/{postId}`)
*   **Read**: Public.
*   **Create**: Authenticated Users only. Must set `authorId` to their own UID.
*   **Update**:
    *   **Author**: Can edit their own post.
    *   **Admin**: Can edit any post (e.g., removing offensive content).
*   **Delete**:
    *   **Author**: Can delete their own post.
    *   **Admin**: Can delete any post.

### 💬 Comments (`/comments/{commentId}`)
Comments have a special **"Triple-Delete"** rule for moderation.

*   **Read**: Public.
*   **Create**: Authenticated Users only.
*   **Delete**: Allowed if **ANY** of the following are true:
    1.  **Comment Author**: You wrote the comment.
    2.  **Admin**: You have the global admin role.
    3.  **Post Author**: You wrote the *Post* that this comment is attached to.
        *   *Note*: This requires an extra database read (`get()`) to fetch the parent Post's `authorId`.

### 🚩 Reports (`/reports/{reportId}`)
*   **Read/Update/Delete**: **Admin Only**. Regular users cannot see reports.
*   **Create**: Authenticated Users can create reports (must attribute to self).

## 3. Threat Model & Mitigations
*   **Impersonation**: `request.resource.data.authorId == request.auth.uid` checks prevent users from posting as someone else.
*   **Privilege Escalation**: The `isAdmin()` check is server-side. Even if a user modifies the client-side code, Firestore will reject the write if the database record doesn't say "admin".
*   **Data Validation**: While strict types aren't currently enforced in rules, the application code handles type parsing safely.
