FROM python:3.12-slim
 
 # Set working directory
 WORKDIR /app
 
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

 # Install system dependencies (including ffmpeg for conversions)
RUN apt-get update && apt-get install -y --no-install-recommends \
     ffmpeg \
     && rm -rf /var/lib/apt/lists/*
 
 # Copy project files
 COPY requirements.txt .
 COPY app.py .
 COPY organize_music.py .
 COPY templates/ ./templates/
 COPY static/ ./static/
 
 # Install Python dependencies
RUN python -m pip install --no-cache-dir --upgrade pip \
+    && pip install --no-cache-dir -r requirements.txt
 
 # Create a directory for downloads and organized music
 RUN mkdir -p /app/downloads /app/downloads/organized
 
 # Expose the port the app runs on
 EXPOSE 5000
 
 # (Optional) environment variables
 ENV FLASK_APP=app.py
 ENV FLASK_ENV=production
 ENV FLASK_RUN_HOST=0.0.0.0
 ENV FLASK_RUN_PORT=5000
 
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/', timeout=3)" || exit 1

 # Run the application, explicitly specifying host & port
 CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
