# Настройка базы данных

## 1. Настройте .env файл

Откройте `.env` файл и укажите правильные данные для подключения:

```bash
# Если у PostgreSQL нет пароля:
DATABASE_URL=postgresql://postgres@localhost:5432/ish_db

# Если у PostgreSQL есть пароль:
DATABASE_URL=postgresql://postgres:ваш_пароль@localhost:5432/ish_db

# Если используете другого пользователя:
DATABASE_URL=postgresql://username:password@localhost:5432/ish_db
```

## 2. Проверьте подключение

```bash
# Проверить, что база данных существует
psql -l | grep ish_db

# Или подключиться напрямую
psql -d ish_db
```

## 3. Создайте первую миграцию

```bash
cd ish-backend
poetry run alembic revision --autogenerate -m "Initial migration"
```

Это создаст файл миграции в `alembic/versions/` на основе ваших моделей.

## 4. Примените миграции

```bash
poetry run alembic upgrade head
```

Это создаст все таблицы в базе данных.

## 5. Проверьте таблицы

```bash
psql -d ish_db -c "\dt"
```

Должны появиться таблицы:
- users
- profiles
- companies
- jobs
- applications

## Альтернатива: Создать таблицы без миграций

Если хотите быстро создать таблицы без миграций:

```bash
poetry run python -c "from app.database.session import init_db; init_db()"
```

Но рекомендуется использовать Alembic для управления схемой БД.

## Устранение проблем

### Ошибка подключения
- Проверьте, что PostgreSQL запущен: `pg_isready`
- Проверьте правильность DATABASE_URL в .env
- Убедитесь, что база данных существует: `createdb ish_db`

### Ошибка прав доступа
- Убедитесь, что пользователь PostgreSQL имеет права на создание таблиц
- Или создайте пользователя: `createuser -s your_username`
