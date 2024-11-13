#!/bin/bash


cd ~/makhbazti_dbt

mkdir -p logs 


echo "EXTRACT LOAD  EL pipeline started at: $(date +"%d-%m-%y %T")"

python mongodb_pipeline.py 2>&1 | tee logs/mongodb_pipeline.log
echo "EXTRACT LOAD  completed at: $(date +"%d-%m-%y %T")"

exit 0