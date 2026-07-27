# Next Bus: GitHub Release & Incremental Versioning Guide

This document outlines the incremental release strategy for the Next Bus application and provides a standard template for creating professional GitHub Releases.

## 1. Incremental Release Strategy

To deliver value to users faster and isolate potential bugs, we use an incremental release strategy. 

* **UI/UX Enhancements (Minor Release):** Features like timelines, snackbars, and animations are released under a minor version bump (e.g., `v2.2.0`) because they do not fundamentally break the core app architecture.
* **Architecture Rewrites (Major Release):** Massive foundational changes, such as replacing the legacy navigation with `go_router` (Issue #28), are reserved for a major version bump (e.g., `v3.0.0`).

### Benefits of this approach:
1. **Faster Delivery:** Users receive the new UI immediately, rather than waiting for the entire v3.0 milestone to be completed.
2. **Safer Debugging:** By separating UI changes from architectural changes, any new bugs are much easier to trace to their root cause.

---

## 2. Creating a GitHub Release

When a milestone or major feature set is complete, follow these steps to publish a release on GitHub:

1. Navigate to your repository and click **Releases** > **Draft a new release**.
2. **Choose a tag:** Type exactly the version from your `pubspec.yaml` (e.g., `v2.2.0`). Use the standard `v` prefix.
3. **Release Title:** Keep it clear and indicative of the update's theme (e.g., `v2.2.0: UI & Visual Enhancements`).
4. **Description:** Provide a user-friendly summary of the new features and a bulleted changelog.
5. **Assets:** Attach the compiled `.apk` (Android) or `.ipa` (iOS) files.

---

## 3. Standard Release Template (Example for v2.2.0)

Use the following markdown template for the upcoming UI release.

## 🚀 What's New in v2.2.0

This update focuses heavily on making the Next Bus app feel more premium, native, and visually intuitive. 

**Highlights include:**
* **Visual Route Timelines:** Bus routes are no longer static lists. We've introduced a beautiful vertical timeline to help you visualize the bus's journey and your current position.
* **Premium Alerts:** All system notifications (like network drops or successful saves) have been upgraded to modern, highly visible snackbars.
* **Engaging Loading States:** Replaced standard system spinners with custom animations during network calls and authentication.

## 📝 Changelog
* **Feature:** Implemented `timelines_plus` for route visualization (Closes #39)
* **Feature:** Upgraded `CustomSnackBar` wrapper with `awesome_snackbar_content` (Closes #41)
* **Enhancement:** Added `flutter_spinkit` custom loading states for API/Auth delays (Closes #40)

*Note: Page transition animations are currently on hold pending the upcoming v3.0 `go_router` migration.*

*(Note: Adding `(Closes #IssueNumber)` in the release notes allows GitHub to automatically close those issues on your project board once the release is published.)*