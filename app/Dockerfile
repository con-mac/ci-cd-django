FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /usr/src/app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files
COPY . .

# Set environment variables
ENV PYTHONPATH=/usr/src/app

# Run the app (optional, usually handled by docker-compose)
CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]
