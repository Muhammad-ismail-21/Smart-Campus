# Nexus — Campus Companion App

Nexus is a Flutter mobile application built for **KLE Technological University**.  
It provides campus navigation (tour), user authentication (college-only email), and a simple profile system backed by Firebase.

---

## 🧭 Overview

**Primary goals**
- Provide an interactive campus tour (Indoor / Outdoor modes).
- Restrict account creation to `@kletech.ac.in` emails.
- Allow guest usage (anonymous sign-in).
- Store and show user profiles using Cloud Firestore.
- Simple, modern Material 3 UI with offline-friendly Firestore streams.

**Key features**
- Email / Password authentication (Firebase Auth) with college-domain enforcement.
- Anonymous (guest) sign-in option.
- User profile persisted to Firestore and editable from the app.
- Tour screens with POIs and images (local assets or Firebase Storage).
- Clean architecture: screens, widgets, services.

---

## 🏗 Tech stack

- Flutter (Dart) — UI
- Firebase (Authentication, Firestore, Storage)
- FlutterFire (firebase_core, firebase_auth, cloud_firestore, firebase_storage)
- Material 3 design principles

---

## 📁 Project structure (important files)

