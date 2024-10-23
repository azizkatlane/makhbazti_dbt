#!/bin/bash


cd ~/makhbazti_dbt

mkdir -p logs 

echo "FETCHING WEATHER DATA started at: $(date +"%d-%m-%y %T")"

python weather_dlt_api.py 2>&1 | tee logs/weather_pipeline.log
echo "FETCHING WEATHER DATA   completed at: $(date +"%d-%m-%y %T")"

exit 0