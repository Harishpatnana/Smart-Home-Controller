# 🏠 Smart Home Controller App (Flutter)

A simple Flutter app to **control smart home devices** (door lock, fan, light) and **monitor temperature and humidity** in real time from a NodeMCU IoT system.

---

## 🔍 Key Features

* 🌡️ Real-time temperature and humidity display
* 🔒 Door lock toggle (lock/unlock)
* 🌬️ Fan toggle (on/off)
* 💡 Light toggle (on/off)
* 🔄 Manual refresh button to update sensor and device status
* 📱 Clean and responsive UI built with Flutter Material Design

---

## 🧠 Learning Goals

This project helps understand:

* Making HTTP requests in Flutter using the `http` package
* Parsing JSON responses from IoT device APIs
* Managing UI state with `setState`
* Building interactive widgets like `Switch`, `ListTile`, and `Card`
* Communicating with embedded devices (NodeMCU) over a local network

---

## 🔗 API Endpoints Used

* `GET /status` — Returns JSON with temperature, humidity, and device states
* `GET /door?state=0|1` — Lock/unlock door
* `GET /fan?state=0|1` — Turn fan off/on
* `GET /light?state=0|1` — Turn light off/on

*(These endpoints must be implemented on your NodeMCU firmware)*

---

## ⚙️ Installation & Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/smart-home-controller.git
   cd smart-home-controller
   ```

2. Update the NodeMCU IP address in `main.dart`:

   ```dart
   final String baseUrl = "http://YOUR_NODEMCU_IP";
   ```

3. Install dependencies and run:

   ```bash
   flutter pub get
   flutter run
   ```

4. Ensure your mobile device is on the same network as your NodeMCU to communicate properly.

---

## 📂 Project Structure

```
lib/
 └── main.dart       # Main Flutter app source code

assets/
 └── images/         # Optional: Screenshots or icons

pubspec.yaml         # Flutter dependencies and configuration
```

---

## 📦 Dependencies

* flutter
* http (^0.13.0)

Defined in `pubspec.yaml`.

---





## 📄 License

MIT License

---


