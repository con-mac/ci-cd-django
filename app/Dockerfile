FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# Copy all application code
COPY . .

# Install Python dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

ENV PYTHONPATH=/usr/src/app

CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]
