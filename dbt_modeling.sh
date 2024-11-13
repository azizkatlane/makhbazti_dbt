#!/bin/bash

# Navigate to the project directory
cd ~/makhbazti_dbt/MAKHBAZTI_DBT

# Run dbt commands with the updated profiles directory path
dbt seed --select "Tunisia_Holidays" --profiles-dir ~/makhbazti_dbt/MAKHBAZTI_DBT
dbt snapshot --profiles-dir ~/makhbazti_dbt/MAKHBAZTI_DBT

# Run the dbt transformation and log output
dbt run --profiles-dir ~/makhbazti_dbt/MAKHBAZTI_DBT 2>&1 | tee logs/dbt_transform.log
