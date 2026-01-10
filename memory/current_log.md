# Project Memory Log

## Abstract
Project started: Building a writing sharing platform. Initial pages planned: Home, Explore, Search, Post View, Dashboard, Profile, Auth.

## Log Entries

### Entry 1 [2026-01-06 19:38:04]
Updated implementation plan to include tech stack options. Waiting for user's preference on framework (Next.js, Vite/React, or Astro).

### Entry 2 [2026-01-06 19:40:13]
**Change Abstract:** Added 'Change Abstract' field to log entries.

**Details:**
Refined the logger script to include 'Change Abstract' in each entry. Updated the CLI to accept message, entry abstract, and global abstract update.

### Entry 3 [2026-01-06 19:44:29]
**Change Abstract:** Switched tech stack to Flutter for Web.

**Details:**
Selected Flutter for Web as the tech stack. Updated implementation plan and task list to reflect Flutter-specific requirements and project structure.

### Entry 4 [2026-01-06 19:49:14]
**Change Abstract:** Decided on Provider/Material 3. Initiating SDK setup.

**Details:**
Verified that Flutter SDK is missing. Decided on Provider for state management and Material 3 for design. Explanation added to implementation plan. Starting SDK installation guidance.

### Entry 5 [2026-01-06 19:57:01]
**Change Abstract:** Initialized Flutter Web project and installed dependencies.

**Details:**
Installed Flutter SDK, initialized the project for Web, and installed core dependencies: provider, go_router, and google_fonts. Created the recommended project folder structure.

### Entry 6 [2026-01-06 19:59:20]
**Change Abstract:** Implemented routing and premium theme with Roboto Serif.

**Details:**
Implemented the basic app shell with GoRouter and a Material 3 theme. Integrated Roboto Serif as the primary font and set up a ShellRoute for consistent navigation across pages.

### Entry 7 [2026-01-06 20:02:27]
**Change Abstract:** Built Home Page hero and featured posts.

**Details:**
Developed the Home Page with a responsive hero section and featured writing cards. Created a Post model for content structure. Refined the AppRouter to include a more professional navigation bar with active state highlighting.

### Entry 8 [2026-01-06 20:05:30]
**Change Abstract:** Fixed bugs and launched the app for preview.

**Details:**
Fixed issues in AppRouter and HomeView (GoRouter state.uri.path and InkWell onTap). The app is now running successfully on port 8080.

### Entry 9 [2026-01-06 20:21:28]
**Change Abstract:** Implemented Content Viewing (Explore & Post Details).

**Details:**
Implemented the Content Viewing features: ExploreView for browsing posts and PostDetailView for reading articles. Extracted PostCard into a reusable widget. Updated AppRouter with new routes.

### Entry 10 [2026-01-06 20:52:18]
**Change Abstract:** Implemented Authentication.

**Details:**
Implemented Authentication system (Mock). Created AuthService, LoginView, RegisterView. Integrated with AppRouter for dynamic user menu.

### Entry 11 [2026-01-07 02:32:17]
**Change Abstract:** Implemented Admin, Social, Search, and Profile Features.

**Details:**
Major feature implementations:
1. **Admin Panel**: Role-based access, user management. Verified via Security Rules.
2. **Social**: Comments (Real-time, threaded deletion), Likes, View Counts.
3. **Core**: Markdown rendering for posts, URL launching, Poetry support (Soft Line Breaks).
4. **Search**: Client-side filtering by title/author on Explore page.
5. **Profile**: Editable Bio with Markdown support.
6. **Polishing**: Fixed compilation errors, resolved poetry formatting, and drafted production-ready Firestore Security Rules.

### Entry 11 [2026-01-07 20:13:28]
**Change Abstract:** Completed Security Audit, Refactored User Model, and Enforced Strict Access Control.

- **[2026-01-07] User Profile Navigation & Fixes**
  - **Feature:** Added `PublicUserView` to view user profiles (Avatar, Bio, Posts).
  - **Feature:** Made author names clickable in `PostCard` and `PostDetailView` to navigate to `PublicUserView`.
  - **Fix:** Added safety checks to prevent clicking author names on legacy posts (missing `authorId`), resolving a `GoException` crash.
  - **Refactor:** Added `getUser(uid)` to `AuthService` for clean public profile fetching.
**Details:**
1. **Security Audit**: Patched authorization vulnerability in post editing.
2. **Access Control**: Implemented strict firestore.rules (restricted updates to authors, prevented role escalation).
3. **Refactoring**: Created AppUser model to encapsulate user data.
4. **Sanitization**: Added link sanitization for markdown.

### Entry 12 [2026-01-08 16:42:46]
**Change Abstract:** Refactored Comments & Enhanced Profiles

**Details:**
# Session Memory Log

## Date: 2026-01-08

### Key Achievements
1.  **Dashboard Removal**: The dashboard view and route were removed. Functionality was moved to the Admin Panel or integrated into the main navigation flow.
2.  **Admin Panel Enhancements**:
    - Added navigation to user public profiles from the admin user list.
    - Implemented a safeguard preventing admins from deleting their own accounts.
3.  **Comments Refactoring**:
    - Migrated comments from subcollections (`posts/{id}/comments`) to a top-level collection (`comments`).
    - Added `postId` to the `Comment` model to support this new schema.
    - Enables querying comments by user (`authorId`) independent of the post.
4.  **Profile Enhancements**:
    - Added "Yazılar" (Posts) and "Yorumlar" (Comments) tabs to both `ProfileView` and `PublicUserView`.
    - Created `CommentCard` widget for consistent comment display in lists.
    - Added navigation from a user's comment list back to the original post.

### Architectural Decisions
- **Top-Level Comments**: We moved to a root `comments` collection to simplify "Get all comments by user" queries, which are expensive/difficult with subcollections (collection group queries require complex indexing).
- **Public Shared Components**: Helper widgets for profile views were moved to `profile_view_helpers.dart` to be shared between the private `ProfileView` and public `PublicUserView`, reducing code duplication.

### Pending Actions / Technical Debt
- **Firestore Index**: The new "User Comments" feature requires a composite index on the `comments` collection: `authorId` (Ascending) + `date` (Descending). This must be created via the Firebase Console (clicking the link in the debug logs).
- **Legacy Data**: Old comments stored in subcollections are not migrated. They will not appear in the new lists. A migration script would be needed if retaining old comments is critical.
- **Flutter Web Issue**: A known assertion failure in `flutter run -d chrome` persists with the default CanvasKit renderer. Using `--web-renderer html` is the current workaround.

### Next Steps 
- Delete the old top-level `posts/{id}/comments` subcollections if we want to clean up the database (as requested by user, to be done later).

### Entry 12 [2026-01-10 03:46:58]
**Change Abstract:** Git Integration and Profile Comments Refactor.

**Details:**
1. Initialized Git repository and pushed to remote.
2. Updated README.md with comprehensive project documentation.
3. Refactored Comments to use top-level collection for better querying.
4. Implemented "My Comments" tab in Profile with Delete functionality.
5. Added Admin capabilities to delete any comment.
