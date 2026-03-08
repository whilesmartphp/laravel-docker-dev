# Laravel Dev Docker Image

Centralized Laravel development Docker image with nginx, PHP-FPM, and supervisor.

## Image

```
ghcr.io/whilesmartphp/laravel-dev:8.4
ghcr.io/whilesmartphp/laravel-dev:8.2
```

## What's Included

- **PHP-FPM** (8.2 or 8.4)
- **Nginx** with Laravel-optimized config
- **Supervisor** managing both processes
- **Composer** (latest)
- **PHP Extensions:** pdo_mysql, pdo_pgsql, mbstring, exif, pcntl, bcmath, gd, zip
- **Shared `laravel.mk`** at `/usr/local/share/laravel.mk`

## Usage

### docker-compose.yml

```yaml
services:
  app:
    image: ghcr.io/whilesmartphp/laravel-dev:8.4
    build:
      context: .
      dockerfile_inline: |
        FROM ghcr.io/whilesmartphp/laravel-dev:8.4
      args:
        HOST_UID: '${HOST_UID:-1000}'
        HOST_GID: '${HOST_GID:-1000}'
    ports:
      - '${APP_PORT:-8000}:80'
    volumes:
      - '.:/var/www/html'
```

The `HOST_UID`/`HOST_GID` build args map container permissions to your host user, avoiding file ownership issues.

### Makefile

Copy `laravel.mk` into your project. It works standalone or with a thin project `Makefile`:

```makefile
include laravel.mk
```

Port resolution is automatic — `make up` finds available ports starting from 8000 and stores them in `.ports`.

### Customizing for Your Project

`laravel.mk` exposes hook variables you can set **before** the `include` to customize behavior without overriding targets:

```makefile
# Extra port defaults
DEFAULT_DB_PORT ?= 3306
DEFAULT_PMA_PORT ?= 8080

# Add extra ports to .ports file
EXTRA_PORTS_SCRIPT = \
	DB_PORT=$$(port=$(DEFAULT_DB_PORT); while nc -z 127.0.0.1 $$port 2>/dev/null || lsof -i :$$port >/dev/null 2>&1; do port=$$((port + 1)); done; echo $$port); \
	PMA_PORT=$$(port=$(DEFAULT_PMA_PORT); while nc -z 127.0.0.1 $$port 2>/dev/null || lsof -i :$$port >/dev/null 2>&1; do port=$$((port + 1)); done; echo $$port); \
	echo "FORWARD_DB_PORT=$$DB_PORT" >> $(PORTS_FILE); \
	echo "PMA_PORT=$$PMA_PORT" >> $(PORTS_FILE);

# Show extra service URLs on 'make up'
EXTRA_UP_INFO = \
	echo "  phpMyAdmin: http://localhost:$$PMA_PORT" && \
	echo "  MySQL:      localhost:$$FORWARD_DB_PORT"

# Custom test and lint commands
TEST_CMD = php artisan test --coverage
LINT_CMD = composer phpcs:test && composer phpmd && composer pint:test

include laravel.mk

# Add project-specific targets below
```

| Variable | Default | Description |
|----------|---------|-------------|
| `EXTRA_PORTS_SCRIPT` | *(empty)* | Shell script appended to `.ports` generation |
| `EXTRA_UP_INFO` | *(empty)* | Extra `echo` commands shown after `make up` |
| `TEST_CMD` | `php artisan test` | Command used by `make test` |
| `LINT_CMD` | `composer pint:test` | Command used by `make lint` |

### Available Targets

| Target | Description |
|--------|-------------|
| `up` | Start the application (auto port resolution) |
| `setup` | First-time setup (up + install + key + migrate + seed) |
| `restart` | Restart the application |
| `ports` | Show current port assignments |
| `reset-ports` | Clear ports and find new available ones |
| `composer-install` | Install composer dependencies |
| `composer-update` | Update composer dependencies |
| `test` | Run tests |
| `lint` | Check code formatting (Pint) |
| `lint-fix` | Fix code formatting (Pint) |
| `migrate` | Run database migrations |
| `migrate-fresh` | Drop all tables and re-run migrations |
| `seed` | Seed the database |
| `migrate-fresh-seed` | Fresh migrations with seeders |
| `optimize` | Optimize the application |
| `tinker` | Start a tinker session |
| `bash` | Open a shell in the container |
| `fix-permissions` | Fix storage/cache permissions |
| `logs` | Tail application logs |
| `down` | Stop and remove containers |
| `stop` | Stop containers |
| `clean` | Remove everything (containers, images, volumes) |
| `help` | Show available targets |

## Production

For production, use [`ghcr.io/whilesmartphp/frankenphp`](https://github.com/whilesmartphp/frakenphp) instead.
