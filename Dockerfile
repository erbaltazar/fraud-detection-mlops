# Use a slim Python 3.12 image to match the local requirements
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Prevent Python from writing .pyc files and enable unbuffered logging (critical for K8s)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy ONLY the requirements file first to leverage Docker layer caching
COPY requirements.txt .

# CRITICAL FIX 3.0 (The MLOps Reality Check): 
# PowerShell generates text files in UTF-16 encoding by default. Linux tools like 'grep' 
# treat UTF-16 as binary garbage, resulting in a blank file and a silent pip failure. 
# We use Python natively to safely decode the file, filter out pywinpty, and reinstall cleanly.
RUN python -c "import pathlib; raw=pathlib.Path('requirements.txt').read_bytes(); text=raw.decode('utf-16' if raw.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8', 'ignore'); pathlib.Path('clean.txt').write_text('\n'.join(l for l in text.splitlines() if 'pywinpty' not in l.lower()), encoding='utf-8')" && \
    pip install --no-cache-dir -r clean.txt

# Copy the source code into the container
COPY src/ ./src/

# CRITICAL: We purposely DO NOT copy the data/ directory here.
# Large datasets should never be baked into a container image. 
# We will inject the data dynamically at runtime using a volume mount.

# Set the default command to run your orchestrator
CMD ["python", "src/main.py"]