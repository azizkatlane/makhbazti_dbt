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

# Make the shell scripts executable
RUN chmod +x /app/EL_pipeline_runner.sh /app/dbt_modeling.sh /app/weather_pipe.sh

# Copy the crontab file to the container (if you have one)
COPY my_crontab /etc/cron.d/my_crontab

# Give execution rights to the cron file
RUN chmod 0644 /etc/cron.d/my_crontab

# Apply the cron job
RUN crontab /etc/cron.d/my_crontab

# Run the command on container startup
CMD ["cron", "-f"]