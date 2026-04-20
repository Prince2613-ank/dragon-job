# Dragon Jobs Flutter App

This app now uses a backend-only data flow via Express APIs backed by PostgreSQL.

## Project structure

- `flutter_application_1/` -> Flutter frontend
- `backend/` -> Express + Prisma + PostgreSQL backend

## Backend setup

From the `backend/` folder:

```bash
npm install
cp .env.example .env
npm run prisma:migrate -- --name init
npm run prisma:seed
npm run dev
```

The backend runs on:

```txt
http://localhost:4000
```

## Flutter setup

From the `flutter_application_1/` folder:

```bash
flutter pub get
```

Run with backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Notes:

- Use `10.0.2.2` for Android emulator to reach local machine.
- For physical device, use your machine LAN IP, for example:
  `http://192.168.1.20:4000`
- For Windows/macOS/Linux desktop app, `http://localhost:4000` usually works.

## Current integration status

Implemented now:

- Backend auth (`/auth/signup`, `/auth/login`)
- Backend posts (`/posts`, `/posts?type=...`, `/posts` create)
- Backend user profile sync (`/users/me`)
- Backend user-scoped skills sync (`/users/me/skills`)
- Backend AI resume parsing + matching (`/ai/analyze-resume`)
- Flutter app data operations are backend-only (auth, posts, saved jobs, profile, skills, resume analysis)
- No local SQLite dependency in frontend

Still local in frontend:

- UI/session preferences in `SharedPreferences` (for example counters, small UI flags)
