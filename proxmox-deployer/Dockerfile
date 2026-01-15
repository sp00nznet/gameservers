FROM python:3.11-slim

LABEL maintainer="Silverware Game Servers"
LABEL description="Game Server Deployer for Proxmox VE"

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create data directory for database
RUN mkdir -p /data

# Environment variables
ENV FLASK_APP=run.py
ENV FLASK_ENV=production
ENV DATABASE_URL=sqlite:////data/deployer.db

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Run with gunicorn in production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "run:app"]
