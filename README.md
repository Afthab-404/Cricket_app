# CricketLive - Flutter App

A beautiful, responsive Flutter app for tracking live cricket scores, upcoming matches, batting/bowling stats, and live ball-by-ball events.

---

## Features

- **Live Scores** — Real-time match scores with auto-refresh every 30s
- **Upcoming Matches** — All scheduled fixtures with date/time
- **Scorecard** — Full batting & bowling details per innings
- **Who's Batting/Bowling** — Highlighted current batsmen & bowler
- **Live Events** — Ball-by-ball commentary with 4s, 6s, wickets
- **Match Info** — Venue, format, status, series details
- **Dark Theme** — Premium cricket dark UI
- **Responsive** — Works on phones and tablets

---

## Setup

### 1. Prerequisites
- Flutter SDK 3.x+
- Android Studio / Xcode

### 2. Install dependencies
```bash
cd cricket_live_tracker
flutter pub get
```

### 3. Get a FREE Cricket API Key
1. Visit [https://www.cricapi.com/](https://www.cricapi.com/)
2. Sign up for a free account (100 API calls/day)
3. Copy your API key from the dashboard

### 4. Add your API key
Open `lib/services/cricket_api_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_API_KEY';
```
with your actual key.

### 5. Run the app
```bash
flutter run
```

> **Note:** Without an API key, the app runs with rich mock data showcasing all features.

---

## Project Structure

```
lib/
├── main.dart                    # Entry point + navigation
├── models/
│   ├── match_model.dart         # Match data model
│   └── scorecard_model.dart     # Scorecard & player models
├── services/
│   └── cricket_api_service.dart # CricAPI integration + mock data
├── screens/
│   ├── home_screen.dart         # Live & Upcoming tabs
│   └── match_detail_screen.dart # Scorecard, Live events, Info
├── widgets/
│   ├── live_match_card.dart     # Live match card widget
│   ├── upcoming_match_card.dart # Upcoming match card widget
│   └── scorecard_widget.dart    # Full innings scorecard
└── theme/
    └── app_theme.dart           # Colors, typography, themes
```

---

## API Used

**CricAPI** (cricapi.com)
- Free tier: 100 calls/day
- Endpoints used:
  - `GET /currentMatches` — Live matches
  - `GET /matches` — All matches (upcoming)
  - `GET /match_scorecard` — Detailed scorecard
  - `GET /match_info` — Match metadata

---

## Screenshots (Mock Data Preview)

- **Home Screen** — Live matches with pulsing LIVE badge + score
- **Scorecard Tab** — Batting/bowling tables with current player indicators
- **Live Tab** — Ball-by-ball events (4, 6, W highlighted)
- **Info Tab** — Venue, format, series details
