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

Copy `laravel.mk` into your project and create a thin `Makefile`:

```makefile
include laravel.mk

up:  ## Start the application
	$(DC) up -d

setup: up composer-install  ## First-time setup
	$(EXEC) php artisan key:generate
	$(MAKE) migrate-fresh-seed
```

### Available `laravel.mk` Targets

| Target | Description |
|--------|-------------|
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
