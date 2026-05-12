# Next Bus: Complete Release & Versioning Guide

This document serves as the comprehensive authority for managing versions and releases for the **Next Bus** application. It combines semantic versioning standards with an incremental release strategy designed for high-quality Flutter development.

---

## 1. Versioning Strategy & Guidelines

The project follows **Semantic Versioning (SemVer)** tailored specifically for Flutter applications and App Store distribution requirements.

### Single Source of Truth

The app's version is defined exclusively in the `pubspec.yaml` file:

```yaml
version: MAJOR.MINOR.PATCH-SUFFIX+BUILD
```

### Anatomy of a Flutter Version Number

#### A. The Version Name (`MAJOR.MINOR.PATCH`)

The public-facing version number visible to users in app stores.

* **MAJOR (`x.0.0`)**: Used for massive, breaking changes, complete UI overhauls, or fundamental architecture rewrites (e.g., migrating to `go_router`).
* **MINOR (`0.x.0`)**: Used when adding new, distinct features while the core app architecture remains stable (e.g., adding a new transit route).
* **PATCH (`0.0.x`)**: Used for bug fixes, hotfixes, or minor visual tweaks that do not add significant new functionality.

#### B. Pre-release Suffix (`-suffix`)

Used during the development cycle to indicate the build is not a final public release.

* `-dev`: For active development (e.g., `3.0.0-dev`).
* `-beta`: For builds ready for testing but not final (e.g., `3.0.0-beta.1`).
* *Note: Remove this suffix entirely for production releases*.

#### C. The Build Number (`+BUILD`)

A critical hidden number used internally by App Stores.

* **The Golden Rule**: You **MUST** increment this by `1` every time you upload a new binary to the Google Play Console or Apple App Store.
* App stores will reject any upload where the build number is not strictly greater than the previous upload.

---

## 2. Incremental Release Strategy

To deliver value to users faster and isolate potential bugs, Next Bus utilizes an incremental approach.

* **Minor Releases (e.g., `v2.2.0`)**: Focus on UI/UX enhancements like new timelines, snackbars, and loading animations that do not fundamentally change the core navigation architecture.

* **Major Releases (e.g., `v3.0.0`)**: Reserved for foundational changes, such as the migration to `go_router` or establishment of a new testing framework.

### Benefits of this approach

1. **Faster Delivery**: Users receive UI improvements immediately rather than waiting for architecture rewrites to finish.
2. **Safer Debugging**: Separating visual changes from structural changes makes tracing new bugs significantly easier.

---

## 3. Creating a GitHub Release

Follow these steps to publish a release once a milestone is complete:

1. **Navigate** to the repository and click **Releases** > **Draft a new release**.
2. **Tag Name**: Use the version from `pubspec.yaml` with a `v` prefix (e.g., `v2.2.0`).
3. **Title**: Provide a clear, theme-indicative title (e.g., `v2.2.0: UI & Visual Enhancements`).
4. **Description**: Use the standard template provided in the separate `RELEASE_TEMPLATE.md` file to provide a summary and changelog.
5. **Assets**: Attach the compiled `.apk` (Android) or `.ipa` (iOS) files.
