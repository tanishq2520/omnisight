<div align="center">

# 🦯 OmniSight
### *Fully Offline Spatial AI for the Visually Impaired*

![Platform](https://img.shields.io/badge/Platform-Android-brightgreen?style=for-the-badge&logo=android)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Python](https://img.shields.io/badge/Python-3.11-3776AB?style=for-the-badge&logo=python)
![AI](https://img.shields.io/badge/AI-Moondream2-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

> **"Your eyes, powered by AI — no internet required."**

Built for the **iQOO Hackathon · Open Innovation Track**

</div>

---

## 🌍 The Problem

Over **285 million people** worldwide live with visual impairment. Existing assistive tools are either:

- 💸 Prohibitively expensive
- 📡 Dependent on internet connectivity
- 🐢 Too slow for real-time spatial awareness
- 🗺️ Limited to navigation, ignoring immediate surroundings

**OmniSight solves all of this — completely offline, in real time.**

---

## 💡 What is OmniSight?

OmniSight is a **dual-architecture AI assistant** that turns any Android phone into a spatial awareness device for visually impaired users. Point the camera — and the app speaks the world back to you.

Every response answers three questions:

| Question | Example Response |
|----------|-----------------|
| 🏠 **Where am I?** | *"You appear to be indoors, in a corridor."* |
| 📏 **What's nearby?** | *"There is an object at arm's reach to your left."* |
| ⚠️ **Any danger?** | *"Warning — vehicle approaching from the right."* |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                    USER'S PHONE                      │
│                                                      │
│  📷 Camera → Frame Capture → Base64 Encode          │
│  🎤 Voice Input → Query Classifier                  │
│       ↓ Simple Query          ↓ Complex Query        │
│  🔊 Instant TTS Reply    WebSocket → Laptop         │
│  ⚡ < 100ms latency                                  │
└─────────────────────────────────────────────────────┘
                         ↕ Local WiFi / USB
┌─────────────────────────────────────────────────────┐
│                   LAPTOP BACKEND                     │
│                                                      │
│  🐍 FastAPI Server (WebSocket)                      │
│  👁️ Moondream2 Vision AI → Scene Analysis          │
│  📝 Tesseract 5.x OCR → Text Reading               │
│  🔁 Token Streaming → Phone TTS                     │
└─────────────────────────────────────────────────────┘
```

**Everything runs on your local network. Zero cloud. Zero data sent anywhere.**

---

## ✨ Key Features

### 🔴 Real-Time Scene Understanding
Point the camera, tap the screen. OmniSight instantly describes your environment — indoors or outdoors, what kind of space, what's around you.

### 📏 Proximity Detection
Distances described in natural human language. Not "2.3 metres" — but *"arm's reach"*, *"a few steps away"*, *"across the room"*.

### ⚠️ Threat Alerting
Vehicles, obstacles, steps, people too close — flagged immediately with urgent voice alerts. Silence means safety.

### 📖 Text Reading (OCR)
Hold the camera up to any sign, menu, label, or document. OmniSight reads it aloud using Tesseract OCR.

### 🎤 Voice Query Routing
Speak naturally. The app classifies your query and routes it — simple questions answered instantly on-device, complex vision tasks sent to the AI engine.

### 🔇 Smart Silence
The app never speaks unnecessarily. No constant noise. No false alarms. Speaks only when it matters.

### ⚡ Audio Fillers During Processing
While the AI thinks (8-10 seconds), the app keeps you informed: *"Scanning surroundings... Capturing details... Analyzing the environment..."* — so it never feels frozen.

---

## 🛠️ Tech Stack

### 📱 Phone (Flutter)
| Component | Technology |
|-----------|-----------|
| UI Framework | Flutter 3.x (Dart) |
| Camera | camera + CameraX |
| Text-to-Speech | flutter_tts |
| Speech-to-Text | speech_to_text |
| Network | web_socket_channel |
| Sensors | sensors_plus |
| Wake Lock | wakelock_plus |

### 💻 Laptop Backend (Python)
| Component | Technology |
|-----------|-----------|
| API Server | FastAPI + Uvicorn |
| Vision AI | Moondream2 (via Ollama) |
| OCR Engine | Tesseract 5.x |
| Image Processing | OpenCV + Pillow |
| Runtime | Python 3.11 |

---

## 📱 Device Requirements

| Item | Spec |
|------|------|
| Phone | Android 9+ with camera |
| Demo Device | iQOO 15 (Snapdragon 8 Elite, 16GB RAM) |
| Laptop | Any with 8GB+ RAM (NVIDIA GPU recommended) |
| Network | Local WiFi or USB tethering |
| Internet | ❌ Not required |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`E:\Flutter`)
- Python 3.10+
- Ollama with Moondream2 model
- Tesseract 5.x
- Android device with USB debugging enabled

### Phone Setup
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/omnisight.git

# Navigate to phone app
cd omnisight/phone_app

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Laptop Backend Setup
```bash
# Navigate to backend
cd omnisight/backend

# Install Python dependencies
pip install fastapi uvicorn opencv-python pillow pytesseract websockets

# Pull Moondream2 via Ollama
ollama pull moondream

# Start the server
uvicorn main:app --host 0.0.0.0 --port 8000
```

---

## 🎯 How It Works — User Flow

```
1. App launches → Phone says: "OmniSight Active"
2. User taps screen (or presses volume button)
3. Phone says: "Scanning surroundings..."
4. Camera captures frame → compressed → sent to laptop
5. Moondream2 analyzes: environment + proximity + threats
6. Response streams back to phone
7. Phone speaks the result clearly
8. Repeat
```

---

## 🏆 Hackathon Context

**Event:** iQOO Hackathon — Open Innovation Track
**Theme:** Assistive Technology / AI for Social Good
**Team:** Built in under 48 hours

### Why This Matters
Assistive technology for the visually impaired has been largely unchanged for decades. Screen readers exist. Navigation apps exist. But **real-time spatial awareness** — knowing what's *around* you right now, how close things are, whether you're safe — that doesn't exist in an affordable, offline form.

OmniSight is that missing piece.

---

## 🔮 Future Roadmap

- [ ] On-device YOLO for sub-100ms object detection
- [ ] Accelerometer-based motion gating (saves battery when stationary)
- [ ] Threat escalation — voice urgency increases as danger approaches
- [ ] Offline STT with Whisper
- [ ] React dashboard for caregivers
- [ ] Wearable integration (smart glasses)

---

## 👤 Author

**Tanishq**
Built with Flutter, FastAPI, Moondream2, and a lot of debugging at 2am.

---

<div align="center">

**If this project helped you or inspired you, leave a ⭐**

*OmniSight — See the world, even when you can't.*

</div>
