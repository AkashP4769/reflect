# Use a lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy build output
COPY build/web /app

# Expose port 8080
EXPOSE 8080

# Run Python HTTP server
CMD ["python3", "-m", "http.server", "8080", "--directory", "/app"]
