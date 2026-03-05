# ISH Backend API

FastAPI backend for ISH - Job platform for Uzbekistan.

## Project Structure

```
ish-backend/
├── app/
│   ├── main.py                # FastAPI application entry point
│   ├── core/                  # Configuration and settings
│   │   ├── config.py
│   │   └── logger.py
│   ├── database/              # Database models and session
│   │   ├── base.py
│   │   ├── session.py
│   │   └── models.py
│   ├── exceptions/            # Custom exceptions
│   │   └── custom_exceptions.py
│   ├── repositories/          # Database CRUD operations
│   │   ├── user_repository.py
│   │   ├── profile_repository.py
│   │   ├── job_repository.py
│   │   ├── company_repository.py
│   │   └── application_repository.py
│   ├── schemas/               # Pydantic schemas
│   │   ├── user_schema.py
│   │   ├── profile_schema.py
│   │   ├── job_schema.py
│   │   ├── company_schema.py
│   │   └── application_schema.py
│   ├── services/              # Business logic
│   │   ├── user_service.py
│   │   ├── profile_service.py
│   │   ├── job_service.py
│   │   ├── company_service.py
│   │   └── application_service.py
│   ├── api/                   # API routes
│   │   ├── dependencies.py    # Auth dependencies
│   │   └── v1/
│   │       ├── auth.py
│   │       ├── users.py
│   │       ├── profiles.py
│   │       ├── jobs.py
│   │       ├── companies.py
│   │       └── applications.py
│   ├── utils/                 # Utility functions
│   │   ├── formatters.py
│   │   └── security.py
│   └── constants/             # Application constants
│       └── index.py
├── tests/                     # Unit and integration tests
├── alembic/                   # Database migrations
├── requirements.txt
└── .env.example
```

## Features

- **Authentication**: JWT-based authentication with phone/email login
- **User Management**: User registration, profile management
- **Job Management**: Create, update, delete jobs
- **Company Management**: Create and manage companies
- **Applications**: Apply to jobs, manage applications
- **Profile Setup**: Onboarding flow for new users

## Quick Setup

### Автоматическая установка (рекомендуется)

```bash
cd ish-backend
./setup.sh
```

### Ручная установка

#### 1. Создать виртуальное окружение

```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# или
venv\Scripts\activate     # Windows
```

#### 2. Установить зависимости

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

#### 3. Настроить переменные окружения

```bash
cp .env.example .env
```

Отредактируйте `.env`:
- `DATABASE_URL`: PostgreSQL connection string (например: `postgresql://user:password@localhost:5432/ish_db`)
- `SECRET_KEY`: Сгенерируйте ключ: `openssl rand -hex 32`
- `CORS_ORIGINS`: URLs фронтенда

#### 4. Настроить базу данных

```bash
# Создать базу данных
createdb ish_db

# Запустить миграции
alembic upgrade head
```

#### 5. Запустить сервер

```bash
# Development
uvicorn app.main:app --reload

# Production
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Подробная инструкция в [SETUP.md](./SETUP.md)

## API Documentation

Once the server is running, visit:
- Swagger UI: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user

### Users
- `GET /api/v1/users/me` - Get current user
- `PUT /api/v1/users/me` - Update current user

### Profiles
- `POST /api/v1/profiles` - Create profile
- `GET /api/v1/profiles/me` - Get current profile
- `PUT /api/v1/profiles/me` - Update current profile

### Jobs
- `GET /api/v1/jobs` - Get all jobs
- `GET /api/v1/jobs/{id}` - Get job by ID
- `GET /api/v1/jobs/my-jobs` - Get my jobs
- `POST /api/v1/jobs` - Create job
- `PUT /api/v1/jobs/{id}` - Update job
- `DELETE /api/v1/jobs/{id}` - Delete job

### Companies
- `GET /api/v1/companies` - Get all companies
- `GET /api/v1/companies/{id}` - Get company by ID
- `GET /api/v1/companies/my-companies` - Get my companies
- `POST /api/v1/companies` - Create company
- `PUT /api/v1/companies/{id}` - Update company
- `DELETE /api/v1/companies/{id}` - Delete company

### Applications
- `GET /api/v1/applications/my-applications` - Get my applications
- `GET /api/v1/applications/job/{job_id}` - Get job applications
- `POST /api/v1/applications` - Create application
- `PUT /api/v1/applications/{id}` - Update application
- `DELETE /api/v1/applications/{id}` - Delete application

## Database Models

- **User**: Users with email/phone authentication
- **Profile**: User profiles with bio, skills, experience
- **Company**: Companies that post jobs
- **Job**: Job postings with requirements and salary
- **Application**: Job applications from users

## Development

### Run Tests

```bash
pytest
```

### Create Migration

```bash
alembic revision --autogenerate -m "Description"
alembic upgrade head
```

## License

MIT
