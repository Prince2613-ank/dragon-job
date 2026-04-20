# Dragon Jobs Backend

Express + Prisma + PostgreSQL backend for the Flutter app in `flutter_application_1/`.

## Tech stack

- Node.js + Express
- Prisma ORM
- PostgreSQL
- JWT auth

## Quick start

1. Install dependencies:

```bash
npm install
```

2. Copy env file:

```bash
cp .env.example .env
```

3. Set your DB in `.env`:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/dragon_jobs?schema=public
JWT_SECRET=your-strong-secret
PORT=4000
ADMIN_EMAILS=admin@example.com
```

4. Run migrations and generate client:

```bash
npm run prisma:migrate -- --name init
```

5. Seed sample posts:

```bash
npm run prisma:seed
```

Seed behavior:
- Adds a larger catalog of jobs/internships/daily-wage posts (idempotent).
- Creates/updates one admin and one normal user.
- Admin email is taken from `ADMIN_EMAILS` first value.
- Default seed password is `Password@123` (override via `SEED_DEFAULT_PASSWORD`).

6. Start API:

```bash
npm run dev
```

API base URL:

```txt
http://localhost:4000
```

## Main endpoints

- `POST /auth/signup`
- `POST /auth/login`
- `GET /users/me` (Bearer token)
- `PUT /users/me` (Bearer token)
- `GET /posts`
- `GET /posts?type=job|internship|daily_wage`
- `POST /posts` (Bearer token, admin only)
- `GET /saved-jobs` (Bearer token)
- `POST /saved-jobs/:postId` (Bearer token)
- `DELETE /saved-jobs/:postId` (Bearer token)
