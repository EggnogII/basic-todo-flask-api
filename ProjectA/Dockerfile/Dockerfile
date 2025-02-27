FROM python:slim

WORKDIR /home/basic-todo-flask-api

# Install necessary dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements first for better caching
COPY requirements.txt .

# Create virtual environment & install dependencies
RUN python -m venv venv && \
    venv/bin/pip install --no-cache-dir --upgrade pip && \
    venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Ensure entrypoint script is executable
RUN chmod +x entrypoint.sh

# Expose necessary ports
EXPOSE 80 5432

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Use entrypoint for better signal handling in ECS
ENTRYPOINT ["bash", "./entrypoint.sh"]
