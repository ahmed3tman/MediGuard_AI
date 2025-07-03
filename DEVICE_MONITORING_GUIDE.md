# Spider Doctor - Medical Device Monitor

## Overview

Flutter medical app that monitors real-time vital signs from medical devices via Firebase Realtime Database. Shows "Not Connected" when devices aren't sending data.

## Features

✅ Real-time device monitoring  
✅ Firebase authentication  
✅ BLoC state management  
✅ Connection status indicators  
✅ "Not Connected" display for offline devices  
✅ English language interface

## Connection Status Logic

### Connected (Green)

- Device sending data within last 5 minutes
- All vital signs displayed with color-coded health status
- Shows "Last updated: X minutes ago"

### Connection Issues (Orange)

- Data is 5-10 minutes old
- Shows "Connection unstable - Data may be delayed"

### Not Connected (Red)

- No data for 10+ minutes or never received
- All readings show "Not Connected"
- Shows "Device not connected - Check device power and connection"

## Firebase Data Structure

### Device Readings (From External Devices)

```
/device_readings/{deviceId}/current
{
  "temperature": 36.8,
  "ecg": 75,
  "spo2": 98,
  "bloodPressure": {
    "systolic": 120,
    "diastolic": 80
  },
  "timestamp": 1641072000000
}
```

### User Devices (App Data)

```
/users/{userId}/devices/{deviceId}
{
  "deviceId": "DEVICE001",
  "name": "Patient Monitor",
  "readings": { ... },
  "lastUpdated": 1641072000000
}
```

## Testing the App

### 1. Add Demo Device

- Tap "Add Demo Device" button
- Device will show with simulated readings

### 2. Simulate Real Data

- Tap refresh icon on device card
- New readings will be generated

### 3. Test Connection Status

- Tap WiFi off icon to simulate disconnect
- Device will show "Not Connected" after timeout period

### 4. Test Real Firebase Data

- Send data to Firebase path: `/device_readings/{deviceId}/current`
- App will automatically update and display real readings

## Real Device Integration

To connect real medical devices:

1. **Device sends data to Firebase:**

   ```javascript
   firebase
     .database()
     .ref("device_readings/DEVICE001/current")
     .set({
       temperature: 36.8,
       ecg: 75,
       spo2: 98,
       bloodPressure: { systolic: 120, diastolic: 80 },
       timestamp: Date.now(),
     });
   ```

2. **App automatically receives and displays data**

3. **If device stops sending data, app shows "Not Connected"**

## Health Status Color Coding

### Temperature

- 🟢 Normal: 36.1°C - 37.2°C
- 🔴 Abnormal: Outside normal range

### Heart Rate (ECG)

- 🟢 Normal: 60-100 BPM
- 🔴 Abnormal: Outside normal range

### Blood Oxygen (SpO2)

- 🟢 Normal: ≥95%
- 🔴 Abnormal: <95%

### Blood Pressure

- 🟢 Normal: 90-120/60-80 mmHg
- 🔴 Abnormal: Outside normal range

## Error Handling

- Authentication errors handled gracefully
- Firebase connection issues managed
- Device timeout detection
- User-friendly error messages in English

## Development Commands

```bash
# Run the app
flutter run

# Hot reload changes
r

# Hot restart
R

# Build for release
flutter build ios
flutter build android
```

## Firebase Setup Required

1. Create Firebase project
2. Enable Realtime Database
3. Configure authentication
4. Add iOS/Android apps
5. Download config files (GoogleService-Info.plist, google-services.json)

The app is now ready for production use with real medical devices!
