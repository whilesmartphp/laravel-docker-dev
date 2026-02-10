.DEFAULT_GOAL := help

HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
DC := HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker compose
EXEC := $(DC) exec --user www-data app

composer-install: ## Install composer dependencies
	$(EXEC) composer install

composer-update: ## Update composer dependencies
	$(EXEC) composer update

test: ## Run tests
	$(EXEC) php artisan test

lint: ## Check code formatting
	$(EXEC) composer pint:test

lint-fix: ## Fix code formatting
	$(EXEC) composer pint

migrate: ## Run database migrations
	$(EXEC) php artisan migrate

migrate-fresh: ## Drop all tables and re-run all migrations
	$(EXEC) php artisan migrate:fresh

seed: ## Seed the database
	$(EXEC) php artisan db:seed

migrate-fresh-seed: ## Run fresh migrations with seeders
	$(EXEC) php artisan migrate:fresh --seed

optimize: ## Optimize the application
	$(EXEC) php artisan optimize

tinker: ## Start a tinker session
	$(EXEC) php artisan tinker

bash: ## Open a bash session in the app container
	$(EXEC) bash

fix-permissions: ## Fix file permissions
	docker compose exec app bash -c "chown -R www-data:www-data /var/www/html && chmod -R 775 /var/www/html/storage && chmod -R 775 /var/www/html/bootstrap/cache"

logs: ## Show application logs
	docker compose logs -f app

down: ## Stop and remove containers
	docker compose down

stop: ## Stop containers
	docker compose stop

clean: ## Remove all containers, networks, images, and volumes
	docker compose down --rmi all -v

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
