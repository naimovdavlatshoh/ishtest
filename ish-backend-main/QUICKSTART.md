# Быстрый старт

## Проблема: "This site can't be reached"

**Причина:** Сервер не запущен.

## Решение:

### Вариант 1: Использовать скрипт (рекомендуется)

```bash
cd ish-backend
./run.sh
```

### Вариант 2: Запустить вручную

```bash
cd ish-backend
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Вариант 3: Запустить через Python

```bash
cd ish-backend
poetry run python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## После запуска:

Сервер будет доступен на:
- **API:** http://localhost:8000
- **Документация:** http://localhost:8000/api/docs
- **ReDoc:** http://localhost:8000/api/redoc

## Возможные ошибки:

### 1. "ModuleNotFoundError"
Убедитесь, что все зависимости установлены:
```bash
poetry install
```

### 2. "Database connection error"
Это нормально на первом запуске. Сервер запустится, но эндпоинты с БД не будут работать до настройки базы данных.

### 3. "Port 8000 already in use"
Используйте другой порт:
```bash
poetry run uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

## Проверка работы:

Откройте в браузере:
- http://localhost:8000 - должен показать `{"message":"ISH API","version":"1.0.0","docs":"/api/docs"}`
- http://localhost:8000/health - должен показать `{"status":"healthy"}`
- http://localhost:8000/api/docs - Swagger UI

## Остановка сервера:

Нажмите `Ctrl+C` в терминале, где запущен сервер.
