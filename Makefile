# Bring up the app in detached mode
up:
	docker-compose up -d

# Bring down the app and remove volumes
down:
	docker-compose down -v --remove-orphans

# Rebuild all containers
build:
	docker-compose build

# Apply database migrations
migrate:
	docker-compose exec web python manage.py migrate

# Create a superuser interactively
createsuperuser:
	docker-compose exec web python manage.py createsuperuser

# Run tests
test:
	docker-compose exec web python manage.py test

# Open Django shell
shell:
	docker-compose exec web python manage.py shell

# Show logs
logs:
	docker-compose logs -f

# Collect static files (for production prep)
collectstatic:
	docker-compose exec web python manage.py collectstatic --noinput
