#!/bin/bash

# ISH Backend Setup Script

echo "🚀 Настройка ISH Backend..."

# Проверка Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не найден. Установите Python 3.9+"
    exit 1
fi

echo "✅ Python найден: $(python3 --version)"

# Создание виртуального окружения
if [ ! -d "venv" ]; then
    echo "📦 Создание виртуального окружения..."
    python3 -m venv venv
    echo "✅ Виртуальное окружение создано"
else
    echo "✅ Виртуальное окружение уже существует"
fi

# Активация виртуального окружения
echo "🔌 Активация виртуального окружения..."
source venv/bin/activate

# Обновление pip
echo "⬆️  Обновление pip..."
pip install --upgrade pip

# Установка зависимостей
echo "📥 Установка зависимостей..."
pip install -r requirements.txt

# Создание .env файла если его нет
if [ ! -f ".env" ]; then
    echo "📝 Создание .env файла..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ .env файл создан из .env.example"
        echo "⚠️  Не забудьте отредактировать .env файл!"
    else
        echo "⚠️  .env.example не найден, создайте .env вручную"
    fi
else
    echo "✅ .env файл уже существует"
fi

echo ""
echo "✅ Установка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Отредактируйте .env файл (DATABASE_URL, SECRET_KEY)"
echo "2. Создайте базу данных: createdb ish_db"
echo "3. Запустите миграции: alembic upgrade head"
echo "4. Запустите сервер: uvicorn app.main:app --reload"
echo ""
echo "💡 Для активации виртуального окружения в будущем:"
echo "   source venv/bin/activate"
