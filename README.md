# Next Bus 🚍

**Next Bus** is a dynamic Flutter application designed to provide real-time bus timings and manage routes effectively. It integrates Firebase for database operations and uses Provider for state management. This app offers a clean, responsive UI and ensures ease of use with features like dynamic theming and admin operations.

[![Netlify Status](https://api.netlify.com/api/v1/badges/736ced60-11c2-47e4-a24d-5d7e7c26c7c0/deploy-status)](https://app.netlify.com/sites/next-bus-app/deploys)

## Features ✨

### User Features

- View upcoming and past bus timings.
- Dynamic UI with support for light and dark themes (Material Design 3).
- Portrait mode for seamless usability.

### Admin Features

- **Add Bus Routes**: Add new bus routes with associated details.
- **Remove Bus Routes**: Delete existing bus routes.
- **Add Timings**: Add new timings for specific bus routes.
- **Retrieve Timings**: View all timings for specific routes.

### Firebase Integration

- **Firestore Database**: Store and manage bus routes, timings, and related data.
- CRUD operations (Create, Read, Update, Delete) implemented for seamless data handling.

---

## Technologies Used 🛠️

### Frameworks and Libraries

- **Flutter**: For building a cross-platform application.
- **Firebase**: Backend as a Service (BaaS) for authentication and Firestore database.
- **Provider**: For efficient state management.
- **Dynamic Color**: To enable dynamic light and dark themes.

### UI Design

- **Material Design 3**: Modern and responsive UI.
- **Dialogs and Animations**: Improved user interaction and feedback.

---

## Installation and Setup 🚀

### Prerequisites

- Flutter SDK (latest stable version).
- Dart SDK.
- Firebase Project (set up in the [Firebase Console](https://console.firebase.google.com/)).

### Steps to Set Up

1. Clone the repository:

   ```bash
   git clone https://github.com/Sourish-Kanna/Next-Bus.git
   cd next-bus
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
    - Add the `google-services.json` file to the `android/app` directory.

4. Run the app:

   ```bash
   flutter run
   ```

---

## Project Structure 📁

``` text
next-bus/
├── lib/
│   ├── main.dart            # App entry point
│   ├── build_widgets.dart   # Custom UI components
│   ├── bus_timing_provider.dart # State management
│   ├── firebase_operations.dart # Firebase service operations
├── android/                 # Android-specific files
├── pubspec.yaml             # Dependencies and assets
└── README.md                # Project documentation
```

---

## Future Enhancements 🛠️

- Add notifications for upcoming bus timings.
- Implement user authentication (Admin/User roles).
- Support multiple languages for wider accessibility.
- Expand to support additional public transport modes.

---

## Contributing 🤝

1. Fork the repository.
2. Create your feature branch: `git checkout -b feature/YourFeature`.
3. Commit your changes: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin feature/YourFeature`.
5. Open a pull request.

---

## License 📄

This project is licensed under the [MIT License](LICENSE).

---

## Screenshots 📸
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
<table>
    <tr>
        <td><img src="https://github.com/user-attachments/assets/2842a9a3-e108-4be3-ab67-0c8eea904bdd" alt="Screenshot_20250123_195131" width="100%"></td>
        <td><img src="https://github.com/user-attachments/assets/f61997bc-7f84-48c5-8b13-feb433c92726" alt="Screenshot_20250123_194820" width="100%"></td>
    </tr>
    <tr>
        <td><img src="https://github.com/user-attachments/assets/ad314106-c706-4d41-8152-e50b9affd147" alt="Screenshot_20250123_194519" width="100%"></td>
        <td><img src="https://github.com/user-attachments/assets/fc3569f8-002b-4549-8601-8b206f7e08ad" alt="Screenshot_20250123_194505" width="100%"></td>
    </tr>
</table>
<https://github.com/user-attachments/assets/243b39d5-74e1-44eb-80d4-d7fdb15c8aca>
<https://github.com/user-attachments/assets/8f902910-e598-4c2c-a814-e5e06ac38dd0>
</div>

---

## Acknowledgements 🙏

- Firebase Documentation: <https://firebase.google.com/docs>
- Flutter Documentation: <https://flutter.dev/docs>
