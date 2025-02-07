# Reflect - README

Welcome to the Reflect. This README provides an overview of the app, its features, and the technologies used to build it. The app is designed to help users organize their thoughts, memories, and ideas through a structured journaling experience.

**Reflect Backend** - https://github.com/FrostyCake47/reflect-backend

---

## Table of Contents
1. [About the App](#about-the-app)
2. [Features](#features)
3. [Core Concepts](#core-concepts)
4. [Authentication](#authentication)
5. [End-to-End Encryption (E2EE)](#end-to-end-encryption-e2ee)
6. [Cache Management](#cache-management)
7. [Save Modes](#save-modes)
8. [Achievements](#achievements)
9. [Tags and Accessibility Features](#tags-and-accessibility-features)
10. [Technologies Used](#technologies-used)
11. [Setup and Installation](#setup-and-installation)
12. [Contributing](#contributing)

---

## About the App
Reflect is a versatile platform for users to write, organize, and manage their entries. It introduces a unique chapter-based structure for categorization and supports offline and cloud-synced journaling, along with encryption for enhanced privacy. With robust features and a user-friendly design, the app is perfect for both personal and professional use.

---

## Features
- **Chapter and Entry System:** Organize journal entries into chapters for better categorization and readability.
- **Authentication:** Secure login with Firebase Google Authentication and email-password sign-in.
- **End-to-End Encryption:** Protect user data with AES encryption, ensuring that only the user can access their private entries.
- **Robust Cache Management:** Efficient caching system for seamless offline access, tailored to individual users and chapters.
- **Multiple Save Modes:** Flexible save options, including local-only, cloud-synced, and encrypted cloud-synced modes.
- **Achievements:** Unlock milestones for writing streaks, chapter organization, and word counts.
- **Tags and Accessibility Features:** Add tags to entries and utilize filtering, sorting, and searching for enhanced navigation.

---

## Core Concepts
### Chapters and Entries
- **Chapters:** Act as folders or categories to organize journal entries.
- **Entries:** The core content of the app, allowing text input with optional features like tags and images.
- **Hierarchical Structure:** Each user can have multiple chapters, and each chapter can contain multiple entries.

---

## Authentication
- **Firebase Google Authentication:** Simplify the sign-in process with Google login.
- **Email-Password Authentication:** Provide traditional sign-in options for users who prefer email and password.
- **Secure Session Management:** Ensure that user sessions are managed securely to prevent unauthorized access.

---

## End-to-End Encryption (E2EE)
- **AES Encryption:** Utilize AES (Advanced Encryption Standard) to encrypt entries before they are synced to the cloud.
- **Key Derivation:** Derive encryption keys from user passwords, ensuring secure and unique encryption for each user.
- **Zero Knowledge:** Data encrypted with E2EE can only be decrypted on the user's device.

---

## Cache Management
- **User-Based Caching:** Cache is maintained separately for each user to ensure personalized access.
- **Chapter-Specific Caching:** Entries are cached on a per-chapter basis, optimizing performance and resource usage.
- **Offline Access:** Users can seamlessly access their entries offline, with automatic syncing when connectivity is restored.

---

## Save Modes
1. **Local Save:** Data is stored locally on the device, suitable for offline use.
2. **Cloud-Synced Save:** Data is synced to the cloud for easy access across devices.
3. **Encrypted Cloud-Synced Save:** Data is encrypted locally before being synced, ensuring privacy even on cloud storage.

---

## Achievements
Celebrate your journaling journey with achievements! Unlock badges for:
- Writing streaks (e.g., 7 days, 30 days).
- Total word count milestones (e.g., 10,000 words).
- Organizing chapters and entries.
- Adding tags and images to entries.
- Frequently favoriting entries.

---

## Tags and Accessibility Features
### Tags
- **Custom Tags:** Users can add tags to entries to enhance organization and categorization.
- **Tag Management:** Tags are reusable and help in grouping similar entries.
- **Insights with Tags:** Track and analyze tag usage for better journaling insights.

### Accessibility Features
- **Search:** Quickly locate entries by searching keywords or tags.
- **Filter:** Filter entries by date, tags, chapters, or other attributes.
- **Sort:** Sort entries alphabetically, by creation date, or by modification date.
- **Favorites:** Mark and access frequently used or important entries with ease.

---
<p align="center">
   <img src="/screenshots/1.jpg" width="256">
   <img src="/screenshots/2.jpg" width="256">
</p>
<p align="center">
   <img src="/screenshots/3.jpg" width="256">
   <img src="/screenshots/4.jpg" width="256">
   <img src="/screenshots/5.jpg" width="256">
</p>
<p align="center">
   <img src="/screenshots/6.jpg" width="256">
   <img src="/screenshots/7.jpg" width="256">
   <img src="/screenshots/8.jpg" width="256">
</p>


## Technologies Used
### Frontend
- **Flutter**: For building a cross-platform, responsive UI.
- **Dart**: The programming language powering Flutter.

### Backend
- **Firebase**: For authentication and cloud functions.
- **AWS S3**: For storing images and large files.
- **Node.js**: Backend API for handling requests and managing encrypted data.

### Storage and Encryption
- **Hive**: Local database for caching.
- **AES Encryption**: For securing sensitive data.

---

## Setup and Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/FrostyCake47/reflect.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Set up Firebase project and add the configuration files for Android and iOS.
4. Configure `.env` file with Firebase and AWS credentials.
5. Run the app:
   ```bash
   flutter run
   ```

