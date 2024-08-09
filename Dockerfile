# Use a Python base image
FROM python:3.10-slim-buster

# Set working directory
WORKDIR /usr/src/dbt

# Copy the entire dbt project directory into the container
COPY ./makhbazti_modeling  .

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy profiles.yml into the correct location
RUN mkdir -p /root/.dbt
COPY profiles.yml /root/.dbt/profiles.yml

WORKDIR /usr/src/dbt/makhbazti_modeling/

# Run dbt commands
CMD dbt deps && dbt build --profiles-dir /root/.dbt/profiles.yml && sleep infinity
