.DEFAULT_GOAL := help

HOST_UID := $(or $(shell id -u 2>/dev/null),1000)
HOST_GID := $(or $(shell id -g 2>/dev/null),1000)

DC = HOST_UID=$(HOST_UID) HOST_GID=$(HOST_GID) docker compose
EXEC = $(DC) exec app

TEST_CMD ?= ./vendor/bin/testbench package:test
LINT_CMD ?= composer pint:test
LINT_FIX_CMD ?= composer pint

up: ## Start containers
	$(DC) up -d

down: ## Stop and remove containers
	$(DC) down

restart: ## Restart containers
	$(DC) restart

logs: ## Show container logs
	$(DC) logs -f

bash: ## Open a shell in the container
	$(EXEC) bash

install: up ## Install dependencies
	$(EXEC) composer install

update: ## Update dependencies
	$(EXEC) composer update

test: ## Run tests
	$(EXEC) $(TEST_CMD)

lint: ## Check code formatting
	$(EXEC) $(LINT_CMD)

lint-fix: ## Fix code formatting
	$(EXEC) $(LINT_FIX_CMD)

build: ## Build workbench
	$(EXEC) composer build

serve: ## Start development server
	$(EXEC) composer serve

autoload: ## Dump composer autoloader
	$(EXEC) composer dump-autoload

fresh: down up install ## Fresh start: down, up, install

setup: fresh test ## Complete setup with tests
	@echo "Setup complete!"

check: lint test ## Run all checks (formatting + tests)
	@echo "All checks passed!"

clean: ## Remove containers, images, and volumes
	$(DC) down --rmi all -v

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed 's/^[^:]*://' | sort -u | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
