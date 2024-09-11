FROM salomaosan/ads:v0.1

# Bring in app
WORKDIR /app
COPY ./requirements-dd.txt ./requirements-dd.txt

# Install dependencies via pip and avoid caching build artifacts
RUN pip install --no-cache-dir -r requirements-dd.txt

# Start the app using ddtrace so we have profiling and tracing
CMD ["flask", "run", "--port=5002", "--host=0.0.0.0"]