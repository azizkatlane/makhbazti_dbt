# Base image with Python 3.10.12
FROM python:3.10.12-slim

# Set the working directory
WORKDIR /app

# Update package list and install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential \
	&& rm -rf /var/lib/apt/lists/*

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip setuptools
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app

# Ensure the script is executable
RUN chmod +x /app/scripts/run_tasks.sh


COPY profiles.yml /root/.dbt/profiles.yml


# Set the entry point to run the bash script
ENTRYPOINT ["/bin/bash", "/app/scripts/run_tasks.sh"]