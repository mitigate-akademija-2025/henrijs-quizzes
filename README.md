# Henrijs Quizzes

## (A) Run with Docker

```bash
docker-compose up --build
```

## (B) Run Locally

Make sure you have the correct Ruby version.

### 1. Install dependencies

```bash
bundle install
```

### 2. Set up the database

```bash
bin/rails db:prepare
```

### 3. Start the application

```bash
bundle exec bin/dev
```

Look for http://localhost:3000.

### For production, add `.env` file

```
SECRET_KEY_BASE=

DATABASE_URL=

REDIS_URL=

SMTP_USERNAME=
SMTP_PASSWORD=
MAIL_FROM=

R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_ENDPOINT=
R2_BUCKET=

AWS_REQUEST_CHECKSUM_CALCULATION="WHEN_REQUIRED"
AWS_RESPONSE_CHECKSUM_VALIDATION="WHEN_REQUIRED"

GEMINI_API_KEY=
GEMINI_MODELS="gemini-2.5-flash, gemini-2.5-flash-lite, gemini-2.5-pro, gemini-2.0-flash, gemini-2.0-flash-lite, gemini-1.5-flash"

```
