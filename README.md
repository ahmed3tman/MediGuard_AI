<!-- # Spider Doctor

Spider Doctor is a comprehensive Flutter-based mobile application designed for remote patient monitoring. It allows doctors to track vital signs, manage patient data, and receive critical alerts, all in real-time. The app also features a smart medical assistant to provide quick insights and answer medical queries.

## Features

- **User Authentication**: Secure login and registration for doctors.
- **Device Management**: Add, view, and manage patient monitoring devices.
- **Patient Dashboard**: A centralized view of all patients and their current status.
- **Patient Details**: In-depth view of each patient, including:
  - Real-time vital signs (e.g., ECG, heart rate, temperature).
  - Historical data visualization with charts.
- **Critical Cases**: A dedicated section to highlight patients requiring immediate attention.
- **Medical Assistant**: An AI-powered assistant that can:
  - Analyze vital signs and provide summaries.
  - Answer medical questions based on a knowledge base.
  - Offer nutritional guidance.
- **Profile Management**: Update doctor's information.
- **Settings**: Customize application settings, including language (English/Arabic).

## Project Structure

The project follows a clean, feature-driven architecture to ensure scalability and maintainability. The codebase is organized as follows:

- `lib/`: Main source code directory.
  - `core/`: Contains shared code used across multiple features.
    - `localization/`: Handles internationalization and localization.
    - `shared/`: Includes shared widgets, themes, colors, and utility functions.
  - `features/`: Each feature of the application is encapsulated in its own directory.
    - `auth/`: User authentication.
    - `devices/`: Device management.
    - `patient_detail/`: Patient data and vital signs.
    - `medical_assistant/`: AI assistant.
    - ... and so on.
  - `navigation/`: Manages routing and navigation.
  - `main.dart`: The entry point of the application.

Each feature directory is typically structured into:

- `cubit/`: State management using Flutter BLoC (Cubit).
- `model/`: Data models specific to the feature.
- `services/` or `repository/`: Data handling and business logic.
- `view/`: UI components, divided into `screens` and `widgets`.

## Packages Used

- **State Management**: `flutter_bloc`, `equatable`
- **Backend (BaaS)**: `firebase_core`, `firebase_auth`, `firebase_database`
- **UI**: `flutter_floating_bottom_bar`, `fl_chart`, `flutter_html`
- **Localization**: `flutter_localizations`, `intl`
- **Local Storage**: `shared_preferences`
- **Networking**: `http`
- **Environment Variables**: `flutter_dotenv`
- **Utilities**: `url_launcher`

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/spider_doctor.git
    cd spider_doctor
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Set up Firebase:**
    - Create a new Firebase project.
    - Add an Android and/or iOS app to your Firebase project.
    - Download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the appropriate directories (`android/app/` and `ios/Runner/`).
4.  **Create a `.env` file:**
    - Create a `.env` file in the root of the project.
    - Add any necessary environment variables (e.g., API keys for the medical assistant).
5.  **Run the app:**
    ```bash
    flutter run
    ``` -->
