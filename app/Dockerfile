FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY . .

# Debug: List what was copied
RUN echo "=== Contents of /usr/src/app ===" && ls -la /usr/src/app
RUN echo "=== Looking for manage.py ===" && find /usr/src/app -name "manage.py" -type f
RUN echo "=== Current working directory ===" && pwd

RUN pip install --upgrade pip && pip install -r requirements.txt

ENV PYTHONPATH=/usr/src/app

CMD ["gunicorn", "core.wsgi:application", "--bind", "0.0.0.0:8000"]
