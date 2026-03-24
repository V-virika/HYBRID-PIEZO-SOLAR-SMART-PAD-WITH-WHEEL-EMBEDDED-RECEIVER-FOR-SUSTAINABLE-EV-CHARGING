# ⚡ Smart Wireless EV Charging Road using Renewable Energy, IoT & ML

## 📌 Project Overview

This project presents a smart wireless electric vehicle (EV) charging system powered by renewable energy sources and enhanced with IoT-based monitoring and machine learning analytics. The system integrates solar energy and piezoelectric energy harvesting with dynamic wireless power transfer (DWPT) to enable contactless EV charging.

The prototype demonstrates how an EV can be charged while in motion without physical connectors, improving convenience, safety, and infrastructure efficiency.

---

## 🚀 Key Features

* 🔋 Renewable energy-based charging (Solar + Piezoelectric)
* ⚡ Wireless power transfer using Qi technology
* 🧠 ESP32-based smart control system
* 🚗 Vehicle detection using IR sensors
* 📊 Real-time monitoring (Current, Power, Energy)
* ☁️ Cloud integration using Firebase
* 📈 Live dashboard (Web + Mobile)
* 🤖 Machine Learning:

  * Charging time prediction
  * Anomaly detection
  * Efficiency optimization
* 📁 Automatic dataset generation (Google Sheets + CSV export)

---

## 🧱 Hardware Components

* ESP32 DevKit V1
* Piezoelectric discs (×4)
* Solar panel (6V)
* Bridge rectifier (MB6S / DB107)
* Capacitor (470µF / 25V)
* TP4056 Li-ion charging module
* 18650 batteries (×2)
* LM2596 Buck converter
* MT3608 Boost converters (×2)
* Qi Wireless Transmitter module
* ACS712 Current sensor
* IR Sensors (×2)
* Relay module (5V)
* LEDs (Red & Green) + resistors
* Buzzer

---

## 🔌 Hardware Architecture

1. Piezoelectric + Solar energy harvesting
2. Power conditioning (Rectifier, Capacitor, Buck/Boost converters)
3. Battery storage via TP4056
4. ESP32 control system
5. IR-based vehicle detection
6. Relay-controlled wireless charging (Qi TX)
7. Current monitoring using ACS712
8. Safety alerts via LED & buzzer

---

## 🧠 Software Architecture

### Embedded System (ESP32)

* Sensor reading (IR, ACS712)
* Charging control via relay
* Real-time current & power calculation
* Fault detection (cutoff failure)

### IoT Integration

* ESP32 sends data via Wi-Fi
* Firebase Realtime Database stores live data
* Data updated every few seconds

### Dashboard

* Web dashboard (HTML + JS + Chart.js)
* Mobile app (Flutter)
* Displays:

  * Current, Power, Energy
  * Charging status
  * Fault alerts
  * Live graphs

---

## ☁️ Data Flow Architecture

Sensors → ESP32 → Wi-Fi → Firebase → Dashboard → Dataset → ML Models

---

## 📊 Dataset Generation

* Real-time data is pushed to Firebase
* Each entry contains:

  * Timestamp
  * Current (A)
  * Power (W)
  * Energy (Wh)
  * Charging status
  * Fault status
* Data is automatically logged into Google Sheets
* Exportable to CSV/Excel for analysis

---

## 🤖 Machine Learning Modules

### 1. Charging Time Prediction

* Model: Linear Regression
* Input: Current, Power, Energy
* Output: Remaining charging time

### 2. Anomaly Detection

* Model: Isolation Forest
* Detects:

  * Abnormal current
  * Power spikes
  * Fault conditions

### 3. Efficiency Optimization

* Calculates energy efficiency
* Compares solar vs piezo contribution
* Identifies optimal charging conditions

---

## 📱 Dashboard Features

* Live charging status
* Power & energy graphs
* Fault alerts
* Multi-EV support (scalable design)
* Real-time updates

---

## 🧪 Testing Workflow

1. Power ON system
2. Detect vehicle using IR sensors
3. Activate relay → Start wireless charging
4. Measure current via ACS712
5. Stop charging after set duration
6. Detect fault if current persists
7. Trigger LED & buzzer alert

---

## 📈 Research & Applications

* Smart cities infrastructure
* Airport & industrial EV charging
* Dynamic wireless charging roads
* Energy-efficient transportation systems

---

## 🎯 Future Enhancements

* Battery percentage monitoring
* GPS-based vehicle tracking
* Advanced ML models (Deep Learning)
* Mobile notifications & alerts
* Energy source analytics (Solar vs Piezo split)

---

## 🛠️ Tech Stack

* Hardware: ESP32, Sensors, Power Electronics
* Backend: Firebase Realtime Database
* Frontend: HTML, JavaScript, Chart.js
* Mobile App: Flutter
* ML: Python (Pandas, Scikit-learn, Matplotlib)

---

## 📌 Conclusion

This project demonstrates a complete smart EV charging ecosystem combining renewable energy harvesting, wireless power transfer, IoT-based monitoring, and machine learning analytics. It provides a scalable and efficient solution for future EV infrastructure.

---

## 👩‍💻 Author

VIRIKA OLIVIA SOANS
R SINDHU
JANARDHAN K S 
HARSHITA JEETENDRA BHUTE

---

## ⭐ Acknowledgement

This project was developed as part of academic research in smart energy systems and IoT-enabled electric vehicle infrastructure.(MAJOR PROJECT)
