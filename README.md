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
docker compose exec web bundle exec rspec

# Shopify RuboCop
docker compose exec web bin/rubocop

# Brakeman
docker compose exec web bin/brakeman --no-pager
```

Необязательные настройки можно переопределить, скопировав `.env.example` в `.env`. Файл `.env` не отслеживается Git.

## Content provider

Для TMDB задайте `TMDB_ACCESS_TOKEN` (рекомендуется) или `TMDB_API_KEY`. Регион по умолчанию задаётся через `TMDB_DEFAULT_REGION`, а реализация — через `CONTENT_PROVIDER=tmdb`.

HTTP-слой обращается к общей PORO-точке входа `ExternalContent::Gateway`, которая зависит только от контракта `ExternalContent::Provider`. Другого провайдера можно подключить без изменения контроллеров:

```ruby
ExternalContent::ProviderRegistry.register("another") { AnotherProvider::Adapter.new }
```

После этого достаточно установить `CONTENT_PROVIDER=another`. В тестах готовый gateway внедряется через `ExternalContent::Gateway.default=`.

TMDB-реализация собрана в одном composition root. Каждый внутренний сервис и mapper является PORO с единственным публичным рабочим методом `#call`; все зависимости передаются через конструктор.

### API v1

- `GET /api/v1/home`
- `GET /api/v1/titles`
- `GET /api/v1/search`
- `GET /api/v1/titles/:media_type/:id`
- `GET /api/v1/people/:id`
- `GET /api/v1/configuration`

### Гостевые действия

Приложение один раз создаёт случайный UUID и сохраняет его в данных установки. Все запросы ниже отправляют этот UUID в заголовке `X-Device-Id`. При первом запросе сервер создаёт временного гостя. Регистрация не нужна; после очистки данных приложения прежний UUID и доступ к гостевым данным теряются.

- `GET /api/v1/guest` — создать или получить гостя.
- `GET /api/v1/library` — записи библиотеки текущего гостя.
- `PUT /api/v1/library/:media_type/:id` — сохранить статус, оценку, избранное и заметку. JSON: `{"status":"WATCHING","user_rating":8,"favorite":true,"personal_note":"..."}`. Допустимые статусы: `WANT_TO_WATCH`, `WATCHING`, `ON_HOLD`, `DROPPED`, `COMPLETED`.
- `DELETE /api/v1/library/:media_type/:id` — удалить запись.
- `GET /api/v1/recent_views` — 10 последних открытых тайтлов.
- `PUT /api/v1/recent_views/:media_type/:id` — отметить открытие тайтла.
- `GET /api/v1/titles/:media_type/:id/comments` — комментарии с вложенными ответами, числом лайков и `is_liked` для гостя.
- `POST /api/v1/titles/:media_type/:id/comments` — создать комментарий. JSON: `{"text":"..."}`; для ответа добавить `"parent_id":123`.
- `PUT /api/v1/comments/:id/like` — поставить или убрать лайк. JSON: `{"liked":true}` или `{"liked":false}`.

`media_type` — `tv` или `movie`, `id` — положительный числовой ID из каталога.

Все ошибки имеют форму `{ "error": { "code": "...", "message": "...", "details": {} } }`. Ошибочные параметры возвращают `422`, отсутствующие сущности — `404`, а сбой внешнего провайдера — `502` или `503`.
