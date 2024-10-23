# Base image with Python 3.10.12
FROM python:3.10.12-slim

# Set the working directory
WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY EL_pipeline_runner.sh /app/EL_pipeline_runner.sh
COPY dbt_modeling.sh /app/dbt_modeling.sh
COPY weather_pipe.sh /app/weather_pipe.sh