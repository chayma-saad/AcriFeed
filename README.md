# 🦗 AcriFeed — Smart Locust Farm Monitoring

[![Live Demo](https://img.shields.io/badge/Live%20Demo-chayma--saad.github.io-16a34a?style=for-the-badge&logo=githubpages&logoColor=white)](https://chayma-saad.github.io/AcriFeed/)
[![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

AcriFeed is a cross-platform app for **monitoring locust farms**. It combines live sensor readings (temperature, humidity, feeding), camera feeds, a machine-learning model that predicts the colony's condition (*normal*, *hungry* or *stressed*), smart alerts and an AI assistant — in **English, French and Arabic**.

> 🌐 **Try it live:** https://chayma-saad.github.io/AcriFeed/ — log in with **admin / admin123**.
> The web demo runs in *demo mode*: no server is needed. Features that rely on the backend (database history, ML predictions, chatbot) work in the full local setup below.

---

## ✨ Features

- 📊 **Real-time dashboard** — live sensor panel, quick stats and feeding control
- 🤖 **ML condition prediction** — Random Forest model classifies the colony as normal / hungry / stressed
- 🔔 **Smart alerts & recommended actions** when readings go out of range
- 📈 **Analytics** — interactive charts built with `fl_chart`
- 🎥 **Camera history** with video playback
- 💬 **AI assistant** (chatbot) for farm-management questions
- 🌍 **Multilingual** — English, French, Arabic (RTL)
- 🔐 **Authentication** with JWT (backend mode)
- 🧪 **Sensor simulator** for testing without hardware

## 🏗️ Architecture

```
┌──────────────────────┐      REST/JWT      ┌──────────────────────┐      ┌─────────┐
│   Flutter app (lib/) │ ─────────────────▶ │  .NET 8 Web API      │ ───▶ │  MySQL  │
│  Android · Web · iOS │                    │  app/backend/        │      └─────────┘
│  Windows · macOS     │ ───────┐           └──────────────────────┘
└──────────────────────┘        │  REST
                                ▼
                      ┌──────────────────────┐
                      │  Flask ML service     │  ← models/locust_condition_model.pkl
                      │  backend_python/app.py│
                      └──────────────────────┘
```

| Part | Tech | Folder |
|---|---|---|
| Mobile / web app | Flutter, Provider, fl_chart, sqflite, video_player | `lib/` |
| REST API | .NET 8 Web API, JWT auth | `app/backend/` |
| Database | MySQL schema & setup scripts | `app/database/` |
| ML service | Flask, scikit-learn, pandas | `backend_python/` |
| Model training | Random Forest on FAO Locust Hub data | `train_locust_model.py` |

## 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![.NET](https://img.shields.io/badge/.NET%208-512BD4?style=flat&logo=dotnet&logoColor=white)
![C#](https://img.shields.io/badge/C%23-239120?style=flat&logo=csharp&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=flat&logo=flask&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-F7931E?style=flat&logo=scikitlearn&logoColor=white)

## 📂 Data

The ML model is trained on the **FAO Locust Hub** open datasets (`data/Swarms.csv`, `data/Locust_watch.csv`): historical desert-locust swarm and hopper reports with control-operation details. Swarm reports are labelled *stressed*, hopper reports *hungry*, the rest *normal*.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.29
- .NET 8 SDK and MySQL (e.g. XAMPP) — for the full backend
- Python 3.10+ — for the ML service

### 1. Run the app

```bash
git clone https://github.com/chayma-saad/AcriFeed.git
cd AcriFeed
flutter pub get
flutter run                          # full mode (needs the backend)
flutter run --dart-define=DEMO_MODE=true   # demo mode, no backend needed
```

### 2. Start the backend (full mode)

```bash
# Database: create the schema (see app/SETUP_DATABASE.md)
mysql -u root < app/database/schema.sql

# .NET API (http://localhost:5000)
cd app/backend/LocustMonitoring.API
dotnet run
```

Configure the connection string and JWT key in `app/backend/LocustMonitoring.API/appsettings.json`.

### 3. Start the ML service

```bash
pip install flask flask-cors pandas numpy scikit-learn joblib
python backend_python/app.py
```

Endpoints: `GET /health`, `POST /predict/condition`, `/predict/humidity`, `/predict/feeding`, `/predict/anomaly`.

More details: [`app/QUICK_START.md`](app/QUICK_START.md) · [`app/RUN_BACKEND.md`](app/RUN_BACKEND.md) · [`app/PROJECT_STRUCTURE.md`](app/PROJECT_STRUCTURE.md)

## 📦 Deployment

The web demo is built and published automatically to GitHub Pages by [`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml) on every push to `main`.

---
👩‍💻 Made by [Chaima Saad](https://github.com/chayma-saad)
