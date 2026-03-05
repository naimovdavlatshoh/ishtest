# Setup Guide

## Вариант 1: venv (рекомендуется)

### 1. Создать виртуальное окружение

```bash
cd ish-backend
python3 -m venv venv
```

### 2. Активировать виртуальное окружение

**macOS/Linux:**

```bash
source venv/bin/activate
```

**Windows:**

```bash
venv\Scripts\activate
```

### 3. Установить зависимости

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Настроить переменные окружения

```bash
cp .env.example .env
```

Отредактируйте `.env` файл и укажите:

- `DATABASE_URL` - строка подключения к PostgreSQL
- `SECRET_KEY` - секретный ключ (можно сгенерировать: `openssl rand -hex 32`)

### 5. Настроить базу данных

```bash
# Создать базу данных (если еще не создана)
createdb ish_db

# Запустить миграции
alembic upgrade head
```

### 6. Запустить сервер

```bash
uvicorn app.main:app --reload
```

Сервер будет доступен на: http://localhost:8000
API документация: http://localhost:8000/api/docs

---

## Вариант 2: Poetry (альтернатива)

Если предпочитаете Poetry:

### 1. Установить Poetry (если еще не установлен)

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

### 2. Инициализировать проект

```bash
cd ish-backend
poetry init
```

### 3. Установить зависимости

```bash
poetry install
```

Или добавить зависимости из requirements.txt:

```bash
poetry add fastapi uvicorn[standard] sqlalchemy psycopg2-binary alembic python-jose[cryptography] bcrypt pydantic pydantic-settings pytest
```

### 4. Активировать окружение

```bash
poetry shell
```

### 5. Запустить сервер

```bash
poetry run uvicorn app.main:app --reload
```

---

## Проверка установки

После установки проверьте:

```bash
python -c "import fastapi; print('FastAPI установлен!')"
python -c "import sqlalchemy; print('SQLAlchemy установлен!')"
```

## Полезные команды

### Деактивировать виртуальное окружение

```bash
deactivate
```

### Создать новую миграцию

```bash
alembic revision --autogenerate -m "Описание изменений"
alembic upgrade head
```

### Запустить тесты

```bash
pytest
```
