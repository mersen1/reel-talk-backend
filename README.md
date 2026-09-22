# Reel Talk Backend

API-only приложение на Ruby on Rails с PostgreSQL. Локальная разработка полностью работает в Docker.

## Стек

- Ruby 4.0.7
- Rails 8.1.3.1
- PostgreSQL 18.6

## Запуск

Требуется только Docker с поддержкой Compose.

```bash
docker compose up --build
```

При первом старте контейнер установит gems и подготовит базу данных. API будет доступно по адресу <http://localhost:3000>, healthcheck — <http://localhost:3000/up>.

Остановить приложение:

```bash
docker compose down
```

Остановить приложение и удалить локальные данные PostgreSQL и кеш gems:

```bash
docker compose down --volumes
```

## Команды разработки

```bash
# Rails console
docker compose exec web bin/rails console

# Миграции
docker compose exec web bin/rails db:migrate

# Тесты
docker compose exec web bin/rails test

# Shopify RuboCop
docker compose exec web bin/rubocop

# Brakeman
docker compose exec web bin/brakeman --no-pager
```

Необязательные настройки можно переопределить, скопировав `.env.example` в `.env`. Файл `.env` не отслеживается Git.
