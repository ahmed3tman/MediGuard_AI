# Spider Doctor - Medical Device Monitoring System

A Flutter application for monitoring medical devices in real-time using Firebase Realtime Database. This app allows doctors to add, monitor, and manage patient monitoring devices with live vital sign tracking.

## Features

- **Real-time Device Monitoring**: Track vital signs (temperature, ECG, SpO2, blood pressure) in real-time
- **Secure Authentication**: Each doctor can only see their own devices
- **Device Management**: Add, view, and delete medical devices
- **Visual Health Indicators**: Color-coded cards showing normal/abnormal readings
- **Data Simulation**: Built-in demo mode for testing
- **Responsive UI**: Modern Material Design 3 interface

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **BLoC State Management**: Using flutter_bloc for predictable state management
- **Firebase Integration**: Real-time database for live data synchronization
- **Modular Structure**: Feature-based folder organization

## Getting Started

### Prerequisites

- Flutter SDK (3.8.0 or higher)
- Firebase project setup
- Android Studio/VS Code
- Android emulator or iOS simulator

### Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd spider_doctor
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project
   - Enable Authentication and Realtime Database
   - Update `firebase_options.dart` with your project configuration
   - Set up Firebase Security Rules

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Authentication

- Use email/password authentication
- Or login as guest for demo purposes

### Adding Devices

1. Click the "Add Device" button
2. Enter a unique Device ID and name
3. The device will appear in your dashboard

### Monitoring

- Real-time vital signs are displayed in colored cards
- Green indicators show normal readings
- Red indicators show abnormal readings
- Use the refresh button to simulate new data

## Health Indicators

### Normal Ranges

- **Temperature**: 36.1°C - 37.2°C
- **SpO2**: ≥ 95%
- **Blood Pressure**: 90-120/60-80 mmHg
- **ECG**: 60-100 BPM
