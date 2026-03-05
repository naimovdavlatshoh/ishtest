#!/bin/bash

# ISH Backend Run Script

echo "🚀 Запуск ISH Backend..."

cd "$(dirname "$0")"

# Проверка Poetry
if ! command -v poetry &> /dev/null; then
    echo "❌ Poetry не найден. Установите Poetry или используйте venv"
    exit 1
fi

# Проверка .env файла
if [ ! -f ".env" ]; then
    echo "⚠️  .env файл не найден"
    if [ -f ".env.example" ]; then
        echo "📝 Создание .env из .env.example..."
        cp .env.example .env
        echo "✅ .env создан. Отредактируйте его перед запуском!"
    fi
fi

# Запуск сервера
echo "🌐 Запуск сервера на http://localhost:8000"
echo "📚 API документация: http://localhost:8000/api/docs"
echo ""
echo "Для остановки нажмите Ctrl+C"
echo ""

poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
