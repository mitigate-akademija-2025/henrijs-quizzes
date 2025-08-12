# Henrijs Quizzes

### Add `.env` file

```
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
MAIL_FROM=your@email.com
```

## (A) Run with Docker

```bash
docker build -t henrijs_quizzes . && \
docker run --rm -it -p 3000:3000 -e RAILS_ENV=development \
  --env-file .env \
  henrijs_quizzes \
  sh -lc "bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"
```

## (B) Run Locally

### 1. Install dependencies

Make sure you have the correct Ruby version:

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

Your app will be available at http://localhost:3000.
