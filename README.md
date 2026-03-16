# Laravel Dev Docker Image

Centralized Laravel development Docker images with two variants:

- **App** — Full Laravel application image with nginx, PHP-FPM, and supervisor
- **Package** — Lightweight CLI image for package development and testing

## Images

```
# App variant (nginx + PHP-FPM + supervisor)
ghcr.io/whilesmartphp/laravel-dev:8.4
ghcr.io/whilesmartphp/laravel-dev:8.2

# Package variant (PHP CLI only)
ghcr.io/whilesmartphp/laravel-dev:package-8.4
ghcr.io/whilesmartphp/laravel-dev:package-8.2
```

## App Variant

Full-stack Laravel development environment.

### What's Included

- **PHP-FPM** (8.2 or 8.4)
- **Nginx** with Laravel-optimized config
- **Supervisor** managing both processes
- **Composer** (latest)
- **PHP Extensions:** pdo_mysql, pdo_pgsql, mbstring, exif, pcntl, bcmath, gd, zip
- **Shared `laravel.mk`** at `/usr/local/share/laravel.mk`

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

### Makefile

Copy `laravel.mk` into your project or include it:

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
```

| Variable | Default | Description |
|----------|---------|-------------|
| `EXTRA_PORTS_SCRIPT` | *(empty)* | Shell script appended to `.ports` generation |
| `EXTRA_UP_INFO` | *(empty)* | Extra `echo` commands shown after `make up` |
| `TEST_CMD` | `php artisan test` | Command used by `make test` |
| `LINT_CMD` | `composer pint:test` | Command used by `make lint` |

### App Targets

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

---

## Package Variant

Lightweight image for developing and testing Laravel packages with Orchestra Testbench.

### What's Included

- **PHP CLI** (8.2 or 8.4)
- **Composer** (latest)
- **PHP Extensions:** pdo_mysql, pdo_pgsql, mbstring, zip
- **Shared `package.mk`** at `/usr/local/share/package.mk`

### docker-compose.yml

```yaml
name: my-package
services:
  app:
    image: ghcr.io/whilesmartphp/laravel-dev:package-8.4
    volumes:
      - .:/app
    working_dir: /app
    command: tail -f /dev/null
    environment:
      - APP_ENV=testing
```

### Makefile

Include `package.mk` from the image:

```makefile
include package.mk
```

Or override defaults before the include:

```makefile
TEST_CMD = ./vendor/bin/testbench package:test --parallel
LINT_FIX_CMD = ./vendor/bin/pint

include package.mk
```

| Variable | Default | Description |
|----------|---------|-------------|
| `TEST_CMD` | `./vendor/bin/testbench package:test` | Command used by `make test` |
| `LINT_CMD` | `composer pint:test` | Command used by `make lint` |
| `LINT_FIX_CMD` | `composer pint` | Command used by `make lint-fix` |

### Package Targets

| Target | Description |
|--------|-------------|
| `up` | Start containers |
| `down` | Stop and remove containers |
| `restart` | Restart containers |
| `logs` | Show container logs |
| `bash` | Open a shell in the container |
| `install` | Install dependencies (starts containers first) |
| `update` | Update dependencies |
| `test` | Run tests |
| `lint` | Check code formatting |
| `lint-fix` | Fix code formatting |
| `build` | Build workbench |
| `serve` | Start development server |
| `autoload` | Dump composer autoloader |
| `fresh` | Fresh start (down + up + install) |
| `setup` | Complete setup (fresh + test) |
| `check` | Run all checks (lint + test) |
| `clean` | Remove everything (containers, images, volumes) |
| `help` | Show available targets |

---

## Production

For production, use [`ghcr.io/whilesmartphp/frankenphp`](https://github.com/whilesmartphp/frakenphp) instead.
