FROM python:3.13.4-slim

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the remaining application source code into the container
COPY . .

# Start FastAPI app by default
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
