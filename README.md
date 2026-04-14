# Next Bus 🚍

[![Build Status](https://github.com/Sourish-Kanna/Next-Bus-Frontend/actions/workflows/release.yml/badge.svg)](https://github.com/Sourish-Kanna/Next-Bus-Frontend/actions)
[![Release](https://img.shields.io/github/v/release/Sourish-Kanna/Next-Bus-Frontend)](https://github.com/Sourish-Kanna/Next-Bus-Frontend/releases)
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/Sourish-Kanna/Next-Bus-Frontend/total)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/Platform-Android-grey)

> **A commuter-built, offline-first transit app for unreliable bus schedules.**

**Next Bus** is a Flutter-based mobile application that helps commuters view bus timings, report arrivals, and access schedule data even in low-network environments.
Originally built for personal use on **Thane routes 56 & 156**, the project has evolved into a scalable, crowdsourced platform.

**Problem solved:** Official bus schedules are unreliable and internet connectivity is inconsistent during daily commutes.

---

## 📱 Download

👉 **APK available via GitHub Releases**

[![Download Latest APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://github.com/Sourish-Kanna/Next-Bus-Frontend/releases/latest)

---

## 📖 The Story

> *3.5 years of real-world data. 1 year of engineering.*

This project started at a bus stop — not a hackathon.

Frustrated by unreliable official schedules while commuting between **Thane Station and Tikujiniwadi**, I manually tracked bus arrival patterns for **3.5 years**.
That dataset became the foundation for **Next Bus**: an app that combines **historical accuracy**, **offline-first design**, and **community reporting**.

---

## ✨ Features

### 👤 For Commuters

* **View Bus Timings** for supported routes
* **Offline Access** — works without internet
* **Crowdsourced Reporting** (report arrivals with minimal interaction)
* **Material Design 3 UI**
* **Dynamic Light / Dark Theme**

### 🛡️ For Admins

* Add / update / remove bus routes
* Add or modify bus timings
* View route data health

---

## 🧠 Engineering Highlights

### Offline-First Architecture

Designed for real Indian commute conditions.

* Local caching of schedules
* Offline report queueing
* Automatic sync when connectivity is restored
* Lightweight conflict prevention to reduce duplicate reports
* Basic anti-spam and deduplication checks to reduce noisy or repeated reports

### Clean State Management

* Built using **Provider**
* Clear separation of UI, state, and data layers
* Responsive UI even during background sync operations

---

## 🧑‍💼 Why This Project Matters

This is not a demo app.

It demonstrates:

* **Real-world problem solving** (network unreliability, data trust)
* **Offline-first system design**
* **State management at scale**
* **Production CI/CD** (signed APKs via GitHub Actions)
* **User empathy → engineering decisions**

All architectural choices were driven by **actual commuter behavior**, not assumptions.

### What I Learned Building This

* Designing for unreliable networks
* Balancing UX simplicity with data correctness
* Shipping and maintaining a real user-facing system

---

## 🏗 Tech Stack

### Frontend

* **Flutter (Dart)**
* **Provider** – state management
* **Material Design 3**
* **Dynamic Color**

### Backend

* **FastAPI (Python)**
* **Firebase Firestore**
* **Firebase Auth**

🔗 Backend Repository:
[https://github.com/Sourish-Kanna/Next-Bus-Backend](https://github.com/Sourish-Kanna/Next-Bus-Backend)

---

## 🌿 Branch Strategy

* **`stable`** → Production-ready releases
* **`main`** → Development & experimentation

Pull requests should generally target the `main` branch unless explicitly fixing a release issue.

> If you want stability, always refer to the `stable` branch.

---

## 📸 Screenshots

Screenshots are stored in: [/docs/screenshots](/docs/screenshots/)

| Home | Admin | Dark Mode |
| --- | --- | --- |
| ![Home](docs/screenshots/dark.jpg) | ![Home](docs/screenshots/dark.jpg) | ![Home](docs/screenshots/dark.jpg) |

> Screenshots will be updated as the UI stabilizes.

---

## ⚠️ Disclaimer

* This is **not an official transport authority app**
* Timings are based on **historical data and community reports**
* Data accuracy may vary depending on usage and participation

The goal is **practical usefulness**, not perfect prediction.

---

## 🚀 Getting Started (Developers)

### Prerequisites

* Flutter SDK (3.x)
* Firebase project (Firestore enabled)

### Setup

```bash
git clone https://github.com/Sourish-Kanna/Next-Bus-Frontend.git
cd Next-Bus-Frontend
flutter pub get
flutter run
```

Firebase configuration is handled via `flutterfire`.

---

## 🧭 Project Status & Roadmap

* 🚧 No active development currently
* 🔧 Improvements planned for upcoming releases
* 📍 See **Milestone 3** for future scope

---

## 🤝 Contributing

Contributions are welcome when development resumes.

1. Fork the repo
2. Create a feature branch
3. Open a Pull Request

---

## 📄 License

**MIT License**
*(subject to final confirmation)*

---

<div align="center">
  <small>Built with ❤️ by a commuter, for commuters.</small>
</div>
