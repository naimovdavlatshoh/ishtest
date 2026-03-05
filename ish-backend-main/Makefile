.PHONY: install dev test lint format clean migrate upgrade downgrade run

# Install dependencies
install:
	poetry install --no-root

# Install with dev dependencies
dev:
	poetry install

# Run tests
test:
	poetry run pytest

# Run linter (if you add one)
lint:
	@echo "Linting not configured yet"

# Format code (if you add black/isort)
format:
	@echo "Formatting not configured yet"

# Clean cache and build files
clean:
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov

# Database migrations
migrate:
	poetry run alembic revision --autogenerate -m "$(msg)"

upgrade:
	poetry run alembic upgrade head

downgrade:
	poetry run alembic downgrade -1

# Run development server
run:
	poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Create database tables (alternative to migrations)
create-tables:
	poetry run python create_tables.py

# Check imports
check-imports:
	poetry run python test_imports.py
