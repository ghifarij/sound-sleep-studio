# SoundSleep Studio  
*A heart-rate–adaptive lullaby generator for iPhone + Apple Watch*

Turns your live pulse into a slowly-sliding pad, helps you drift from daytime alertness to sleep in **≤ 15 min**, and logs nightly HR-drop analytics — all on-device, no cloud, no ads.

---

## ✨ Features

| ✔︎ MVP (v0.5) | ⏳ Planned |
|---------------|-----------|
| Live HR stream (5 s cadence) via **HealthKit Anchored Query** | Faster 1 s stream via watchOS workout |
| Adaptive tempo = *HR – 2 BPM* (clamped 40–100 BPM) | Core ML “relaxed?” fade logic |
| Soft pad + heartbeat graph in **AVAudioEngine** | Spatial-audio option |
| 10-min auto-fade **or** fade when HR-drop ≥ 6 BPM | Extra pad packs (IAP) |
| SwiftUI UI (Start ▶, waveform, summary) | Siri Shortcuts auto-bedtime |
| **SwiftData** session log + weekly chart | CloudKit sync |

---

## 🔧 Tech stack

* **SwiftUI / Swift Charts**         UI & visual analytics  
* **AVFoundation (AVAudioEngine)**  Real-time audio  
* **HealthKit**                      Heart-rate stream  
* **SwiftData (+CloudKit opt-in)**  Persistence  
* **App Intents**                   Shortcuts / Siri  
* **Fastlane + TestFlight**         CI & beta delivery  

---
