# =====================================================================
# MAKEFILE FOR CI-CD-DJANGO PROJECT (ROOT LEVEL)
# =====================================================================
# How to use: In your project root, type `make <target>`, e.g.:
#   make up        # Start app for development
#   make ci-up     # Start containers using both compose files (CI)
#   make migrate   # Run Django migrations
#
# Pro tip: Use TABs (not spaces) for indents in Makefile!
# =====================================================================

# Base Compose command (dev only)
COMPOSE_DEV = docker-compose -f docker-compose.yml -f docker-compose.local.yml

# Compose command for CI (uses overrides from docker-compose.jenkins.yml)
COMPOSE_CI = docker-compose -f docker-compose.yml -f docker-compose.jenkins.yml

# Name of your Django web service (as defined in compose files)
WEB = web

# Name of your database service
DB = db

# Default: List all available targets (helpful for learning!)
help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## ' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# --- DEV COMMANDS (USE LOCALLY) ---------------------------------------

up:         ## Start all services (web, db) in background (dev)
	$(COMPOSE_DEV) up -d

down:       ## Stop and remove all containers (dev)
	$(COMPOSE_DEV) down

stop:       ## Stop all running containers (dev)
	$(COMPOSE_DEV) stop

restart:    ## Restart all running containers (dev)
	$(COMPOSE_DEV) restart

build:      ## Build/rebuild all images (dev)
	$(COMPOSE_DEV) build

logs:       ## View/follow logs for web container (dev)
	$(COMPOSE_DEV) logs -f $(WEB)

logs-db:    ## View/follow logs for db container (dev)
	$(COMPOSE_DEV) logs -f $(DB)

ps:         ## Show running containers (dev)
	$(COMPOSE_DEV) ps

migrate:    ## Run Django migrations (dev)
	$(COMPOSE_DEV) run --rm $(WEB) python manage.py migrate

createsuperuser: ## Create a Django superuser interactively (dev)
	$(COMPOSE_DEV) run --rm $(WEB) python manage.py createsuperuser

shell:      ## Open a bash shell inside the web container (dev)
	$(COMPOSE_DEV) run --rm $(WEB) /bin/bash

sh-db:      ## Open a shell inside the db container (dev)
	$(COMPOSE_DEV) exec $(DB) /bin/bash

reset:      ## Remove containers, networks, and volumes (DANGER: wipes DB)
	$(COMPOSE_DEV) down -v

orphan-clean: ## Remove orphaned containers (leftovers from old runs)
	$(COMPOSE_DEV) up -d --remove-orphans

# --- CI/CD COMMANDS (USE IN JENKINS OR MANUALLY WITH OVERRIDES) ------

ci-up:      ## Start services using both compose files (CI/CD)
	$(COMPOSE_CI) up -d

ci-down:    ## Stop and remove all containers using both compose files (CI/CD)
	$(COMPOSE_CI) down

ci-build:   ## Build/rebuild images using both compose files (CI/CD)
	$(COMPOSE_CI) build

ci-migrate: ## Run Django migrations using both compose files (CI/CD)
	$(COMPOSE_CI) run --rm $(WEB) python manage.py migrate

ci-logs:    ## View logs for web in CI/CD stack
	$(COMPOSE_CI) logs -f $(WEB)

ci-ps:      ## Show running containers (CI/CD)
	$(COMPOSE_CI) ps

ci-reset:   ## Remove containers, networks, and volumes (DANGER: wipes DB, CI/CD)
	$(COMPOSE_CI) down -v

ci-orphan-clean: ## Remove orphans (CI/CD)
	$(COMPOSE_CI) up -d --remove-orphans



# --- GITHUB COMMANDS ----------------------------
push:
	@read -p "Commit message: " msg; \
	read -p "Branch to push to (default: current branch): " branch; \
	git add .; \
	if [ -z "$$branch" ]; then branch=$$(git rev-parse --abbrev-ref HEAD); fi; \
	git commit -m "$$msg"; \
	git push origin "$$branch"


# --- CONVENIENCE/MAINTENANCE -----------------------------------------

prune-s:      ## Remove all unused docker objects (careful!)
	docker system prune -f

prune-s-all:  ## Remove all unused docker objects, including volumes (careful!)
	docker system prune -a -f --volumes

volume-ls:  ## List all docker volumes
	docker volume ls

volume-rm:  ## Remove a docker volume (usage: make volume-rm NAME=volume_name)
	docker volume rm $(NAME)

clean-pyc:  ## Remove all .pyc and __pycache__ files (useful after refactor)
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} +

# --- END -------------------------------------------------------------

