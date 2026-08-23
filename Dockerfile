# Use a slim Python 3.12 image to match the local requirements
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Prevent Python from writing .pyc files and enable unbuffered logging (critical for K8s)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# CRITICAL FIX 1: Install system-level C++ libraries required by XGBoost on Debian Slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy ONLY the requirements file first to leverage Docker layer caching
COPY requirements.txt .

# Your custom Windows UTF-16 workaround (Maintained)
RUN python -c "import pathlib; raw=pathlib.Path('requirements.txt').read_bytes(); text=raw.decode('utf-16' if raw.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8', 'ignore'); pathlib.Path('clean.txt').write_text('\n'.join(l for l in text.splitlines() if 'pywinpty' not in l.lower()), encoding='utf-8')" && \
    pip install --no-cache-dir -r clean.txt

# Copy the source code into the container
COPY src/ ./src/

# CRITICAL FIX 2: We MUST copy the compiled model artifact so the API can load it into RAM
COPY models/ ./models/

# Expose the web port
EXPOSE 8000

# CRITICAL FIX 3: Run the FastAPI web server, NOT the training script
CMD ["uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]