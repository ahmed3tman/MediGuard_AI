// Test data for Firebase to test ECG functionality
// Run this in Firebase console or use this structure

const testDeviceData = {
  device_readings: {
    DEVICE001: {
      current: {
        temperature: 36.8,
        ecg: 75,
        respiratoryRate: 16,
        spo2: 98,
        bloodPressure: {
          systolic: 120,
          diastolic: 80,
        },
        timestamp: Date.now(),
        deviceStatus: "connected",
      },
    },
    DEVICE002: {
      current: {
        temperature: 37.2,
        ecg: 88,
        respiratoryRate: 18,
        spo2: 96,
        bloodPressure: {
          systolic: 130,
          diastolic: 85,
        },
        timestamp: Date.now(),
        deviceStatus: "connected",
      },
    },
  },
  users: {
    // Replace with your actual user ID
    YOUR_USER_ID_HERE: {
      devices: {
        DEVICE001: {
          deviceId: "DEVICE001",
          name: "Patient Ahmed Monitor",
          readings: {
            temperature: 36.8,
            ecg: 75,
            respiratoryRate: 16,
            spo2: 98,
            bloodPressure: {
              systolic: 120,
              diastolic: 80,
            },
          },
          lastUpdated: Date.now(),
        },
        DEVICE002: {
          deviceId: "DEVICE002",
          name: "Patient Sara Monitor",
          readings: {
            temperature: 37.2,
            ecg: 88,
            respiratoryRate: 18,
            spo2: 96,
            bloodPressure: {
              systolic: 130,
              diastolic: 85,
            },
          },
          lastUpdated: Date.now(),
        },
      },
    },
  },
};

console.log("Use this data structure in Firebase Console:");
console.log(JSON.stringify(testDeviceData, null, 2));

// To test ECG updates, use this function periodically:
function updateEcgData() {
  const devices = ["DEVICE001", "DEVICE002"];

  devices.forEach((deviceId) => {
    const heartRate = 70 + Math.random() * 30; // Random heart rate 70-100
    const temperature = 36.5 + Math.random() * 1.5; // Random temp 36.5-38.0
    const spo2 = 95 + Math.random() * 5; // Random SpO2 95-100

    const updateData = {
      [`device_readings/${deviceId}/current`]: {
        temperature: parseFloat(temperature.toFixed(1)),
        ecg: parseInt(heartRate),
        respiratoryRate: parseInt(12 + Math.random() * 8), // Random respiratory rate 12-20
        spo2: parseInt(spo2),
        bloodPressure: {
          systolic: 110 + Math.random() * 20,
          diastolic: 70 + Math.random() * 15,
        },
        timestamp: Date.now(),
        deviceStatus: "connected",
      },
    };

    console.log(`Update for ${deviceId}:`, updateData);
  });
}

// Call updateEcgData() every 5 seconds to simulate real-time data
console.log("Run updateEcgData() periodically to simulate real-time data");
