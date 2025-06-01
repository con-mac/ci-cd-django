# app/Dockerfile
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN apt-get update && apt-get install -y netcat-openbsd gcc postgresql-client


# Set work directory
WORKDIR /usr/src/app

# Install Python packages
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files
COPY . .

# Run the Django app
CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]
