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
# Rails secret
SECRET_KEY_BASE=

# Postgres Database
DATABASE_URL=

# Redis Database
REDIS_URL=

# Mail Service
SMTP_USERNAME=
SMTP_PASSWORD=
MAIL_FROM=

# Cloudflare R2
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_ENDPOINT=
R2_BUCKET=
```
