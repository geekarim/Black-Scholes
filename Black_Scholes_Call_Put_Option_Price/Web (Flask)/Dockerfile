FROM python:3.13.4-slim

# Set working directory
WORKDIR /app

# Copy entire app source (including templates/)
COPY . /app/

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Run the Flask app
CMD ["python", "app.py"]