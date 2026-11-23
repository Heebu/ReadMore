# ReadMore - Full-Stack Dart News Platform

A complete full-stack news ecosystem built with Dart and Flutter.

## Architecture

- **`mobile/`**: Cross-platform mobile app built with **Flutter**.
- **`web/`**: Fast, lightweight website built with **FlartDart** (pure Dart HTML/CSS framework from pub.dev).
- **`backend/`**: High-performance backend API and background fetcher built with **Dart Frog**.
- **`packages/news_models/`**: Shared pure Dart models (`Article`, `NewsSource`, etc.) shared across mobile, web, and backend.

## Quick Start Guide

### 1. Backend (Dart Frog)
```bash
cd backend
dart_frog dev
# Runs by default on http://localhost:8080
```

### 2. Web App (FlartDart)
```bash
cd web
flartdart run --port 8081
# Runs on http://localhost:8081
```

### 3. Mobile App (Flutter)
```bash
cd mobile
flutter run
```

### 4. Shared Models
```bash
cd packages/news_models
dart test
```

