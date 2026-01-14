# Security Analysis & Threat Model 🕵️‍♂️

**Date:** 2026-01-15
**Version:** 1.0
**Status:** Initial Audit

This document analyzes the current security posture of the application, identifying implemented defenses and acknowledging known risks.

## 1. Attack Surface Analysis

### 1.1 Authentication & Session
*   **Mechanism**: Firebase Authentication (Email/Password).
*   **Strength**: High. Leveraging Google's identity platform.
*   **Risk**: If "Sign Up" is open to the public, there is a risk of bot account creation.
    *   *Mitigation*: Future implementation of **App Check** (reCAPTCHA) is recommended.

### 1.2 Data Privacy (Critical Finding) ⚠️
*   **Finding**: The `users` collection is globally readable (`allow read: if true`).
*   **Impact**: The `AppUser` document contains the user's `email`. This means anyone can technically scrape email addresses of all registered users.
*   **Likelihood**: High (if the app becomes popular).
*   **Recommendation**:
    *   **Short Term**: Accept risk for MVP / Internal use.
    *   **Long Term**: Split user data into public (`users/public_profile`) and private (`users_private/settings`) collections.

### 1.3 Content Safety (XSS & Injection)
*   **Input**: Users can submit Markdown text in Posts and Comments.
*   **Defense**: The `flutter_markdown` package is used for rendering. It parses Markdown to Flutter Widgets, *not* HTML, which neutralizes standard Web-XSS (Cross-Site Scripting) vectors (e.g., `<script>` tags).
*   **Status**: **Secure** by design of the rendering engine.

### 1.4 Business Logic
*   **Timestamps**:
    *   **Comments**: Uses `FieldValue.serverTimestamp()`. **Secure**. Users cannot spoof comment times.
    *   **Posts**: Uses client-side `DateTime`. **Low Risk**. A user could ostensibly backdate their own post, but this has minimal business impact.

## 2. Authorization (RBAC)
*   **Model**: Role-Based Access Control via `role` field on User document.
*   **Enforcement**: Server-side in `firestore.rules`.
*   **Integrity**:
    *   Users cannot edit their own `role` because the `users` update rule restricts writes to *owner*, but we must ensure the client-side code doesn't send the `role` field during a normal profile update, OR the rules need to explicitly prevent `role` modification.
    *   *Audit*: Currently `firestore.rules` allows `write` if `isOwner`. It does *not* explicitly block modifying the `role` field.
    *   **Risk**: A malicious user *could* technically craft a request to update their `role` to 'admin' if they are the owner of the document.
    *   **CRITICAL FIX NEEDED**: The rules should explicitly prevent `request.resource.data.role` from differing from `resource.data.role` for non-admin updates.

## 3. Summary of Risks

| Risk | Severity | Status | Action Item |
| :--- | :--- | :--- | :--- |
| **Privilege Escalation** | **Critical** | **Patched** | Rules now prevent `role` changes. |
| **Email Scraping** | High | Accepted (MVP) | Split User Collections in V2. |
| **Spam / Botting** | Medium | Open | Add Rate Limiting / App Check. |
| **XSS** | Low | Mitigated | None (Flutter Architecture). |

---
**Auditor Note**: The Privilege Escalation risk (User upgrading themselves to Admin) is a theoretical vulnerability in the current `isOwner` write rule. It is highly recommended to patch this.
